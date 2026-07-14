class Admin::ProcurementPlansController < Admin::BaseController
  before_action :set_order
  before_action :set_plan, only: :update

  def create
    offer = @order.offers.find(params.require(:offer_id))
    plan = ProcurementPlans::CreateFromOffer.new(offer: offer).call
    redirect_to admin_order_path(@order), notice: "Beschaffungsplan mit #{plan.items.count} Positionen erstellt."
  rescue ActiveRecord::RecordInvalid
    redirect_to admin_order_path(@order), alert: "Nur angenommene Angebote können in die Beschaffung übernommen werden."
  end

  def update
    if @plan.update(plan_params)
      redirect_to admin_order_path(@order), notice: "Beschaffungsplan aktualisiert."
    else
      redirect_to admin_order_path(@order), alert: @plan.errors.full_messages.to_sentence
    end
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
end
