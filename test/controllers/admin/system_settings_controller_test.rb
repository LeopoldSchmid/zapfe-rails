require "test_helper"

class Admin::SystemSettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    admin = admin_users(:one)
    sign_in_admin(admin)
  end

  test "updates tax and internal hourly cost defaults" do
    patch admin_system_settings_url, params: { system_setting: { standard_tax_rate: 19, internal_hourly_cost: 35 } }

    assert_redirected_to edit_admin_system_settings_url
    assert_equal 35.to_d, SystemSetting.current.internal_hourly_cost
  end
end
