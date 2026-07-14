require "test_helper"

class SystemSettingTest < ActiveSupport::TestCase
  test "provides a singleton with the agreed tax default" do
    setting = SystemSetting.current

    assert_equal 19.to_d, setting.standard_tax_rate
    assert_equal setting, SystemSetting.current
  end
end
