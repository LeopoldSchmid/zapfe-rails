require "test_helper"

class Admin::InvoicesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = admin_users(:one)
    sign_in_admin(@admin)
    @order = orders(:from_inquiry)
    @offer = @order.offers.create!(version: 1, status: "draft", valid_until: Date.current + 14.days, recipient_name: "Verein Freiburg", recipient_email: "rechnung@verein.example", recipient_address: "Musterstraße 1\n79100 Freiburg")
    @offer.line_items.create!(description: "Miete Zapfe", quantity: 1, unit: "Tag", net_unit_price: 100, tax_rate: 19, discount_type: "none")
    @offer.update_column(:status, "accepted")
  end

  test "creates and finalizes an invoice draft" do
    assert_difference("Invoice.count", 1) { post admin_order_invoices_url(@order), params: { offer_id: @offer.id } }
    invoice = Invoice.last
    assert_redirected_to admin_invoice_url(invoice)

    post finalize_admin_invoice_url(invoice)
    assert_redirected_to admin_invoice_url(invoice)
    assert_equal "finalized", invoice.reload.status
  end

  test "does not create an invoice from a non-accepted offer" do
    @offer.update_column(:status, "finalized")

    assert_no_difference("Invoice.count") { post admin_order_invoices_url(@order), params: { offer_id: @offer.id } }
    assert_redirected_to admin_order_invoices_url(@order)
  end

  test "downloads checksum-verified PDF and XRechnung artifacts" do
    post admin_order_invoices_url(@order), params: { offer_id: @offer.id }
    invoice = Invoice.last
    post finalize_admin_invoice_url(invoice)

    get document_admin_invoice_url(invoice)
    assert_response :success
    assert_equal "application/pdf", response.media_type

    get e_invoice_admin_invoice_url(invoice)
    assert_response :success
    assert_equal "application/xml", response.media_type
    assert Invoices::XrechnungValidator.new(response.body).validate!
  end

  test "creates a referenced stornorechnung instead of mutating invoice content" do
    post admin_order_invoices_url(@order), params: { offer_id: @offer.id }
    invoice = Invoice.last
    post finalize_admin_invoice_url(invoice)

    assert_difference("Invoice.count", 1) do
      post cancel_admin_invoice_url(invoice), params: { reason: "Auftrag einvernehmlich aufgehoben" }
    end

    credit_note = Invoice.order(:created_at).last
    assert_redirected_to admin_invoice_url(credit_note)
    assert_equal "cancelled", invoice.reload.status
    assert_equal invoice, credit_note.correction_of
    assert_equal "credit_note", credit_note.invoice_type
  end
end
