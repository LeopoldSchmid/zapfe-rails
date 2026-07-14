class Offers::CreateFromOrder
  def initialize(order:, admin_user:)
    @order = order
    @admin_user = admin_user
  end

  def call
    @order.with_lock do
      offer = @order.offers.create!(
        version: (@order.offers.maximum(:version) || 0) + 1,
        status: "draft",
        valid_until: Date.current + 14.days,
        recipient_name: @order.customer_name,
        recipient_email: @order.customer_email,
        recipient_address: @order.event_location
      )
      offer.activities.create!(admin_user: @admin_user, event_type: "created", message: "Angebotsentwurf v#{offer.version} erstellt")
      offer
    end
  end
end
