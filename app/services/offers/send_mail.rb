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

      @offer.update!(status: "sent", sent_at: Time.current)
      OfferMailer.offer(@offer).deliver_later
      @offer.activities.create!(admin_user: @admin_user, event_type: "sent", message: "Angebot #{@offer.offer_number} an #{@offer.recipient_email} versendet")
      @offer
    end
  end
end
