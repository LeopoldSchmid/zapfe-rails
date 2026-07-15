require "test_helper"

class Invoices::FinalizeTest < ActiveSupport::TestCase
  setup do
    @admin = admin_users(:one)
    @invoice = Invoice.create!(order: orders(:from_inquiry), recipient_name: "Verein Freiburg", recipient_address: "Musterstraße 1\n79100 Freiburg", due_on: Date.current + 14.days, delivery_on: Date.current)
    @invoice.line_items.create!(description: "Miete Zapfe", quantity: 1, unit: "Tag", net_unit_price: 100, tax_rate: 19, discount_type: "none")
  end

  test "numbers, freezes and renders a finalized invoice" do
    Invoices::Finalize.new(invoice: @invoice, admin_user: @admin).call

    @invoice.reload
    assert_equal "finalized", @invoice.status
    assert_match(/R-#{Date.current.year}-\d{6}/, @invoice.invoice_number)
    assert @invoice.document.attached?
    assert_equal "Ape2tap UG", @invoice.document_snapshot_data.dig("issuer", "company_name")
    assert_not @invoice.update(recipient_name: "Geändert")
  end
end
