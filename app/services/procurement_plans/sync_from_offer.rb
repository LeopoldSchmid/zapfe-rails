class ProcurementPlans::SyncFromOffer
  def initialize(plan:)
    @plan = plan
    @offer = plan.offer
  end

  def call
    return 0 if @offer.blank?

    added = 0
    @plan.with_lock do
      existing_line_item_ids = @plan.items.where.not(offer_line_item_id: nil).pluck(:offer_line_item_id)

      @offer.line_items.includes(:supplier_offering).where.not(id: existing_line_item_ids).find_each do |line_item|
        offering = line_item.supplier_offering
        @plan.items.create!(
          offer_line_item: line_item,
          supplier_offering: offering,
          description: line_item.description,
          quantity: line_item.quantity,
          unit: line_item.unit,
          purchase_price: line_item.direct_cost_unit,
          lead_time_days: offering&.lead_time_days,
          return_policy: offering&.return_policy,
          return_period_days: offering&.return_period_days,
          order_by_on: @plan.order.event_date && offering && @plan.order.event_date - offering.lead_time_days.days
        )
        added += 1
      end

      @plan.update!(order_by_on: @plan.items.minimum(:order_by_on)) if added.positive?
    end

    added
  end
end
