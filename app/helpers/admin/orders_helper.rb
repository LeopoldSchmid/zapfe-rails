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
end
