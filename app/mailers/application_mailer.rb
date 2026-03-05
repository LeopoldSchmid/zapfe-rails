class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAIL_FROM", "Zapfe <info@zapfe.jetzt>")
  layout "mailer"
end
