require "test_helper"

class SupplierOfferingTest < ActiveSupport::TestCase
  test "uses the profile values unless an offering overrides them" do
    stock_offering = supplier_offerings(:suedstar_variant)
    special_offering = supplier_offerings(:beck_variant)

    assert_equal 2, stock_offering.lead_time_days
    assert_equal "returnable", stock_offering.return_policy
    assert_equal 10, special_offering.lead_time_days
    assert_equal "non_returnable", special_offering.return_policy
  end

  test "returns the valid purchase price for a date without changing history" do
    offering = supplier_offerings(:beck_variant)

    assert_equal 70.to_d, offering.current_price(on: Date.new(2025, 6, 1)).purchase_price
    assert_equal 74.to_d, offering.current_price(on: Date.new(2026, 6, 1)).purchase_price
  end

  test "requires the selected profile to belong to the same supplier" do
    offering = supplier_offerings(:suedstar_variant)
    offering.procurement_profile = procurement_profiles(:special_order)

    assert_not offering.valid?
    assert_includes offering.errors.attribute_names, :procurement_profile
  end
end
