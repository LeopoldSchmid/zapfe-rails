class Invoices::SendMail
  class NotSendable < StandardError; end

  def initialize(invoice:, admin_user:)
    @invoice = invoice
    @admin_user = admin_user
  end

  def call
    @invoice.with_lock do
      raise NotSendable, CustomerDocumentDelivery::DISABLED_MESSAGE unless CustomerDocumentDelivery.enabled?
      raise NotSendable, "Nur finalisierte Rechnungen können versendet werden." unless @invoice.status == "finalized"
      raise NotSendable, "Für den Versand fehlt die Empfänger-E-Mail-Adresse." if @invoice.recipient_email.blank?
      raise NotSendable, "Für den Versand fehlt das Rechnungs-PDF." unless @invoice.document.attached?
      Invoices::DocumentIntegrity.verify!(@invoice, kind: :pdf)
      Invoices::DocumentIntegrity.verify!(@invoice, kind: :xml)

      delivery = CustomerDocuments::EnqueueDelivery.new(deliverable: @invoice, admin_user: @admin_user).call
      @invoice.activities.create!(admin_user: @admin_user, event_type: "delivery_queued", message: "Rechnung #{@invoice.invoice_number} für Versand an #{@invoice.recipient_email} eingereiht")
      delivery
    end
  rescue Invoices::DocumentIntegrity::IntegrityError => error
    raise NotSendable, error.message
  end
end
