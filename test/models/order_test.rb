require "test_helper"

class OrderTest < ActiveSupport::TestCase
  test "requires the agreed operational minimum" do
    order = Order.new

    assert_not order.valid?
    assert_includes order.errors.attribute_names, :responsible_admin_user
    assert_includes order.errors.attribute_names, :customer_name
    assert_includes order.errors.attribute_names, :event_location
  end

  test "accepts the agreed statuses" do
    order = orders(:from_inquiry)

    Order::STATUSES.each do |status|
      order.status = status
      assert order.valid?, status
    end
  end
end
