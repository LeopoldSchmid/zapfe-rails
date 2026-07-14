require "test_helper"

class TimeEntryTest < ActiveSupport::TestCase
  test "calculates internal cost from minutes and hourly cost" do
    entry = TimeEntry.new(order: orders(:from_inquiry), entry_type: "planned", category: "organisation", minutes: 90, hourly_cost: 40)

    assert entry.valid?
    assert_equal 60.to_d, entry.cost_total
  end

  test "requires an offer from the same order" do
    offer = Offer.create!(order: orders(:from_inquiry), version: 1, valid_until: Date.current + 14.days, recipient_name: "Max Mustermann")
    entry = TimeEntry.new(order: Order.create!(responsible_admin_user: admin_users(:one), customer_name: "Andere GmbH", event_location: "Freiburg"), offer: offer, entry_type: "planned", category: "organisation", minutes: 60, hourly_cost: 40)

    assert_not entry.valid?
    assert_includes entry.errors.attribute_names, :offer
  end
end
