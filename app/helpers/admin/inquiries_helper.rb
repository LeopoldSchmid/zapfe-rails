module Admin::InquiriesHelper
  INQUIRY_STATUS_LABELS = {
    "new" => "Neu",
    "clarifying" => "In Klärung",
    "waiting_customer" => "Wartet auf Kunde",
    "waiting_external" => "Wartet extern",
    "closed" => "Abgeschlossen",
    "discarded" => "Verworfen"
  }.freeze

  def inquiry_status_label(status)
    INQUIRY_STATUS_LABELS.fetch(status)
  end
end
