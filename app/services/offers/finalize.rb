class Offers::Finalize
  class NotFinalizable < StandardError; end

  def initialize(offer:, admin_user:)
    @offer = offer
    @admin_user = admin_user
  end

  def call
    @offer.with_lock do
      raise NotFinalizable, "Nur Entwürfe können finalisiert werden." unless @offer.editable?
      raise NotFinalizable, "Ein Angebot benötigt mindestens eine Position." if @offer.line_items.empty?

      @offer.update!(
        offer_number: next_offer_number,
        status: "finalized",
        finalized_at: Time.current,
        document_snapshot: snapshot.to_json
      )
      Offers::PdfRenderer.new(offer: @offer).attach!
      @offer.activities.create!(admin_user: @admin_user, event_type: "finalized", message: "Angebot #{@offer.offer_number} finalisiert")
      @offer
    end
  end

  private

  def next_offer_number
    year = Date.current.year
    sequence = Offer.where("offer_number LIKE ?", "A-#{year}-%").count + 1
    format("A-%<year>d-%<sequence>06d", year: year, sequence: sequence)
  end

  def snapshot
    {
      recipient: {
        name: @offer.recipient_name,
        email: @offer.recipient_email,
        address: @offer.recipient_address
      },
      valid_until: @offer.valid_until.iso8601,
      totals: {
        subtotal_net: @offer.subtotal_net.to_s("F"),
        global_discount_type: @offer.global_discount_type,
        global_discount_value: @offer.global_discount_value.to_s("F"),
        global_discount_amount: @offer.global_discount_amount.to_s("F"),
        global_discount_reason: @offer.global_discount_reason,
        net: @offer.net_total.to_s("F"),
        tax: @offer.tax_total.to_s("F"),
        gross: @offer.gross_total.to_s("F"),
        direct_cost: @offer.direct_cost_total.to_s("F")
      },
      line_items: @offer.line_items.includes(supplier_offering: [ :supplier, :procurement_profile ]).order(:position, :created_at).map do |line_item|
        offering = line_item.supplier_offering
        {
          description: line_item.description,
          quantity: line_item.quantity.to_s("F"),
          unit: line_item.unit,
          net_unit_price: line_item.net_unit_price.to_s("F"),
          discount_type: line_item.discount_type,
          discount_value: line_item.discount_value.to_s("F"),
          discount_reason: line_item.discount_reason,
          tax_rate: line_item.tax_rate.to_s("F"),
          net_total: line_item.net_total.to_s("F"),
          tax_amount: line_item.tax_amount.to_s("F"),
          gross_total: line_item.gross_total.to_s("F"),
          supplier_offering_id: line_item.supplier_offering_id,
          direct_cost_unit: line_item.direct_cost_unit&.to_s("F"),
          procurement: offering && {
            supplier_name: offering.supplier.name,
            supplier_sku: offering.supplier_sku,
            profile_name: offering.procurement_profile.name,
            lead_time_days: offering.lead_time_days,
            return_policy: offering.return_policy,
            return_period_days: offering.return_period_days,
            order_by_on: offering.order_by_on(@offer.order.event_date)&.iso8601
          }
        }
      end,
      planned_time_entries: @offer.time_entries.where(entry_type: "planned").map do |entry|
        {
          category: entry.category,
          minutes: entry.minutes,
          hourly_cost: entry.hourly_cost.to_s("F"),
          cost_total: entry.cost_total.to_s("F"),
          note: entry.note
        }
      end
    }
  end
end
