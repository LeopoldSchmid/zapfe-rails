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

  test "creates a procurement plan from a draft offer" do
    draft_offer = Offer.create!(order: @order, version: 2, valid_until: Date.current + 14.days, recipient_name: "Max Mustermann")
    draft_offer.line_items.create!(description: "Vorläufiges Fass", quantity: 1, unit: "Fass", net_unit_price: 120, tax_rate: 19)

    assert_difference("ProcurementPlan.count", 1) do
      post admin_order_procurement_plans_url(@order), params: { offer_id: draft_offer.id }
    end

    assert_equal draft_offer, ProcurementPlan.last.offer
  end

  test "adds offer positions created after the procurement plan" do
    draft_offer = Offer.create!(order: @order, version: 2, valid_until: Date.current + 14.days, recipient_name: "Max Mustermann")
    plan = ProcurementPlans::CreateFromOffer.new(offer: draft_offer).call
    draft_offer.line_items.create!(description: "Bierkrug", quantity: 12, unit: "Stk", net_unit_price: 8, tax_rate: 19, product_variant: product_variants(:one), supplier_offering: supplier_offerings(:suedstar_variant), direct_cost_unit: 5)

    assert_difference("plan.items.count", 1) do
      post sync_admin_order_procurement_plan_url(@order, plan)
    end

    assert_equal "Bierkrug", plan.items.order(:created_at).last.description
  end

  test "downloads a procurement attachment through the protected order route" do
    plan = ProcurementPlans::CreateFromOffer.new(offer: @offer).call
    plan.attachments.attach(io: StringIO.new("Lieferantenangebot"), filename: "angebot.pdf", content_type: "application/pdf")

    get attachment_admin_order_procurement_plan_url(@order, plan, plan.attachments.last)

    assert_response :success
    assert_equal "Lieferantenangebot", response.body
    assert_equal "application/pdf", response.media_type
  end

  test "deletes a procurement plan and its items" do
    plan = ProcurementPlans::CreateFromOffer.new(offer: @offer).call

    assert_difference([ "ProcurementPlan.count", "ProcurementPlanItem.count" ], -1) do
      delete admin_order_procurement_plan_url(@order, plan)
    end

    assert_redirected_to procurement_admin_order_url(@order)
  end

  test "requires an explicit confirmation for non-returnable procurement" do
    plan = @order.procurement_plans.create!(status: "planned")
    plan.items.create!(description: "Sonderbestellung", quantity: 1, unit: "Stk", return_policy: "non_returnable")

    patch admin_order_procurement_plan_url(@order, plan), params: { procurement_plan: { status: "confirmed" } }
    assert_equal "planned", plan.reload.status
    assert_nil plan.non_returnable_confirmed_at

    patch admin_order_procurement_plan_url(@order, plan), params: { procurement_plan: { status: "confirmed" }, confirm_non_returnable: "1" }
    assert_equal "confirmed", plan.reload.status
    assert_equal @admin, plan.non_returnable_confirmed_by
    assert_not_nil plan.non_returnable_confirmed_at
  end
end
