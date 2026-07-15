class ProcurementPlans::CreateFromOffer
  def initialize(offer:)
    @offer = offer
  end

  def call
    raise ActiveRecord::RecordInvalid, @offer if @offer.status.in?(%w[rejected expired])

    @offer.order.with_lock do
      plan = @offer.order.procurement_plans.create!(offer: @offer, status: "planned", order_by_on: nil)
      @offer.line_items.includes(:supplier_offering).each do |line_item|
        offering = line_item.supplier_offering
        plan.items.create!(
          offer_line_item: line_item,
          supplier_offering: offering,
          description: line_item.description,
          quantity: line_item.quantity,
          unit: line_item.unit,
          purchase_price: line_item.direct_cost_unit,
          lead_time_days: offering&.lead_time_days,
          return_policy: offering&.return_policy,
          return_period_days: offering&.return_period_days,
          order_by_on: @offer.order.event_date && offering && @offer.order.event_date - offering.lead_time_days.days
        )
      end
      plan.update!(order_by_on: plan.items.minimum(:order_by_on))
      create_ordering_task(plan) if plan.order_by_on.present?
      plan
    end
  end

  private

  def create_ordering_task(plan)
    offset = (plan.order_by_on - @offer.order.event_date).to_i
    plan.tasks.create!(
      order: @offer.order,
      assigned_admin_user: @offer.order.responsible_admin_user,
      title: "Beschaffung bestellen",
      details: "Bestellung für Beschaffungsplan vom #{I18n.l(plan.created_at.to_date)} auslösen.",
      status: "open",
      due_on: plan.order_by_on,
      relative_anchor: "event_date",
      relative_offset_days: offset
    )
  end
end
