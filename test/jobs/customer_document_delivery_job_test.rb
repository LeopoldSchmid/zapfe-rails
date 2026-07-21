require "test_helper"
require "net/smtp"

class CustomerDocumentDeliveryJobTest < ActiveJob::TestCase
  setup do
    @admin = admin_users(:one)
    @invoice = Invoice.create!(
      order: orders(:from_inquiry), recipient_name: "Verein Freiburg",
      recipient_email: "rechnung@verein.example", recipient_address: "Musterstraße 1\n79100 Freiburg"
    )
    @invoice.line_items.create!(description: "Miete", quantity: 1, unit: "Tag", net_unit_price: 100, tax_rate: 19, discount_type: "none")
    Invoices::Finalize.new(invoice: @invoice, admin_user: @admin).call
    @delivery = CustomerDocuments::EnqueueDelivery.new(deliverable: @invoice, admin_user: @admin).call
    clear_enqueued_jobs
    ActionMailer::Base.deliveries.clear
  end

  test "marks the document sent only after successful mail handoff" do
    CustomerDocumentDeliveryJob.perform_now(@delivery)

    assert_equal "delivered", @delivery.reload.status
    assert_equal 1, @delivery.attempts
    assert_predicate @delivery, :provider_message_id?
    assert_equal "sent", @invoice.reload.status
    assert_predicate @invoice, :sent_at?
    assert_equal 1, ActionMailer::Base.deliveries.size
  end

  test "records a privacy-safe failure and leaves the document unsent for retry" do
    failing_mailer = Object.new
    failing_mailer.define_singleton_method(:deliver_now) { raise Net::SMTPServerBusy, "synthetic recipient detail" }
    job = CustomerDocumentDeliveryJob.new
    job.define_singleton_method(:mailer_for) { |_delivery| failing_mailer }

    assert_raises(Net::SMTPServerBusy) { job.perform(@delivery) }

    assert_equal "failed", @delivery.reload.status
    assert_equal "Net::SMTPServerBusy", @delivery.last_error_class
    assert_not_includes @delivery.last_error_digest, "recipient"
    assert_equal "finalized", @invoice.reload.status
    assert_nil @invoice.sent_at
  end

  test "is idempotent after delivery" do
    CustomerDocumentDeliveryJob.perform_now(@delivery)
    CustomerDocumentDeliveryJob.perform_now(@delivery)

    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_equal 1, @delivery.reload.attempts
    assert_equal 1, @invoice.activities.where(event_type: "delivered").count
  end
end
