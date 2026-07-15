require "test_helper"

class OfferLineItemTest < ActiveSupport::TestCase

  test "requires an integer quantity" do
    line_item = OfferLineItem.new(
      offer: @offer, position_type: "free", description: "Halbe Miete",
      quantity: 0.5, unit: "Stk", net_unit_price: 10, tax_rate: 19, discount_type: "none", discount_value: 0
    )

    assert_not line_item.valid?
    assert_equal :not_an_integer, line_item.errors.details[:quantity].first[:error]
  end
  setup do
    @offer = Offer.create!(order: orders(:from_inquiry), version: 1, valid_until: Date.current + 14.days, recipient_name: "Max Mustermann")
  end

  test "calculates net tax gross costs and margin with BigDecimal values" do
    @offer.line_items.create!(description: "Miete", quantity: 2, unit: "Tag", net_unit_price: 100, discount_type: "percent", discount_value: 10, tax_rate: 19, direct_cost_unit: 25)

    assert_equal 180.to_d, @offer.net_total
    assert_equal 34.2.to_d, @offer.tax_total
    assert_equal 214.2.to_d, @offer.gross_total
    assert_equal 50.to_d, @offer.direct_cost_total
    assert_equal 130.to_d, @offer.contribution_margin
  end

  test "rejects a supplier offering for another product variant" do
    item = @offer.line_items.build(description: "Fass", quantity: 1, unit: "Stk", net_unit_price: 100, product_variant: product_variants(:two), supplier_offering: supplier_offerings(:suedstar_variant))

    assert_not item.valid?
    assert_includes item.errors.attribute_names, :supplier_offering
  end

  test "applies a documented global discount after line discounts" do
    @offer.line_items.create!(description: "Miete", quantity: 2, unit: "Tag", net_unit_price: 100, tax_rate: 19)
    @offer.update!(global_discount_type: "percent", global_discount_value: 10, global_discount_reason: "Frühbuchung")

    assert_equal 20.to_d, @offer.global_discount_amount
    assert_equal 180.to_d, @offer.net_total
    assert_equal 34.2.to_d, @offer.tax_total
    assert_equal 214.2.to_d, @offer.gross_total
  end

  test "includes planned work in direct costs and contribution margin" do
    @offer.line_items.create!(description: "Miete", quantity: 1, unit: "Tag", net_unit_price: 100, tax_rate: 19)
    @offer.time_entries.create!(order: @offer.order, entry_type: "planned", category: "organisation", minutes: 90, hourly_cost: 40)

    assert_equal 60.to_d, @offer.planned_time_cost_total
    assert_equal 60.to_d, @offer.direct_cost_total
    assert_equal 40.to_d, @offer.contribution_margin
  end
end
