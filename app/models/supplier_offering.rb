class SupplierOffering < ApplicationRecord
  RETURN_POLICIES = ProcurementProfile::RETURN_POLICIES

  belongs_to :supplier
  belongs_to :product_variant
  belongs_to :procurement_profile
  has_many :supplier_prices, dependent: :destroy

  accepts_nested_attributes_for :supplier_prices, reject_if: ->(attributes) { attributes["purchase_price"].blank? }

  scope :active, -> { where(active: true) }

  validates :product_variant_id, uniqueness: { scope: :supplier_id }
  validates :lead_time_days_override, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :return_policy_override, inclusion: { in: RETURN_POLICIES }, allow_blank: true
  validates :return_period_days_override, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validate :profile_belongs_to_supplier

  def lead_time_days
    lead_time_days_override || procurement_profile.lead_time_days
  end

  def return_policy
    return_policy_override.presence || procurement_profile.return_policy
  end

  def return_period_days
    return_period_days_override || procurement_profile.return_period_days
  end

  def current_price(on: Date.current)
    supplier_prices.where("valid_from <= ?", on).where("valid_until IS NULL OR valid_until >= ?", on).order(valid_from: :desc).first
  end

  def order_by_on(event_date)
    event_date && event_date - lead_time_days.days
  end

  def procurement_overdue?(event_date, on: Date.current)
    deadline = order_by_on(event_date)
    deadline.present? && deadline < on
  end

  private

  def profile_belongs_to_supplier
    return if procurement_profile.blank? || supplier.blank? || procurement_profile.supplier_id.blank? || procurement_profile.supplier_id == supplier_id

    errors.add(:procurement_profile, "muss zum selben Händler gehören")
  end
end
