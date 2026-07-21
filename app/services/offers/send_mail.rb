class Offers::SendMail
  class NotSendable < StandardError; end

  def initialize(offer:, admin_user:)
    @offer = offer
    @admin_user = admin_user
  end

  def call
    @offer.with_lock do
      raise NotSendable, CustomerDocumentDelivery::DISABLED_MESSAGE unless CustomerDocumentDelivery.enabled?
      raise NotSendable, "Nur finalisierte Angebote können versendet werden." unless @offer.status == "finalized"
      raise NotSendable, "Für den Versand fehlt die Empfänger-E-Mail-Adresse." if @offer.recipient_email.blank?
      raise NotSendable, "Für den Versand fehlt das Angebots-PDF." unless @offer.document.attached?

      delivery = CustomerDocuments::EnqueueDelivery.new(deliverable: @offer, admin_user: @admin_user).call
      @offer.activities.create!(admin_user: @admin_user, event_type: "delivery_queued", message: "Angebot #{@offer.offer_number} für Versand an #{@offer.recipient_email} eingereiht")
      delivery
    end
  end
end
