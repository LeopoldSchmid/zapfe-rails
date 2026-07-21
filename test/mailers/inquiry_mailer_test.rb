require "test_helper"

class InquiryMailerTest < ActionMailer::TestCase
  test "customer confirmation has expected recipient, subject and summary" do
    inquiry = inquiries(:one)

    mail = InquiryMailer.customer_confirmation(inquiry)

    assert_equal [inquiry.email], mail.to
    assert_equal "Deine Anfrage bei Zapfe!", mail.subject
    assert_match inquiry.first_name, mail.body.encoded
    assert_match "Deine Anfrage im Überblick", mail.body.encoded
    assert_match "Mietzeitraum", mail.body.encoded
    assert_match "Geschätzter Gesamtpreis", mail.body.encoded
  end

  test "customer confirmation includes the details of a contact inquiry" do
    inquiry = Inquiry.new(
      source: "contact",
      first_name: "Test",
      last_name: "Musterfrau",
      email: "test@example.com",
      event_type: "Hochzeit",
      guests: 80,
      message: "Wir möchten wissen, ob ihr am Samstag Zeit habt.",
      privacy_accepted: true
    )

    mail = InquiryMailer.customer_confirmation(inquiry)

    assert_match "Deine Anfrage im Überblick", mail.body.encoded
    assert_match "Art der Veranstaltung", mail.body.encoded
    assert_match "Hochzeit", mail.body.encoded
    assert_match "Gästezahl", mail.body.encoded
    assert_match "80", mail.body.encoded
    assert_match "Deine Nachricht", mail.body.encoded
    assert_match "Wir möchten wissen, ob ihr am Samstag Zeit habt.", mail.body.encoded
  end

  test "customer confirmation omits an empty summary" do
    inquiry = Inquiry.new(
      source: "contact",
      first_name: "Test",
      last_name: "Musterfrau",
      email: "test@example.com",
      privacy_accepted: true
    )

    mail = InquiryMailer.customer_confirmation(inquiry)

    assert_no_match "Deine Anfrage im Überblick", mail.body.encoded
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
      assert_match "Lieferadresse", mail.body.encoded
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
