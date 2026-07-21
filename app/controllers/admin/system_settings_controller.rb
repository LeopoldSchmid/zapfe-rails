class Admin::SystemSettingsController < Admin::BaseController
  def edit
    @system_setting = SystemSetting.current
  end

  def update
    @system_setting = SystemSetting.current

    if @system_setting.update(system_setting_params)
      AdminSecurity::Audit.log(event_type: :system_settings_updated, actor: current_admin_user, target: current_admin_user, request: request, metadata: { changed_fields: @system_setting.previous_changes.keys - %w[updated_at] })
      redirect_to edit_admin_system_settings_path, notice: "Einstellungen aktualisiert."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def system_setting_params
    params.require(:system_setting).permit(
      :standard_tax_rate, :internal_hourly_cost, :company_name, :company_address, :vat_id,
      :bank_name, :iban, :bic, :payment_terms_days
    )
  end
end
