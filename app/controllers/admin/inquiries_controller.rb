class Admin::InquiriesController < Admin::BaseController
  before_action :set_inquiry, only: %i[show assign convert_to_order add_attachments add_note archive download_attachment]

  def index
    @inquiries = Inquiry.includes(:assigned_admin_user, :order).order(created_at: :desc)
    @inquiries = params[:archived] == "1" ? @inquiries.where.not(archived_at: nil) : @inquiries.where(archived_at: nil)
    @inquiries = @inquiries.where(status: params[:status]) if params[:status].present?
    @inquiries = @inquiries.where(assigned_admin_user_id: params[:assigned_admin_user_id]) if params[:assigned_admin_user_id].present?
    @inquiries = @inquiries.where(assigned_admin_user_id: nil) if params[:unassigned] == "1"
    @inquiries = @inquiries.where(next_step_due_on: ..Date.current) if params[:due] == "overdue"
    @inquiries = @inquiries.where(next_step_due_on: Date.current..7.days.from_now.to_date) if params[:due] == "next_7_days"
    @admin_users = AdminUser.active.order(:name)
  end

  def show
    @admin_users = AdminUser.active.order(:name)
    @activities = @inquiry.activities.includes(:admin_user).order(created_at: :desc)
  end

  def assign
    if @inquiry.update(inquiry_params)
      record_changes
      redirect_to admin_inquiry_path(@inquiry), notice: "Anfrage aktualisiert."
    else
      @admin_users = AdminUser.active.order(:name)
      render :show, status: :unprocessable_entity
    end
  end

  def convert_to_order
    order = Orders::CreateFromInquiry.new(inquiry: @inquiry, responsible_admin_user: current_admin_user).call
    redirect_to admin_order_path(order), notice: "Anfrage wurde in einen Auftrag umgewandelt."
  rescue ActiveRecord::RecordInvalid => error
    redirect_to admin_inquiry_path(@inquiry), alert: error.record.errors.full_messages.to_sentence
  end

  def add_attachments
    attachments = permitted_attachments(:inquiry)
    return redirect_to(admin_inquiry_path(@inquiry), alert: "Erlaubt sind PDF, JPEG, PNG und WebP bis 25 MB.") unless attachments_valid?(attachments)

    @inquiry.attachments.attach(attachments)
    redirect_to admin_inquiry_path(@inquiry), notice: "Anlagen hinzugefügt."
  rescue ActiveRecord::RecordInvalid
    redirect_to admin_inquiry_path(@inquiry), alert: @inquiry.errors.full_messages.to_sentence
  end

  def add_note
    @inquiry.activities.create!(admin_user: current_admin_user, event_type: "note", message: params.require(:note))
    redirect_to admin_inquiry_path(@inquiry), notice: "Notiz hinzugefügt."
  end

  def archive
    @inquiry.update!(archived_at: Time.current)
    redirect_to admin_inquiries_path, notice: "Anfrage archiviert."
  end

  def download_attachment
    attachment = @inquiry.attachments.find(params[:attachment_id])
    send_data attachment.download, filename: attachment.filename.to_s, type: attachment.content_type, disposition: "attachment"
  end

  private

  def set_inquiry
    @inquiry = Inquiry.includes(:assigned_admin_user, :order).find(params[:id])
  end

  def inquiry_params
    params.require(:inquiry).permit(
      :assigned_admin_user_id, :status, :next_step, :next_step_due_on, :closure_reason,
      :first_name, :last_name, :email, :phone, :event_type, :event_date, :starts_on, :ends_on,
      :start_time, :end_time, :delivery_street, :delivery_postcode, :delivery_city, :guests, :message
    )
  end

  def record_changes
    { "assigned_admin_user_id" => "Verantwortlichkeit", "status" => "Status", "event_date" => "Veranstaltungsdatum", "starts_on" => "Veranstaltungsbeginn", "ends_on" => "Veranstaltungsende" }.each do |attribute, label|
      next unless @inquiry.saved_change_to_attribute?(attribute)

      from, to = @inquiry.saved_change_to_attribute(attribute)
      Activity.create!(admin_user: current_admin_user, subject: @inquiry, event_type: attribute, message: "#{label} geändert", metadata: { from: from, to: to })
    end
  end

  def permitted_attachments(key)
    Array(params.require(key).fetch(:attachments, [])).reject(&:blank?)
  end

  def attachments_valid?(attachments)
    allowed_types = %w[application/pdf image/jpeg image/png image/webp]
    attachments.all? { |attachment| attachment.size <= 25.megabytes && attachment.content_type.in?(allowed_types) }
  end
end
