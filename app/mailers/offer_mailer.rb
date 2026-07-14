class OfferMailer < ApplicationMailer
  def offer(offer)
    @offer = offer
    attachments[@offer.document.filename.to_s] = {
      mime_type: @offer.document.content_type,
      content: @offer.document.download
    }

    mail(to: @offer.recipient_email, subject: "Angebot #{@offer.offer_number} von Zapfe")
  end
end
