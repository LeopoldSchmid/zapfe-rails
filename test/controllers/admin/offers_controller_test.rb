require "test_helper"

class Admin::OffersControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper
  include ActionMailer::TestHelper

  setup do
    @admin = admin_users(:one)
    post admin_login_url, params: { email: @admin.email, password: "password123" }
  end

  test "creates a draft and adds a free line item" do
    order = orders(:from_inquiry)

    assert_difference("Offer.count", 1) { post admin_order_offers_url(order) }
    offer = Offer.last
    assert_redirected_to admin_offer_url(offer)

    assert_difference("OfferLineItem.count", 1) do
      post admin_offer_line_items_url(offer), params: { offer_line_item: { position_type: "free", description: "Lieferung", quantity: 1, unit: "Pauschale", net_unit_price: 50, tax_rate: 19, discount_type: "none", discount_value: 0 } }
    end

    assert_equal 50.to_d, offer.reload.net_total
    assert_equal 59.5.to_d, offer.gross_total

    get admin_offer_url(offer)
    assert_response :success
  end

  test "renders the offers work area for an order" do
    order = orders(:from_inquiry)

    get admin_order_offers_url(order)

    assert_response :success
    assert_select "h2", text: "Angebote erstellen und bearbeiten"
  end

  test "removes an editable line item" do
    offer = Offer.create!(order: orders(:from_inquiry), version: 1, valid_until: Date.current + 14.days, recipient_name: "Max Mustermann")
    line_item = offer.line_items.create!(description: "Lieferung", quantity: 1, unit: "Pauschale", net_unit_price: 50, tax_rate: 19)

    assert_difference("OfferLineItem.count", -1) { delete admin_offer_line_item_url(offer, line_item) }
    assert_redirected_to admin_offer_url(offer)
  end

  test "finalizes a draft and creates an editable next version" do
    offer = Offer.create!(order: orders(:from_inquiry), version: 1, valid_until: Date.current + 14.days, recipient_name: "Max Mustermann")
    offer.line_items.create!(description: "Miete", quantity: 1, unit: "Tag", net_unit_price: 100, tax_rate: 19)

    post finalize_admin_offer_url(offer)
    assert_redirected_to admin_offer_url(offer)
    assert_equal "finalized", offer.reload.status

    assert_difference("Offer.count", 1) { post duplicate_admin_offer_url(offer) }
    duplicate = Offer.last
    assert_equal "draft", duplicate.status
    assert_equal 2, duplicate.version
    assert_equal 1, duplicate.line_items.count
  end

  test "downloads a finalized offer PDF through the protected route" do
    offer = Offer.create!(order: orders(:from_inquiry), version: 1, valid_until: Date.current + 14.days, recipient_name: "Max Mustermann")
    offer.line_items.create!(description: "Miete", quantity: 1, unit: "Tag", net_unit_price: 100, tax_rate: 19)
    Offers::Finalize.new(offer: offer, admin_user: @admin).call

    get document_admin_offer_url(offer)

    assert_response :success
    assert_equal "application/pdf", response.media_type
  end

  test "queues a finalized offer email" do
    offer = Offer.create!(order: orders(:from_inquiry), version: 1, valid_until: Date.current + 14.days, recipient_name: "Max Mustermann", recipient_email: "max@example.com")
    offer.line_items.create!(description: "Miete", quantity: 1, unit: "Tag", net_unit_price: 100, tax_rate: 19)
    Offers::Finalize.new(offer: offer, admin_user: @admin).call

    assert_enqueued_emails 1 do
      post send_mail_admin_offer_url(offer)
    end

    assert_redirected_to admin_offer_url(offer)
    assert_equal "sent", offer.reload.status
  end

  test "uses the selected matching supplier offering as direct cost" do
    offer = Offer.create!(order: orders(:from_inquiry), version: 1, valid_until: Date.current + 14.days, recipient_name: "Max Mustermann")
    variant = product_variants(:one)
    supplier_offering = supplier_offerings(:suedstar_variant)

    post admin_offer_line_items_url(offer), params: { offer_line_item: { product_variant_id: variant.id, supplier_offering_id: supplier_offering.id, quantity: 2, unit: "Fass", net_unit_price: 120, tax_rate: 19, discount_type: "none", discount_value: 0 } }

    assert_equal 1, offer.line_items.count
    line_item = OfferLineItem.last
    assert_equal supplier_offering, line_item.supplier_offering
    assert_equal 72.5.to_d, line_item.direct_cost_unit
    assert_equal 145.to_d, line_item.direct_cost_total
  end

  test "uses the default supplier offering when a product variant is selected" do
    offer = Offer.create!(order: orders(:from_inquiry), version: 1, valid_until: Date.current + 14.days, recipient_name: "Max Mustermann")
    variant = product_variants(:one)

    post admin_offer_line_items_url(offer), params: { offer_line_item: { product_variant_id: variant.id, quantity: 1, unit: "Fass", net_unit_price: 0, tax_rate: 19, discount_type: "none", discount_value: 0 } }

    line_item = offer.reload.line_items.sole
    assert_equal supplier_offerings(:suedstar_variant), line_item.supplier_offering
    assert_equal variant.price, line_item.net_unit_price
  end

  test "returns only matching supplier offerings for a product variant" do
    offer = Offer.create!(order: orders(:from_inquiry), version: 1, valid_until: Date.current + 14.days, recipient_name: "Max Mustermann")

    get supplier_options_admin_offer_url(offer), params: { product_variant_id: product_variants(:one).id }, as: :json

    assert_response :success
    assert_equal product_variants(:one).price.to_s, response.parsed_body.fetch("net_unit_price").to_s
    assert_equal [ "Getränkemarkt Südstar", "Getränke Beck" ], response.parsed_body.fetch("offerings").map { |offering| offering.fetch("label").split(" · ").first }
    assert response.parsed_body.fetch("offerings").first.fetch("preferred")
  end

  test "derives a product description when only a supplier offering is selected" do
    offer = Offer.create!(order: orders(:from_inquiry), version: 1, valid_until: Date.current + 14.days, recipient_name: "Max Mustermann")
    supplier_offering = supplier_offerings(:suedstar_variant)

    post admin_offer_line_items_url(offer), params: { offer_line_item: { supplier_offering_id: supplier_offering.id, quantity: 1, unit: "Fass", net_unit_price: 120, tax_rate: 19, discount_type: "none", discount_value: 0 } }

    line_item = offer.reload.line_items.sole
    assert_equal supplier_offering.product_variant, line_item.product_variant
    assert_equal "Rothaus Pils · 20 l", line_item.description
  end

  test "lists matching supplier alternatives in preferred supplier order" do
    offer = Offer.create!(order: orders(:from_inquiry), version: 1, valid_until: Date.current + 14.days, recipient_name: "Max Mustermann")
    get supplier_options_admin_offer_url(offer), params: { product_variant_id: product_variants(:one).id }, as: :json

    assert_response :success
    assert_equal [ "Getränkemarkt Südstar", "Getränke Beck" ], response.parsed_body.fetch("offerings").map { |offering| offering.fetch("label").split(" · ").first }
  end

  test "returns active resource rental positions for the offer search" do
    Resource.create!(name: "Ape Position", resource_type: "Ape", rental_position_name: "Miete Zapfe", rental_net_price: 250, rental_unit: "Tag")
    offer = Offer.create!(order: orders(:from_inquiry), version: 1, valid_until: Date.current + 14.days, recipient_name: "Max Mustermann")

    get position_options_admin_offer_url(offer), as: :json

    assert_response :success
    assert_includes response.parsed_body.map { |item| item.fetch("label") }, "Ape · Miete Zapfe"
  end

  test "creates a resource rental line item with configured defaults" do
    resource = Resource.create!(name: "Ape Angebot", resource_type: "Ape", rental_position_name: "Miete Zapfe", rental_net_price: 250, rental_unit: "Tag")
    offer = Offer.create!(order: orders(:from_inquiry), version: 1, valid_until: Date.current + 14.days, recipient_name: "Max Mustermann")

    post admin_offer_line_items_url(offer), params: { offer_line_item: { resource_id: resource.id, quantity: 1, unit: "", net_unit_price: "", tax_rate: 19, discount_type: "none", discount_value: 0 } }

    line_item = offer.reload.line_items.sole
    assert_equal resource, line_item.resource
    assert_equal "Miete Zapfe", line_item.description
    assert_equal 250.to_d, line_item.net_unit_price
    assert_equal "Tag", line_item.unit
  end
end
