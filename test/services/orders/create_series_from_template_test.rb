require "test_helper"

class Orders::CreateSeriesFromTemplateTest < ActiveSupport::TestCase
  test "creates independent weekly orders named after the template and date" do
    template = OrderTemplate.create!(name: "Golf-Event", event_location: "Golfclub", responsible_admin_user: admin_users(:one))

    orders = Orders::CreateSeriesFromTemplate.new(
      template: template,
      start_on: Date.new(2026, 7, 14),
      weekday: 1,
      occurrences: 4,
      admin_user: admin_users(:one)
    ).call

    assert_equal [ Date.new(2026, 7, 20), Date.new(2026, 7, 27), Date.new(2026, 8, 3), Date.new(2026, 8, 10) ], orders.map(&:event_date)
    assert_equal "Golf-Event · 20.07.2026", orders.first.customer_name
    assert orders.all?(&:persisted?)
  end
end
