class Inquiry < ApplicationRecord
  PRIVACY_NOTICE_VERSION = "2026-07-16"
  SOURCES = %w[contact calculator solutions events].freeze
  STATUSES = %w[new clarifying waiting_customer waiting_external closed discarded].freeze

  belongs_to :assigned_admin_user, class_name: "AdminUser", optional: true, inverse_of: :assigned_inquiries
  has_one :order, dependent: :restrict_with_error
  has_many :activities, as: :subject, dependent: :destroy
  has_many_attached :attachments

  validate :attachments_are_safe

  before_validation :normalize_structured_fields
  before_validation :record_privacy_notice_acknowledgement, if: :privacy_accepted?

  validates :source, inclusion: { in: SOURCES }
  validates :first_name, :last_name, :email, presence: true
  validates :privacy_accepted, acceptance: true
  validates :status, inclusion: { in: STATUSES }
  validates :rental_mode, :starts_on, :ends_on, presence: true, if: :calculator?
  validates :rental_days, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true

  def calculator?
    source == "calculator"
  end

  def selected_option_lines
    selected_options.to_s.lines.map(&:strip).reject(&:blank?)
  end

  def delivery_address
    [ delivery_street, delivery_postcode, delivery_city ].filter_map(&:presence).join(", ")
  end

  def pricing_snapshot_data
    JSON.parse(pricing_snapshot.presence || "{}")
  rescue JSON::ParserError
    {}
  end

  def time_window
    return "" if start_time.blank? && end_time.blank?

    [ start_time.presence, end_time.presence ].compact.join(" bis ")
  end

  def open?
    !%w[closed discarded].include?(status)
  end

  def archived?
    archived_at.present?
  end

  def customer_name
    [ first_name, last_name ].compact.join(" ")
  end

  private

  def normalize_structured_fields
    self.phone = phone.presence
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
      self.rental_days ||= [ (ends_on - starts_on).to_i, 1 ].max
    end
  end

  def record_privacy_notice_acknowledgement
    self.privacy_notice_version = PRIVACY_NOTICE_VERSION
    self.privacy_notice_acknowledged_at ||= Time.current
  end

  def attachments_are_safe
    attachments.each do |attachment|
      AttachmentSafety.validate(self, attachment)
    end
  end
end
