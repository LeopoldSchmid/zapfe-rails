require "test_helper"

class Invoices::CancelTest < ActiveSupport::TestCase
  setup do
    @admin = admin_users(:one)
    @invoice = Invoice.create!(
      order: orders(:from_inquiry), recipient_name: "Verein Freiburg",
      recipient_email: "rechnung@verein.example", recipient_address: "Musterstraße 1\n79100 Freiburg"
    )
    @invoice.line_items.create!(description: "Miete Zapfe", quantity: 1, unit: "Tag", net_unit_price: 100, tax_rate: 19, discount_type: "none")
    Invoices::Finalize.new(invoice: @invoice, admin_user: @admin).call
  end

  test "creates an immutable referenced credit note and cancels the original" do
    credit_note = Invoices::Cancel.new(invoice: @invoice, admin_user: @admin, reason: "Leistung entfällt").call

    assert_equal "cancelled", @invoice.reload.status
    assert_equal "credit_note", credit_note.invoice_type
    assert_equal "finalized", credit_note.status
    assert_equal @invoice, credit_note.correction_of
    assert credit_note.document.attached?
    assert credit_note.e_invoice.attached?
    assert_includes credit_note.document_snapshot, @invoice.invoice_number
    assert_not credit_note.update(recipient_name: "Manipuliert")
    assert Invoices::XrechnungValidator.new(credit_note.e_invoice.download).validate!
  end

  test "is idempotent and requires a reason" do
    assert_raises(Invoices::Cancel::NotCancellable) do
      Invoices::Cancel.new(invoice: @invoice, admin_user: @admin, reason: "").call
    end

    service = Invoices::Cancel.new(invoice: @invoice, admin_user: @admin, reason: "Storno")
    first = service.call
    assert_equal first, service.call
    assert_equal 1, @invoice.corrections.where(invoice_type: "credit_note").count
  end
end
