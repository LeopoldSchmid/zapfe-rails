class ProcurementProfile < ApplicationRecord
  RETURN_POLICIES = %w[unknown returnable non_returnable].freeze

  belongs_to :supplier
  has_many :supplier_offerings, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: { scope: :supplier_id }
  validates :lead_time_days, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :return_policy, inclusion: { in: RETURN_POLICIES }
end
