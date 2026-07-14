require "test_helper"

class Offers::SendMailTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  include ActionMailer::TestHelper

  setup do
    clear_enqueued_jobs
    @offer = Offer.create!(order: orders(:from_inquiry), version: 1, valid_until: Date.current + 14.days, recipient_name: "Max Mustermann", recipient_email: "max@example.com")
    @offer.line_items.create!(description: "Miete", quantity: 1, unit: "Tag", net_unit_price: 100, tax_rate: 19)
    Offers::Finalize.new(offer: @offer, admin_user: admin_users(:one)).call
  end

  teardown do
    clear_enqueued_jobs
  end

  test "queues the final PDF for delivery and records the sent state" do
    assert_enqueued_emails 1 do
      Offers::SendMail.new(offer: @offer, admin_user: admin_users(:one)).call
    end

    @offer.reload
    assert_equal "sent", @offer.status
    assert_not_nil @offer.sent_at
    assert_match(/versendet/, @offer.activities.last.message)
  end
end
