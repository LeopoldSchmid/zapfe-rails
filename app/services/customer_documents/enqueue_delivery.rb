module CustomerDocuments
  class EnqueueDelivery
    def initialize(deliverable:, admin_user:)
      @deliverable = deliverable
      @admin_user = admin_user
    end

    def call
      delivery = DocumentDelivery.find_or_initialize_by(idempotency_key: idempotency_key)
      if delivery.new_record?
        delivery.assign_attributes(
          deliverable: @deliverable,
          requested_by: @admin_user,
          recipient: @deliverable.recipient_email,
          queued_at: Time.current,
          status: "queued"
        )
        delivery.save!
      end

      CustomerDocumentDeliveryJob.perform_later(delivery) unless delivery.status.in?(%w[delivering delivered])
      delivery
    end

    private

    def idempotency_key
      digest = if @deliverable.is_a?(Invoice)
        [ @deliverable.document_sha256, @deliverable.e_invoice_sha256 ].join(":")
      else
        Digest::SHA256.hexdigest(@deliverable.document.download)
      end
      "#{@deliverable.model_name.singular}:#{@deliverable.id}:#{digest}"
    end
  end
end
