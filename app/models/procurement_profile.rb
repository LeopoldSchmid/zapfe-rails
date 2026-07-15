class ProcurementProfile < ApplicationRecord
  RETURN_POLICIES = %w[unknown returnable non_returnable].freeze

  belongs_to :supplier, optional: true
  has_many :supplier_offerings, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: { scope: :supplier_id }
  validates :lead_time_days, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :return_policy, inclusion: { in: RETURN_POLICIES }
  validates :return_period_days, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validate :standard_profile_is_global

  scope :standard, -> { where(standard: true) }
  scope :custom, -> { where(standard: false) }

  private

  def standard_profile_is_global
    errors.add(:supplier, "darf bei einem Standardprofil nicht gesetzt sein") if standard? && supplier_id.present?
  end
end
