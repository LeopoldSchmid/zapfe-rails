class Inquiry < ApplicationRecord
  SOURCES = %w[contact calculator solutions events].freeze

  before_validation :normalize_structured_fields

  validates :source, inclusion: { in: SOURCES }
  validates :first_name, :last_name, :email, :phone, presence: true
  validates :privacy_accepted, acceptance: true
  validates :rental_mode, :starts_on, :ends_on, presence: true, if: :calculator?
  validates :rental_days, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true

  def calculator?
    source == "calculator"
  end

  def selected_option_lines
    selected_options.to_s.lines.map(&:strip).reject(&:blank?)
  end

  def delivery_address
    [delivery_street, delivery_postcode, delivery_city].filter_map(&:presence).join(", ")
  end

  def pricing_snapshot_data
    JSON.parse(pricing_snapshot.presence || "{}")
  rescue JSON::ParserError
    {}
  end

  def time_window
    return "" if start_time.blank? && end_time.blank?

    [start_time.presence, end_time.presence].compact.join(" bis ")
  end

  private

  def normalize_structured_fields
    snapshot = pricing_snapshot_data
    timing = snapshot.fetch("timing", {})
    delivery = snapshot.fetch("deliveryAddress", {})

    self.rental_mode ||= snapshot["rentalOption"].presence
    self.rental_days ||= snapshot["days"].presence
    self.starts_on ||= timing["startsOn"].presence
    self.ends_on ||= timing["endsOn"].presence
    self.start_time ||= timing["startTime"].presence
    self.end_time ||= timing["endTime"].presence
    self.delivery_street ||= delivery["street"].presence
    self.delivery_postcode ||= delivery["postcode"].presence
    self.delivery_city ||= delivery["city"].presence
    self.bring_own_drinks = snapshot["bringOwnDrinks"] if snapshot.key?("bringOwnDrinks")
    self.glasses_requested = snapshot["glassesRental"] if snapshot.key?("glassesRental")

    self.event_date ||= starts_on

    if starts_on.present? && ends_on.present?
      self.rental_days ||= [(ends_on - starts_on).to_i, 1].max
    end
  end
end
