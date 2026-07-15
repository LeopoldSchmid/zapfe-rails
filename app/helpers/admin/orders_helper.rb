module Admin::OrdersHelper
  ORDER_STATUS_LABELS = {
    "preparing" => "In Vorbereitung",
    "offered" => "Angeboten",
    "confirmed" => "Beauftragt",
    "in_progress" => "In Durchführung",
    "completed" => "Abgeschlossen",
    "cancelled" => "Storniert"
  }.freeze

  def order_status_label(status)
    ORDER_STATUS_LABELS.fetch(status)
  end

  def process_phase_completed?(order, phase)
    case phase.to_sym
    when :inquiry
      order.inquiry.present?
    when :order
      order.offers.exists?
    when :offer
      order.offers.where(status: %w[accepted rejected expired]).exists?
    when :procurement
      order.procurement_plans.where(status: "done").exists?
    when :execution
      order.status == "completed"
    when :invoice
      order.invoices.where(status: "paid").exists?
    else
      false
    end
  end

  def stepped_date_field(form, attribute, value: nil, class_name: "admin-field", **options)
    current_value = value || form.object.public_send(attribute).presence || Date.current

    content_tag(:div, class: "admin-date-stepper", data: { controller: "date-stepper" }) do
      safe_join([
        button_tag("−", type: "button", class: "admin-date-stepper-button", title: "Einen Tag früher", aria: { label: "Einen Tag früher" }, data: { action: "date-stepper#previous" }),
        form.date_field(attribute, **options.merge(value: current_value, class: class_name, data: { date_stepper_target: "input" })),
        button_tag("+", type: "button", class: "admin-date-stepper-button", title: "Einen Tag später", aria: { label: "Einen Tag später" }, data: { action: "date-stepper#next" })
      ])
    end
  end
end
