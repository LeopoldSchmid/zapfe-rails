require "test_helper"

class InquiryMailerTest < ActionMailer::TestCase
  test "customer confirmation has expected recipient, subject and summary" do
    inquiry = inquiries(:one)

    mail = InquiryMailer.customer_confirmation(inquiry)

    assert_equal [inquiry.email], mail.to
    assert_equal "Deine Anfrage bei Zapfe!", mail.subject
    assert_match inquiry.first_name, mail.body.encoded
    assert_match "Deine Anfrage im Überblick", mail.body.encoded
    assert_match "Geschätzter Gesamtpreis", mail.body.encoded
  end

  test "admin notification for calculator uses inbox, reply_to and calculator subject" do
    inquiry = inquiries(:two)

    original_inbox = ENV["ADMIN_INBOX_EMAIL"]
    ENV["ADMIN_INBOX_EMAIL"] = "admin@zapfe.test"
    begin
      mail = InquiryMailer.admin_notification(inquiry)

      assert_equal ["admin@zapfe.test"], mail.to
      assert_equal [inquiry.email], mail.reply_to
      assert_equal "Neue Preisrechner-Anfrage", mail.subject
      assert_match inquiry.last_name, mail.body.encoded
      assert_match "Anfrage-Details", mail.body.encoded
    ensure
      ENV["ADMIN_INBOX_EMAIL"] = original_inbox
    end
  end

  test "admin notification for contact uses contact subject" do
    inquiry = inquiries(:one)

    mail = InquiryMailer.admin_notification(inquiry)
    assert_equal "Neue Kontaktanfrage", mail.subject
  end
end
