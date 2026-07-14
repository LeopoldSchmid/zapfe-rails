class Offers::Duplicate
  def initialize(offer:, admin_user:)
    @offer = offer
    @admin_user = admin_user
  end

  def call
    @offer.order.with_lock do
      duplicate = @offer.order.offers.create!(
        version: (@offer.order.offers.maximum(:version) || 0) + 1,
        status: "draft",
        valid_until: Date.current + 14.days,
        recipient_name: @offer.recipient_name,
        recipient_email: @offer.recipient_email,
        recipient_address: @offer.recipient_address,
        internal_note: @offer.internal_note
      )
      @offer.line_items.order(:position, :created_at).each do |line_item|
        duplicate.line_items.create!(line_item.attributes.except("id", "offer_id", "created_at", "updated_at"))
      end
      duplicate.activities.create!(admin_user: @admin_user, event_type: "created", message: "Angebotsentwurf v#{duplicate.version} aus v#{@offer.version} erstellt")
      duplicate
    end
  end
end
