require "test_helper"

class Offers::FinalizeTest < ActiveSupport::TestCase
  setup do
    @offer = Offer.create!(order: orders(:from_inquiry), version: 1, valid_until: Date.current + 14.days, recipient_name: "Max Mustermann")
    @offer.line_items.create!(description: "Miete", quantity: 1, unit: "Tag", net_unit_price: 100, tax_rate: 19)
  end

  test "assigns a number and preserves a complete financial snapshot" do
    Offers::Finalize.new(offer: @offer, admin_user: admin_users(:one)).call

    @offer.reload
    assert_equal "finalized", @offer.status
    assert_match(/\AA-#{Date.current.year}-\d{6}\z/, @offer.offer_number)
    assert_equal "100.0", @offer.document_snapshot_data.dig("totals", "net")
    assert_equal "Miete", @offer.document_snapshot_data.fetch("line_items").first.fetch("description")
    assert @offer.document.attached?
    assert_equal "application/pdf", @offer.document.content_type
  end

  test "locks offers and line items after finalization" do
    Offers::Finalize.new(offer: @offer, admin_user: admin_users(:one)).call

    @offer.recipient_name = "Andere GmbH"
    assert_not @offer.save
    @offer.line_items.first.description = "Geändert"
    assert_not @offer.line_items.first.save
  end

  test "freezes the selected supplier conditions with the offer" do
    offering = supplier_offerings(:suedstar_variant)
    @offer.order.update!(event_date: Date.current + 10.days)
    @offer.line_items.first.update!(product_variant: offering.product_variant, supplier_offering: offering, direct_cost_unit: 72.5)

    Offers::Finalize.new(offer: @offer, admin_user: admin_users(:one)).call

    procurement = @offer.reload.document_snapshot_data.fetch("line_items").first.fetch("procurement")
    assert_equal "Getränkemarkt Südstar", procurement.fetch("supplier_name")
    assert_equal "Lagerware", procurement.fetch("profile_name")
    assert_equal 2, procurement.fetch("lead_time_days")
    assert_equal "returnable", procurement.fetch("return_policy")
    assert_equal (Date.current + 8.days).iso8601, procurement.fetch("order_by_on")
  end
end
