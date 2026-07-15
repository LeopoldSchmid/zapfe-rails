require "test_helper"

class Admin::InvoicesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = admin_users(:one)
    post admin_login_url, params: { email: @admin.email, password: "password123" }
    @order = orders(:from_inquiry)
    @offer = @order.offers.create!(version: 1, status: "draft", valid_until: Date.current + 14.days, recipient_name: "Verein Freiburg", recipient_address: "Musterstraße 1\n79100 Freiburg")
    @offer.line_items.create!(description: "Miete Zapfe", quantity: 1, unit: "Tag", net_unit_price: 100, tax_rate: 19, discount_type: "none")
    @offer.update!(status: "accepted")
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
end
