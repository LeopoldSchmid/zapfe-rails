require "test_helper"

class Invoices::DocumentIntegrityTest < ActiveSupport::TestCase
  setup do
    admin = admin_users(:one)
    @invoice = Invoice.create!(
      order: orders(:from_inquiry), recipient_name: "Verein Freiburg",
      recipient_email: "rechnung@verein.example", recipient_address: "Musterstraße 1\n79100 Freiburg"
    )
    @invoice.line_items.create!(description: "Miete", quantity: 1, unit: "Tag", net_unit_price: 100, tax_rate: 19, discount_type: "none")
    Invoices::Finalize.new(invoice: @invoice, admin_user: admin).call
  end

  test "accepts unchanged PDF and XML artifacts" do
    assert Invoices::DocumentIntegrity.verify!(@invoice, kind: :pdf)
    assert Invoices::DocumentIntegrity.verify!(@invoice, kind: :xml)
  end

  test "blocks a modified artifact" do
    @invoice.document.blob.service.upload(@invoice.document.blob.key, StringIO.new("tampered"))

    assert_raises(Invoices::DocumentIntegrity::IntegrityError) do
      Invoices::DocumentIntegrity.verify!(@invoice, kind: :pdf)
    end
  end
end
