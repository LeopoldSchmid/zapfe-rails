require "test_helper"

class Admin::ProcurementPlansControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = admin_users(:one)
    post admin_login_url, params: { email: @admin.email, password: "password123" }
    @order = orders(:from_inquiry)
    @offer = Offer.create!(order: @order, version: 1, valid_until: Date.current + 14.days, recipient_name: "Max Mustermann")
    @offer.line_items.create!(description: "Rothaus Pils", quantity: 1, unit: "Fass", net_unit_price: 120, tax_rate: 19, product_variant: product_variants(:one), supplier_offering: supplier_offerings(:suedstar_variant), direct_cost_unit: 72.5)
    Offers::Finalize.new(offer: @offer, admin_user: @admin).call
    Offers::Resolve.new(offer: @offer, status: "accepted", admin_user: @admin).call
  end

  test "creates and updates a procurement plan from an accepted offer" do
    assert_difference("ProcurementPlan.count", 1) do
      post admin_order_procurement_plans_url(@order), params: { offer_id: @offer.id }
    end

    plan = ProcurementPlan.last
    patch admin_order_procurement_plan_url(@order, plan), params: { procurement_plan: { status: "requested" } }
    assert_equal "requested", plan.reload.status
  end
end
