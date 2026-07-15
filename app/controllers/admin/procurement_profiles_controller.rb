class Admin::ProcurementProfilesController < Admin::BaseController
  before_action :set_profile

  def edit; end

  def update
    if @procurement_profile.update(profile_params)
      redirect_to admin_suppliers_path, notice: "Standardprofil aktualisiert."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_profile
    @procurement_profile = ProcurementProfile.standard.find(params[:id])
  end

  def profile_params
    params.require(:procurement_profile).permit(:lead_time_days, :return_policy, :return_period_days, :delivery_notes, :cancellation_notes)
  end
end
