class OfferMailer < ApplicationMailer
  def offer(offer, delivery_id: nil)
    @offer = offer
    attachments[@offer.document.filename.to_s] = {
      mime_type: @offer.document.content_type,
      content: @offer.document.download
    }

    headers["Message-ID"] = DocumentDelivery.find(delivery_id).stable_message_id if delivery_id
    mail(to: @offer.recipient_email, subject: "Angebot #{@offer.offer_number} von Zapfe")
  end
end
