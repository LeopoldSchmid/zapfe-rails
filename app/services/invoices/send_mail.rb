class Invoices::SendMail
  class NotSendable < StandardError; end

  def initialize(invoice:, admin_user:)
    @invoice = invoice
    @admin_user = admin_user
  end

  def call
    @invoice.with_lock do
      raise NotSendable, "Nur finalisierte Rechnungen können versendet werden." unless @invoice.status == "finalized"
      raise NotSendable, "Für den Versand fehlt die Empfänger-E-Mail-Adresse." if @invoice.recipient_email.blank?
      raise NotSendable, "Für den Versand fehlt das Rechnungs-PDF." unless @invoice.document.attached?

      @invoice.update!(status: "sent", sent_at: Time.current)
      InvoiceMailer.invoice(@invoice).deliver_later
      @invoice.activities.create!(admin_user: @admin_user, event_type: "sent", message: "Rechnung #{@invoice.invoice_number} an #{@invoice.recipient_email} versendet")
      @invoice
    end
  end
end
