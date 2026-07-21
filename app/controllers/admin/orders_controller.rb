class Admin::OrdersController < Admin::BaseController
  before_action :set_order, only: %i[show procurement execution notes update update_notes add_attachments add_note archive unarchive download_attachment]

  def index
    @orders = Order.includes(:responsible_admin_user, :inquiry, :customer, :contact).order(event_date: :asc)
    @orders = params[:archived] == "1" ? @orders.where.not(archived_at: nil) : @orders.where(archived_at: nil)
    @orders = paginate(@orders)
  end

  def show
    prepare_overview
  end

  def procurement
    prepare_procurement
  end

  def execution
    prepare_execution
  end

  def notes
  end

  def new
    @admin_users = AdminUser.active.order(:name)
    @order_templates = OrderTemplate.active.order(:name)
    @selected_order_template = @order_templates.find_by(id: params[:order_template_id])
    @order = Order.new(status: "preparing")
    Orders::ApplyTemplate.new(order: @order, template: @selected_order_template).apply_defaults! if @selected_order_template
    @order.responsible_admin_user ||= current_admin_user
    prepare_customer_contacts
  end

  def create
    @admin_users = AdminUser.active.order(:name)
    @order_templates = OrderTemplate.active.order(:name)
    template = @order_templates.find_by(id: params[:order_template_id])
    attributes = order_params.to_h.symbolize_keys
    attributes[:responsible_admin_user] = current_admin_user if attributes[:responsible_admin_user_id].blank?
    @order = Orders::Create.new(attributes: attributes, template: template).call
    redirect_to admin_order_path(@order), notice: "Auftrag erstellt."
  rescue ActiveRecord::RecordInvalid => error
    @order = error.record.is_a?(Order) ? error.record : Order.new(attributes)
    prepare_customer_contacts
    render :new, status: :unprocessable_entity
  end

  def update
    @admin_users = AdminUser.active.order(:name)
    prepare_customer_contacts

    if @order.update(order_params)
      record_changes
      redirect_to admin_order_path(@order), notice: "Auftrag aktualisiert."
    else
      prepare_overview
      render :show, status: :unprocessable_entity
    end
  end

  def update_notes
    if @order.update(notes_params)
      @order.activities.create!(admin_user: current_admin_user, event_type: "freeform_notes", message: "Freie Testnotizen aktualisiert")
      redirect_to notes_admin_order_path(@order), notice: "Freie Testnotizen gespeichert."
    else
      render :notes, status: :unprocessable_entity
    end
  end

  def add_attachments
    attachments = permitted_attachments(:order)
    return redirect_to(admin_order_path(@order), alert: "Erlaubt sind PDF, JPEG, PNG und WebP bis 25 MB.") unless attachments_valid?(attachments)

    @order.attachments.attach(attachments)
    redirect_to admin_order_path(@order), notice: "Anlagen hinzugefügt."
  rescue ActiveRecord::RecordInvalid
    redirect_to admin_order_path(@order), alert: @order.errors.full_messages.to_sentence
  end

  def add_note
    @order.activities.create!(admin_user: current_admin_user, event_type: "note", message: params.require(:note))
    redirect_to admin_order_path(@order), notice: "Notiz hinzugefügt."
  end

  def archive
    @order.update!(archived_at: Time.current)
    redirect_to admin_orders_path, notice: "Auftrag archiviert."
  end

  def unarchive
    @order.update!(archived_at: nil)
    redirect_to admin_orders_path, notice: "Auftrag wiederhergestellt."
  end

  def download_attachment
    attachment = @order.attachments.find(params[:attachment_id])
    send_data attachment.download, filename: attachment.filename.to_s, type: attachment.content_type, disposition: "attachment"
  end

  private

  def set_order
    @order = Order.includes(:responsible_admin_user, :inquiry, :customer, :contact).find(params[:id])
  end

  def order_params
    params.require(:order).permit(
      :responsible_admin_user_id, :customer_id, :contact_id, :status, :customer_name, :customer_email, :customer_phone,
      :event_type, :event_date, :starts_on, :ends_on, :start_time, :end_time, :event_location,
      :guests, :customer_message, :next_step, :next_step_due_on
    )
  end

  def notes_params
    params.require(:order).permit(:freeform_notes)
  end

  def permitted_attachments(key)
    Array(params.require(key).fetch(:attachments, [])).reject(&:blank?)
  end

  def attachments_valid?(attachments)
    attachments.all? { |attachment| AttachmentSafety.safe_upload?(attachment) }
  end

  def record_changes
    {
      "responsible_admin_user_id" => "Verantwortlich",
      "status" => "Status",
      "customer_name" => "Kunde",
      "customer_email" => "E-Mail",
      "customer_phone" => "Telefon",
      "event_type" => "Veranstaltungsart",
      "event_date" => "Veranstaltungsdatum",
      "start_time" => "Beginn",
      "end_time" => "Ende",
      "event_location" => "Veranstaltungsort",
      "guests" => "Gästezahl",
      "customer_message" => "Kundennachricht"
    }.each do |attribute, label|
      next unless @order.saved_change_to_attribute?(attribute)

      from, to = @order.saved_change_to_attribute(attribute)
      Activity.create!(
        admin_user: current_admin_user,
        subject: @order,
        event_type: attribute,
        message: "#{label}: #{activity_value(attribute, from)} → #{activity_value(attribute, to)}",
        metadata: { from: from, to: to }
      )
    end
  end

  def prepare_overview
    @admin_users = AdminUser.active.order(:name)
    @timeline_activities = timeline_activities
    @resources = Resource.active.order(:resource_type, :name)
    @reservations = @order.reservations.includes(:resource, :offer).order(:starts_at)
    @open_task_count = @order.tasks.where.not(status: "done").count
    prepare_customer_contacts
  end

  def prepare_procurement
    @procurement_plans = @order.procurement_plans.includes(:offer, items: :supplier_offering).order(created_at: :desc)
  end

  def prepare_execution
    @admin_users = AdminUser.active.order(:name)
    @tasks = @order.tasks.includes(:assigned_admin_user).order(:due_on, :created_at)
    @actual_time_entries = @order.time_entries.where(entry_type: "actual").includes(:admin_user).order(recorded_on: :desc, created_at: :desc)
    @checklists = @order.checklists.includes(items: { attachment_attachment: :blob }).order(:section, :created_at)
    @checklist_templates = ChecklistTemplate.active.includes(:items).order(:resource_type, :section, :name)
  end

  def timeline_activities
    Activity.includes(:admin_user).where(subject: [ @order, @order.inquiry, *@order.offers, *@order.invoices ].compact).order(created_at: :desc)
  end

  def activity_value(attribute, value)
    return "—" if value.blank?

    case attribute
    when "responsible_admin_user_id"
      AdminUser.find_by(id: value)&.name || "Unzugewiesen"
    when "status"
      helpers.order_status_label(value)
    when "event_date"
      I18n.l(Date.parse(value.to_s))
    else
      value
    end
  rescue Date::Error
    value
  end

  def prepare_customer_contacts
    @customers = Customer.order(:name)
    @contacts = @order.customer&.contacts&.order(primary: :desc, name: :asc) || Contact.none
  end
end
