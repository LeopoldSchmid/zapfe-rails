require "test_helper"

class InquiriesControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper
  include ActionMailer::TestHelper

  setup do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  test "creates contact inquiry and enqueues both emails" do
    assert_difference("Inquiry.count", 1) do
      assert_enqueued_emails 2 do
        post inquiries_url, params: {
          inquiry: {
            source: "contact",
            first_name: "Max",
            last_name: "Mustermann",
            email: "max@example.com",
            phone: "+491234",
            privacy_accepted: "1"
          }
        }
      end
    end

    assert_redirected_to root_url
    follow_redirect!
    assert_match "Vielen Dank", response.body
  end

  test "creates calculator inquiry with pricing fields and enqueues both emails" do
    assert_difference("Inquiry.count", 1) do
      assert_enqueued_emails 2 do
        post inquiries_url, params: {
          inquiry: {
            source: "calculator",
            first_name: "Erika",
            last_name: "Musterfrau",
            email: "erika@example.com",
            phone: "+491235",
            selected_options: "Zapf Option",
            total_price: "350.00",
            pricing_snapshot: "{\"total\":350}",
            privacy_accepted: "1"
          }
        }
      end
    end

    inquiry = Inquiry.order(:created_at).last
    assert_equal "calculator", inquiry.source
    assert_equal BigDecimal("350.0"), inquiry.total_price
  end

  test "does not create inquiry when privacy is not accepted" do
    assert_no_difference("Inquiry.count") do
      assert_enqueued_emails 0 do
        post inquiries_url, params: {
          inquiry: {
            source: "contact",
            first_name: "Max",
            last_name: "Mustermann",
            email: "max@example.com",
            phone: "+491234",
            privacy_accepted: "0"
          }
        }
      end
    end

    assert_redirected_to root_url
    follow_redirect!
    assert_match(/muss akzeptiert werden/i, response.body)
  end
end
