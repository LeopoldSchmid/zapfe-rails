class Admin::ProcurementPlansController < Admin::BaseController
  before_action :set_order
  before_action :set_plan, only: %i[update destroy add_attachments download_attachment]

  def create
    offer = @order.offers.find(params.require(:offer_id))
    plan = ProcurementPlans::CreateFromOffer.new(offer: offer).call
    redirect_to procurement_admin_order_path(@order), notice: "Beschaffungsplan mit #{plan.items.count} Positionen erstellt."
  rescue ActiveRecord::RecordInvalid
    redirect_to procurement_admin_order_path(@order), alert: "Abgelehnte oder abgelaufene Angebote können nicht als Beschaffungsgrundlage verwendet werden."
  end

  def update
    if confirming_non_returnable_without_acknowledgement?
      return redirect_to(procurement_admin_order_path(@order), alert: "Nicht rückgabefähige Positionen müssen vor der Bestätigung bewusst bestätigt werden.")
    end

    confirm_non_returnable! if confirming_non_returnable?
    if @plan.update(plan_params)
      redirect_to procurement_admin_order_path(@order), notice: "Beschaffungsplan aktualisiert."
    else
      redirect_to procurement_admin_order_path(@order), alert: @plan.errors.full_messages.to_sentence
    end
  end

  def destroy
    @plan.destroy!
    redirect_to procurement_admin_order_path(@order), notice: "Beschaffungsplan gelöscht."
  end

  def add_attachments
    attachments = Array(params.require(:procurement_plan).fetch(:attachments, [])).reject(&:blank?)
    allowed_types = %w[application/pdf image/jpeg image/png image/webp]
    unless attachments.all? { |attachment| attachment.size <= 25.megabytes && attachment.content_type.in?(allowed_types) }
      return redirect_to(procurement_admin_order_path(@order), alert: "Erlaubt sind PDF, JPEG, PNG und WebP bis 25 MB.")
    end

    @plan.attachments.attach(attachments)
    redirect_to procurement_admin_order_path(@order), notice: "Beschaffungsanlagen hinzugefügt."
  rescue ActiveRecord::RecordInvalid
    redirect_to procurement_admin_order_path(@order), alert: @plan.errors.full_messages.to_sentence
  end

  def download_attachment
    attachment = @plan.attachments.find(params[:attachment_id])
    send_data attachment.download, filename: attachment.filename.to_s, type: attachment.content_type, disposition: "attachment"
  end

  private

  def set_order
    @order = Order.find(params[:order_id])
  end

  def set_plan
    @plan = @order.procurement_plans.find(params[:id])
  end

  def plan_params
    params.require(:procurement_plan).permit(:status, :notes)
  end

  def confirming_non_returnable?
    plan_params[:status] == "confirmed" && @plan.requires_non_returnable_confirmation? && @plan.non_returnable_confirmed_at.blank?
  end

  def confirming_non_returnable_without_acknowledgement?
    confirming_non_returnable? && params[:confirm_non_returnable] != "1"
  end

  def confirm_non_returnable!
    @plan.assign_attributes(non_returnable_confirmed_at: Time.current, non_returnable_confirmed_by: current_admin_user)
  end
end
