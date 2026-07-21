class CustomerDocumentDeliveryJob < ApplicationJob
  queue_as :mailers
  retry_on StandardError, wait: :polynomially_longer, attempts: 5

  def perform(delivery)
    delivery.with_lock do
      return if delivery.status == "delivered"

      delivery.update!(status: "delivering", attempts: delivery.attempts + 1, failed_at: nil)
    end

    message = mailer_for(delivery).deliver_now

    delivery.with_lock do
      delivery.update!(
        status: "delivered",
        delivered_at: Time.current,
        provider_message_id: message.message_id,
        last_error_class: nil,
        last_error_digest: nil
      )
      mark_deliverable_sent!(delivery)
    end
  rescue StandardError => error
    delivery&.update!(
      status: "failed",
      failed_at: Time.current,
      last_error_class: error.class.name,
      last_error_digest: Digest::SHA256.hexdigest(error.message.to_s)
    )
    raise
  end

  private

  def mailer_for(delivery)
    case delivery.deliverable
    when Invoice then InvoiceMailer.invoice(delivery.deliverable, delivery_id: delivery.id)
    when Offer then OfferMailer.offer(delivery.deliverable, delivery_id: delivery.id)
    else raise ArgumentError, "Nicht unterstützter Dokumenttyp"
    end
  end

  def mark_deliverable_sent!(delivery)
    document = delivery.deliverable
    document.update!(status: "sent", sent_at: delivery.delivered_at)
    document.activities.create!(
      admin_user: delivery.requested_by,
      event_type: "delivered",
      message: "#{document.model_name.human} #{document_identifier(document)} erfolgreich an #{delivery.recipient} übergeben"
    )
  end

  def document_identifier(document)
    document.respond_to?(:invoice_number) ? document.invoice_number : document.offer_number
  end
end
