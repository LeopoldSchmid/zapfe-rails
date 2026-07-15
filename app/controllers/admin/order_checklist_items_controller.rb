class Admin::OrderChecklistItemsController < Admin::BaseController
  before_action :set_order_and_checklist

  def update
    item = @checklist.items.find(params[:id])
    item.update!(item_params)
    @checklist.refresh_status!
    redirect_to execution_admin_order_path(@order), notice: "Checklistenpunkt aktualisiert."
  rescue ActiveRecord::RecordInvalid => error
    redirect_to execution_admin_order_path(@order), alert: error.message
  end

  private

  def set_order_and_checklist
    @order = Order.find(params[:order_id])
    @checklist = @order.checklists.find(params[:checklist_id])
  end

  def item_params
    params.require(:order_checklist_item).permit(:completed, :notes, :attachment)
  end
end
