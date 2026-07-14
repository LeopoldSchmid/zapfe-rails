class SystemSetting < ApplicationRecord
  validates :standard_tax_rate, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :internal_hourly_cost, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  def self.current
    first_or_create!
  end
end
