class Invoices::CreateFromOffer
  class NotCreatable < StandardError; end

  def initialize(offer:, admin_user:)
    @offer = offer
    @admin_user = admin_user
  end

  def call
    raise NotCreatable, "Eine Rechnung kann nur aus einem angenommenen Angebot erstellt werden." unless @offer.status == "accepted"

    Invoice.transaction do
      invoice = @offer.order.invoices.create!(
        offer: @offer,
        recipient_name: @offer.recipient_name,
        recipient_email: @offer.recipient_email,
        recipient_address: @offer.recipient_address,
        delivery_on: @offer.order.event_date,
        due_on: Date.current + SystemSetting.current.payment_terms_days.days,
        global_discount_type: @offer.global_discount_type,
        global_discount_value: @offer.global_discount_value,
        global_discount_reason: @offer.global_discount_reason,
        internal_note: @offer.internal_note
      )
      @offer.line_items.order(:position, :created_at).each do |line_item|
        invoice.line_items.create!(
          description: line_item.description,
          quantity: line_item.quantity,
          unit: line_item.unit,
          net_unit_price: line_item.net_unit_price,
          discount_type: line_item.discount_type,
          discount_value: line_item.discount_value,
          discount_reason: line_item.discount_reason,
          tax_rate: line_item.tax_rate,
          position: line_item.position
        )
      end
      invoice.activities.create!(admin_user: @admin_user, event_type: "created", message: "Rechnungsentwurf aus #{source_label} erstellt")
      invoice
    end
  end

  private

  def source_label
    @offer.offer_number.presence || "Angebotsentwurf v#{@offer.version}"
  end
end
