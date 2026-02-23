require "test_helper"

class InquiryMailerTest < ActionMailer::TestCase
  test "customer confirmation has expected recipient and subject" do
    inquiry = inquiries(:one)

    mail = InquiryMailer.customer_confirmation(inquiry)

    assert_equal [inquiry.email], mail.to
    assert_equal "Deine Anfrage bei Zapfe", mail.subject
    assert_match inquiry.first_name, mail.body.encoded
  end

  test "admin notification uses inbox and reply_to" do
    inquiry = inquiries(:two)

    original_inbox = ENV["ADMIN_INBOX_EMAIL"]
    ENV["ADMIN_INBOX_EMAIL"] = "admin@zapfe.test"
    begin
      mail = InquiryMailer.admin_notification(inquiry)

      assert_equal ["admin@zapfe.test"], mail.to
      assert_equal [inquiry.email], mail.reply_to
      assert_match "Neue Anfrage", mail.subject
      assert_match inquiry.last_name, mail.body.encoded
    ensure
      ENV["ADMIN_INBOX_EMAIL"] = original_inbox
    end
  end
end
