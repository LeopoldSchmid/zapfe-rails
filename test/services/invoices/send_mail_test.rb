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
    assert_enqueued_with(job: ActionMailer::MailDeliveryJob) do
      Invoices::SendMail.new(invoice: @invoice, admin_user: @admin).call
    end

    assert_equal "sent", @invoice.reload.status
    assert_equal "sent", @invoice.activities.order(:created_at).last.event_type
  end
end
