class TimeEntry < ApplicationRecord
  ENTRY_TYPES = %w[planned actual].freeze
  CATEGORIES = %w[organisation execution].freeze

  belongs_to :order
  belongs_to :offer, optional: true
  belongs_to :admin_user, optional: true

  validates :entry_type, inclusion: { in: ENTRY_TYPES }
  validates :category, inclusion: { in: CATEGORIES }
  validates :minutes, numericality: { only_integer: true, greater_than: 0 }
  validates :hourly_cost, numericality: { greater_than_or_equal_to: 0 }
  validate :offer_belongs_to_order

  def cost_total
    BigDecimal(minutes.to_s) / 60 * hourly_cost
  end

  private

  def offer_belongs_to_order
    return if offer.blank? || order.blank? || offer.order_id == order_id

    errors.add(:offer, "muss zum selben Auftrag gehören")
  end
end
