class Admin::OrderTimeEntriesController < Admin::BaseController
  before_action :set_order
  before_action :set_time_entry, only: :destroy

  def create
    @time_entry = @order.time_entries.build(time_entry_params.merge(entry_type: "actual", hourly_cost: SystemSetting.current.internal_hourly_cost || 0))
    @time_entry.admin_user = current_admin_user

    if @time_entry.save
      redirect_to admin_order_path(@order), notice: "Tatsächliche Arbeitszeit erfasst."
    else
      redirect_to admin_order_path(@order), alert: @time_entry.errors.full_messages.to_sentence
    end
  end

  def destroy
    @time_entry.destroy!
    redirect_to admin_order_path(@order), notice: "Arbeitszeit entfernt."
  end

  private

  def set_order
    @order = Order.find(params[:order_id])
  end

  def set_time_entry
    @time_entry = @order.time_entries.find(params[:id])
  end

  def time_entry_params
    params.require(:time_entry).permit(:category, :minutes, :recorded_on, :note)
  end
end
