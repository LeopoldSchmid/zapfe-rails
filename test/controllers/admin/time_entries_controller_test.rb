require "test_helper"

class Admin::TimeEntriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = admin_users(:one)
    post admin_login_url, params: { email: @admin.email, password: "password123" }
    SystemSetting.current.update!(internal_hourly_cost: 40)
    @offer = Offer.create!(order: orders(:from_inquiry), version: 1, valid_until: Date.current + 14.days, recipient_name: "Max Mustermann")
  end

  test "adds planned work with the configured internal cost" do
    assert_difference("TimeEntry.count", 1) do
      post admin_offer_time_entries_url(@offer), params: { time_entry: { category: "organisation", minutes: 90, note: "Angebot abstimmen" } }
    end

    entry = TimeEntry.last
    assert_equal 40.to_d, entry.hourly_cost
    assert_equal 60.to_d, entry.cost_total
  end
end
