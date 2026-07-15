require "test_helper"

class Offers::CreateFromOrderTest < ActiveSupport::TestCase
  test "creates a versioned fourteen-day draft from an order" do
    order = orders(:from_inquiry)
    order.product_selections.create!(product_variant: product_variants(:one), quantity: 2, unit: "Fass")

    offer = Offers::CreateFromOrder.new(order: order, admin_user: admin_users(:one)).call

    assert_equal 1, offer.version
    assert_equal "draft", offer.status
    assert_equal order.customer_name, offer.recipient_name
    assert_equal Date.current + 14.days, offer.valid_until
    assert_equal "Angebotsentwurf v1 erstellt", offer.activities.last.message
    line_item = offer.line_items.sole
    assert_equal product_variants(:one), line_item.product_variant
    assert_equal 2.to_d, line_item.quantity
    assert_equal "Fass", line_item.unit
    assert_equal product_variants(:one).price, line_item.net_unit_price
  end
end
