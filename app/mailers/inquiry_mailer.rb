class InquiryMailer < ApplicationMailer
  default from: ENV.fetch("MAIL_FROM", "Zapfe <info@zapfe.jetzt>")

  def customer_confirmation(inquiry)
    @inquiry = inquiry
    mail(to: @inquiry.email, subject: "Deine Anfrage bei Zapfe")
  end

  def admin_notification(inquiry)
    @inquiry = inquiry
    admin_email = ENV.fetch("ADMIN_INBOX_EMAIL", "info@zapfe.jetzt")
    mail(to: admin_email, reply_to: @inquiry.email, subject: "Neue Anfrage über #{inquiry.source}")
  end
end
