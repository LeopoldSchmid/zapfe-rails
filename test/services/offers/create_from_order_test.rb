require "test_helper"

class Offers::CreateFromOrderTest < ActiveSupport::TestCase
  test "creates a versioned fourteen-day draft from an order" do
    order = orders(:from_inquiry)

    offer = Offers::CreateFromOrder.new(order: order, admin_user: admin_users(:one)).call

    assert_equal 1, offer.version
    assert_equal "draft", offer.status
    assert_equal order.customer_name, offer.recipient_name
    assert_equal Date.current + 14.days, offer.valid_until
    assert_equal "Angebotsentwurf v1 erstellt", offer.activities.last.message
  end
end
