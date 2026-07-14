class Admin::ReservationsController < Admin::BaseController
  before_action :set_order
  before_action :set_reservation, only: :destroy

  def create
    @reservation = @order.reservations.build(reservation_params)
    if @reservation.save
      redirect_to admin_order_path(@order), notice: "Ressource reserviert."
    else
      redirect_to admin_order_path(@order), alert: @reservation.errors.full_messages.to_sentence
    end
  end

  def destroy
    @reservation.destroy!
    redirect_to admin_order_path(@order), notice: "Reservierung entfernt."
  end

  private

  def set_order
    @order = Order.find(params[:order_id])
  end

  def set_reservation
    @reservation = @order.reservations.find(params[:id])
  end

  def reservation_params
    params.require(:reservation).permit(:resource_id, :offer_id, :starts_at, :ends_at, :note)
  end
end
