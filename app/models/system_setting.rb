class SystemSetting < ApplicationRecord
  validates :standard_tax_rate, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :internal_hourly_cost, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :payment_terms_days, numericality: { only_integer: true, greater_than: 0 }

  def self.current
    first_or_create!
  end
end
