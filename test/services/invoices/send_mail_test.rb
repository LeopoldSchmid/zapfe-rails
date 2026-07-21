require "test_helper"

class Invoices::SendMailTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @admin = admin_users(:one)
    @invoice = Invoice.create!(order: orders(:from_inquiry), recipient_name: "Verein Freiburg", recipient_email: "rechnung@verein.example", recipient_address: "Musterstraße 1\n79100 Freiburg", status: "draft")
    @invoice.line_items.create!(description: "Miete Zapfe", quantity: 1, unit: "Tag", net_unit_price: 100, tax_rate: 19, discount_type: "none")
    Invoices::Finalize.new(invoice: @invoice, admin_user: @admin).call
  end

  test "queues the finalized invoice email" do
    assert_enqueued_with(job: CustomerDocumentDeliveryJob) do
      @delivery = Invoices::SendMail.new(invoice: @invoice, admin_user: @admin).call
    end

    assert_equal "finalized", @invoice.reload.status
    assert_nil @invoice.sent_at
    assert_equal "queued", @delivery.status
    assert_equal "delivery_queued", @invoice.activities.order(:created_at).last.event_type
  end

  test "mail contains checksum-verified PDF and XRechnung attachments" do
    email = InvoiceMailer.invoice(@invoice)

    assert_equal [ "#{@invoice.invoice_number}.pdf", "#{@invoice.invoice_number}.xml" ], email.attachments.map(&:filename)
    assert_equal [ "application/pdf", "application/xml" ], email.attachments.map(&:mime_type)
  end

  test "does not send a document when external document delivery is disabled" do
    previous = ENV["CUSTOMER_DOCUMENT_DELIVERY_ENABLED"]
    ENV["CUSTOMER_DOCUMENT_DELIVERY_ENABLED"] = "false"
    begin
      assert_raises(Invoices::SendMail::NotSendable) { Invoices::SendMail.new(invoice: @invoice, admin_user: @admin).call }
    ensure
      ENV["CUSTOMER_DOCUMENT_DELIVERY_ENABLED"] = previous
    end

    assert_equal "finalized", @invoice.reload.status
  end
end
