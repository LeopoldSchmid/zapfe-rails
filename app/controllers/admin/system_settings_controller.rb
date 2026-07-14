class Admin::SystemSettingsController < Admin::BaseController
  def edit
    @system_setting = SystemSetting.current
  end

  def update
    @system_setting = SystemSetting.current

    if @system_setting.update(system_setting_params)
      redirect_to edit_admin_system_settings_path, notice: "Einstellungen aktualisiert."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def system_setting_params
    params.require(:system_setting).permit(:standard_tax_rate, :internal_hourly_cost)
  end
end
