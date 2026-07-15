require "test_helper"

class Invoices::CreateFromOfferTest < ActiveSupport::TestCase
  setup do
    @admin = admin_users(:one)
    @offer = Offer.create!(order: orders(:from_inquiry), version: 1, status: "draft", valid_until: Date.current + 14.days, recipient_name: "Verein Freiburg", recipient_email: "rechnung@verein.example", recipient_address: "Musterstraße 1\n79100 Freiburg")
    @offer.line_items.create!(description: "Miete Zapfe", quantity: 1, unit: "Tag", net_unit_price: 100, tax_rate: 19, discount_type: "none")
    @offer.update!(status: "accepted")
  end

  test "creates a mutable invoice draft from an accepted offer" do
    invoice = Invoices::CreateFromOffer.new(offer: @offer, admin_user: @admin).call

    assert invoice.persisted?
    assert_equal "draft", invoice.status
    assert_equal @offer, invoice.offer
    assert_equal 1, invoice.line_items.count
    assert_equal 119.to_d, invoice.gross_total
    assert_equal Date.current + SystemSetting.current.payment_terms_days.days, invoice.due_on
  end

  test "rejects an invoice from an offer that was not accepted" do
    @offer.update_column(:status, "finalized")

    assert_raises(Invoices::CreateFromOffer::NotCreatable) { Invoices::CreateFromOffer.new(offer: @offer, admin_user: @admin).call }
  end
end
