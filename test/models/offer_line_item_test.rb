require "test_helper"

class OfferLineItemTest < ActiveSupport::TestCase
  test "keeps a procurement snapshot when its draft offer line is deleted" do
    order = orders(:from_inquiry)
    offer = order.offers.create!(version: 1, status: "draft", recipient_name: order.customer_name, valid_until: Date.current + 14.days, global_discount_type: "none", global_discount_value: 0)
    line_item = offer.line_items.create!(position_type: "free", description: "Miete Zapfe", quantity: 1, unit: "Tag", net_unit_price: 100, tax_rate: 19, discount_type: "none", discount_value: 0)
    plan = order.procurement_plans.create!(offer: offer, status: "planned")
    item = plan.items.create!(offer_line_item: line_item, description: line_item.description, quantity: 1, unit: "Tag")

    line_item.destroy!

    assert_nil item.reload.offer_line_item
    assert_equal "Miete Zapfe", item.description
  end
end
