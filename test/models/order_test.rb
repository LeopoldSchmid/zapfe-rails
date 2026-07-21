require "test_helper"

class OrderTest < ActiveSupport::TestCase
  test "rejects an unexpected status jump" do
    order = orders(:from_inquiry)
    order.status = "completed"

    assert_not order.valid?
    assert_includes order.errors[:status], "kann nicht von preparing nach completed wechseln"
  end

  test "allows an explicit status transition" do
    order = orders(:from_inquiry)

    assert order.update(status: "offered")
  end
  test "requires the agreed operational minimum" do
    order = Order.new

    assert_not order.valid?
    assert_includes order.errors.attribute_names, :responsible_admin_user
    assert_includes order.errors.attribute_names, :customer_name
    assert_includes order.errors.attribute_names, :event_location
  end

  test "accepts the agreed statuses" do
    Order::STATUSES.each do |status|
      order = Order.new(status: status, responsible_admin_user: admin_users(:one), customer_name: "Test", event_location: "Freiburg")
      assert order.valid?, status
    end
  end
end
