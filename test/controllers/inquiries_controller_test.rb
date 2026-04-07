require "test_helper"

class InquiriesControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper
  include ActionMailer::TestHelper

  setup do
    clear_enqueued_jobs
    clear_performed_jobs
    ActionMailer::Base.deliveries.clear
    Rails.cache.clear
    ApplicationController::RATE_LIMIT_STORE.clear
  end

  test "creates contact inquiry and enqueues both emails" do
    assert_difference("Inquiry.count", 1) do
      assert_enqueued_emails 2 do
        post inquiries_url, params: {
          inquiry: inquiry_params(
            source: "contact",
            first_name: "Max",
            last_name: "Mustermann",
            email: "max@example.com",
            phone: "+491234",
            privacy_accepted: "1"
          )
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
          inquiry: inquiry_params(
            source: "calculator",
            first_name: "Erika",
            last_name: "Musterfrau",
            email: "erika@example.com",
            phone: "+491235",
            rental_mode: "self",
            rental_days: "2",
            starts_on: "2026-03-10",
            ends_on: "2026-03-11",
            start_time: "18:00",
            end_time: "23:00",
            delivery_street: "Beispielweg 1",
            delivery_postcode: "79104",
            delivery_city: "Freiburg",
            bring_own_drinks: "0",
            glasses_requested: "1",
            selected_options: "Zapf Option",
            total_price: "350.00",
            pricing_snapshot: "{\"total\":350}",
            privacy_accepted: "1"
          )
        }
      end
    end

    inquiry = Inquiry.order(:created_at).last
    assert_equal "calculator", inquiry.source
    assert_equal BigDecimal("350.0"), inquiry.total_price
    assert_equal "self", inquiry.rental_mode
    assert_equal Date.new(2026, 3, 10), inquiry.starts_on
    assert_equal "Beispielweg 1", inquiry.delivery_street
    assert inquiry.glasses_requested
  end

  test "delivers both inquiry emails successfully" do
    perform_enqueued_jobs do
      assert_emails 2 do
        post inquiries_url, params: {
          inquiry: inquiry_params(
            source: "calculator",
            first_name: "Lisa",
            last_name: "Beispiel",
            email: "lisa@example.com",
            phone: "+491236",
            event_date: "2026-03-01",
            rental_mode: "zapf",
            rental_days: "2",
            starts_on: "2026-03-01",
            ends_on: "2026-03-02",
            start_time: "18:00",
            end_time: "23:00",
            selected_options: "Option: Zapf\nGetränk: Pils 30L x 1 = 80,00 €",
            total_price: "330.00",
            pricing_snapshot: "{\"total\":330}",
            privacy_accepted: "1"
          )
        }
      end
    end

    subjects = ActionMailer::Base.deliveries.last(2).map(&:subject)
    assert_includes subjects, "Deine Anfrage bei Zapfe!"
    assert_includes subjects, "Neue Preisrechner-Anfrage"
  end

  test "does not create inquiry when privacy is not accepted" do
    assert_no_difference("Inquiry.count") do
      assert_enqueued_emails 0 do
        post inquiries_url, params: {
          inquiry: inquiry_params(
            source: "contact",
            first_name: "Max",
            last_name: "Mustermann",
            email: "max@example.com",
            phone: "+491234",
            privacy_accepted: "0"
          )
        }
      end
    end

    assert_redirected_to root_url
    follow_redirect!
    assert_match(/muss akzeptiert werden/i, response.body)
  end

  test "rate limits inquiry creation bursts" do
    5.times do |index|
      post inquiries_url, params: {
        inquiry: inquiry_params(
          source: "contact",
          first_name: "Max#{index}",
          last_name: "Mustermann",
          email: "max#{index}@example.com",
          phone: "+491234#{index}",
          privacy_accepted: "1"
        )
      }
    end

    assert_no_difference("Inquiry.count") do
      post inquiries_url, params: {
        inquiry: inquiry_params(
          source: "contact",
          first_name: "Burst",
          last_name: "Blocked",
          email: "burst@example.com",
          phone: "+4912399",
          privacy_accepted: "1"
        )
      }
    end

    assert_redirected_to root_url
    follow_redirect!
    assert_match(/Zu viele Anfragen/i, response.body)
  end

  test "silently drops spam inquiry when honeypot is filled" do
    assert_no_difference("Inquiry.count") do
      assert_enqueued_emails 0 do
        post inquiries_url, params: {
          inquiry: inquiry_params(
            source: "contact",
            first_name: "Spam",
            last_name: "Bot",
            email: "spam@example.com",
            phone: "+491230",
            privacy_accepted: "1",
            website: "https://spam.invalid"
          )
        }
      end
    end

    assert_redirected_to root_url
    follow_redirect!
    assert_match "Vielen Dank", response.body
  end

  test "silently drops spam inquiry when submitted too quickly" do
    assert_no_difference("Inquiry.count") do
      assert_enqueued_emails 0 do
        post inquiries_url, params: {
          inquiry: inquiry_params(
            source: "contact",
            first_name: "Fast",
            last_name: "Bot",
            email: "fast@example.com",
            phone: "+491231",
            privacy_accepted: "1",
            submitted_at_token: inquiry_timestamp_token(Time.current)
          )
        }
      end
    end

    assert_redirected_to root_url
    follow_redirect!
    assert_match "Vielen Dank", response.body
  end

  private

  def inquiry_params(attributes)
    {
      submitted_at_token: inquiry_timestamp_token(10.seconds.ago)
    }.merge(attributes)
  end

  def inquiry_timestamp_token(time)
    Rails.application.message_verifier(:inquiry_form).generate(time.to_i, purpose: :inquiry_form)
  end
end
