require "test_helper"

class Admin::OrderTimeEntriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = admin_users(:one)
    sign_in_admin(@admin)
    SystemSetting.current.update!(internal_hourly_cost: 40)
    @order = orders(:from_inquiry)
  end

  test "records actual work with the current admin" do
    assert_difference("TimeEntry.where(entry_type: 'actual').count", 1) do
      post admin_order_actual_time_entries_url(@order), params: { time_entry: { category: "execution", minutes: 120, recorded_on: Date.current, note: "Aufbau" } }
    end

    entry = TimeEntry.last
    assert_equal @admin, entry.admin_user
    assert_equal "actual", entry.entry_type
    assert_equal 80.to_d, entry.cost_total
  end
end
