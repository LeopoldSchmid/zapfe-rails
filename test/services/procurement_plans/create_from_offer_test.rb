require "test_helper"

class ProcurementPlans::CreateFromOfferTest < ActiveSupport::TestCase
  setup do
    @order = orders(:from_inquiry)
    @order.update!(event_date: Date.new(2026, 9, 1))
    @offer = Offer.create!(order: @order, version: 1, valid_until: Date.current + 14.days, recipient_name: "Max Mustermann")
    @offer.line_items.create!(description: "Rothaus Pils", quantity: 2, unit: "Fass", net_unit_price: 120, tax_rate: 19, product_variant: product_variants(:one), supplier_offering: supplier_offerings(:suedstar_variant), direct_cost_unit: 72.5)
    Offers::Finalize.new(offer: @offer, admin_user: admin_users(:one)).call
    Offers::Resolve.new(offer: @offer, status: "accepted", admin_user: admin_users(:one)).call
  end

  test "creates a procurement snapshot with the supplier conditions and deadline" do
    plan = ProcurementPlans::CreateFromOffer.new(offer: @offer).call
    item = plan.items.first

    assert_equal "planned", plan.status
    assert_equal @offer, plan.offer
    assert_equal supplier_offerings(:suedstar_variant), item.supplier_offering
    assert_equal 72.5.to_d, item.purchase_price
    assert_equal 2, item.lead_time_days
    assert_equal Date.new(2026, 8, 30), item.order_by_on
    task = plan.tasks.sole
    assert_equal "Beschaffung bestellen", task.title
    assert_equal Date.new(2026, 8, 30), task.due_on
    assert_equal(-2, task.relative_offset_days)
  end

  test "includes external rental or combined free positions without a supplier source" do
    offer = Offer.create!(order: @order, version: 2, valid_until: Date.current + 14.days, recipient_name: "Max Mustermann")
    offer.line_items.create!(description: "Externe Kühlanhänger-Miete", quantity: 1, unit: "Tag", net_unit_price: 180, tax_rate: 19, direct_cost_unit: 120)
    Offers::Finalize.new(offer: offer, admin_user: admin_users(:one)).call
    Offers::Resolve.new(offer: offer, status: "accepted", admin_user: admin_users(:one)).call
    plan = ProcurementPlans::CreateFromOffer.new(offer: offer).call

    item = plan.items.find_by!(description: "Externe Kühlanhänger-Miete")
    assert_nil item.supplier_offering
    assert_equal 120.to_d, item.purchase_price
    assert_nil item.order_by_on
  end
end
