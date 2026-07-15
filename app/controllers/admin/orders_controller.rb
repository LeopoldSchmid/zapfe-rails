class Admin::OrdersController < Admin::BaseController
  before_action :set_order, only: %i[show procurement execution notes update update_notes add_attachments add_note archive unarchive download_attachment]

  def index
    @orders = Order.includes(:responsible_admin_user, :inquiry).order(event_date: :asc)
    @orders = params[:archived] == "1" ? @orders.where.not(archived_at: nil) : @orders.where(archived_at: nil)
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
    @order = Order.new(responsible_admin_user: current_admin_user, status: "preparing")
    @admin_users = AdminUser.active.order(:name)
    @order_templates = OrderTemplate.active.order(:name)
  end

  def create
    @order = Order.new(order_params)
    @admin_users = AdminUser.active.order(:name)
    @order_templates = OrderTemplate.active.order(:name)
    template = @order_templates.find_by(id: params[:order_template_id])
    Orders::ApplyTemplate.new(order: @order, template: template).apply_defaults! if template

    if @order.save
      Orders::ApplyTemplate.new(order: @order, template: template).materialize! if template
      redirect_to admin_order_path(@order), notice: "Auftrag erstellt."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @admin_users = AdminUser.active.order(:name)

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
    @order = Order.includes(:responsible_admin_user, :inquiry).find(params[:id])
  end

  def order_params
    params.require(:order).permit(
      :responsible_admin_user_id, :status, :customer_name, :customer_email, :customer_phone,
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
    allowed_types = %w[application/pdf image/jpeg image/png image/webp]
    attachments.all? { |attachment| attachment.size <= 25.megabytes && attachment.content_type.in?(allowed_types) }
  end

  def record_changes
    { "responsible_admin_user_id" => "Verantwortlichkeit", "status" => "Status", "event_date" => "Veranstaltungsdatum" }.each do |attribute, label|
      next unless @order.saved_change_to_attribute?(attribute)

      from, to = @order.saved_change_to_attribute(attribute)
      Activity.create!(admin_user: current_admin_user, subject: @order, event_type: attribute, message: "#{label} geändert", metadata: { from: from, to: to })
    end
  end

  def prepare_overview
    @admin_users = AdminUser.active.order(:name)
    @timeline_activities = timeline_activities
    @resources = Resource.active.order(:resource_type, :name)
    @reservations = @order.reservations.includes(:resource, :offer).order(:starts_at)
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
end
