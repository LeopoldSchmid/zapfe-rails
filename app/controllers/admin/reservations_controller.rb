class Admin::ReservationsController < Admin::BaseController
  before_action :set_order
  before_action :set_reservation, only: %i[update destroy]

  def create
    @reservation = @order.reservations.build(reservation_params.merge(status: reservation_params[:status].presence || "requested"))
    if @reservation.save
      record_activity(@reservation.requested? ? "Ressource angefragt" : "Ressource verbindlich reserviert")
      redirect_to admin_order_path(@order), notice: @reservation.requested? ? "Ressource angefragt." : "Ressource verbindlich reserviert."
    else
      redirect_to admin_order_path(@order), alert: @reservation.errors.full_messages.to_sentence
    end
  end

  def update
    previous_status = @reservation.status
    if @reservation.update(reservation_params)
      register_undo(@reservation, attribute: :status, from: previous_status, path: admin_order_path(@order)) if @reservation.saved_change_to_status?
      record_activity(@reservation.reserved? ? "Ressource verbindlich reserviert" : "Ressourcenanfrage aktualisiert")
      redirect_to admin_order_path(@order), notice: @reservation.reserved? ? "Ressource verbindlich reserviert." : "Ressourcenanfrage aktualisiert."
    else
      redirect_to admin_order_path(@order), alert: @reservation.errors.full_messages.to_sentence
    end
  end

  def destroy
    record_activity("Ressource freigegeben")
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
    params.require(:reservation).permit(:resource_id, :offer_id, :starts_at, :ends_at, :note, :status)
  end

  def record_activity(message)
    @order.activities.create!(admin_user: current_admin_user, event_type: "reservation", message: "#{message}: #{@reservation.resource.name}")
  end
end
