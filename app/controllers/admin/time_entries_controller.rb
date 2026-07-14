class Admin::TimeEntriesController < Admin::BaseController
  before_action :set_offer
  before_action :set_time_entry, only: %i[destroy]

  def create
    @time_entry = @offer.time_entries.build(time_entry_params.merge(order: @offer.order, entry_type: "planned", hourly_cost: SystemSetting.current.internal_hourly_cost || 0))
    @time_entry.admin_user = current_admin_user

    if @time_entry.save
      redirect_to admin_offer_path(@offer), notice: "Geplante Arbeitszeit hinzugefügt."
    else
      redirect_to admin_offer_path(@offer), alert: @time_entry.errors.full_messages.to_sentence
    end
  end

  def destroy
    return redirect_to(admin_offer_path(@offer), alert: "Finalisierte Angebote können nicht mehr geändert werden.") unless @offer.editable?

    @time_entry.destroy!
    redirect_to admin_offer_path(@offer), notice: "Geplante Arbeitszeit entfernt."
  end

  private

  def set_offer
    @offer = Offer.find(params[:offer_id])
  end

  def set_time_entry
    @time_entry = @offer.time_entries.find(params[:id])
  end

  def time_entry_params
    params.require(:time_entry).permit(:category, :minutes, :note)
  end
end
