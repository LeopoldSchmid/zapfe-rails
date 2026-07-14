class Offers::Resolve
  STATUSES = %w[accepted rejected expired].freeze

  class NotResolvable < StandardError; end

  def initialize(offer:, status:, admin_user:)
    @offer = offer
    @status = status
    @admin_user = admin_user
  end

  def call
    raise NotResolvable, "Ungültiger Angebotsstatus." unless STATUSES.include?(@status)

    @offer.with_lock do
      raise NotResolvable, "Nur finalisierte oder versendete Angebote können entschieden werden." unless %w[finalized sent].include?(@offer.status)

      @offer.update!(status: @status)
      @offer.order.update!(status: "confirmed") if @status == "accepted"
      label = { "accepted" => "angenommen", "rejected" => "abgelehnt", "expired" => "als abgelaufen markiert" }.fetch(@status)
      @offer.activities.create!(admin_user: @admin_user, event_type: @status, message: "Angebot #{@offer.offer_number} #{label}")
      @offer
    end
  end
end
