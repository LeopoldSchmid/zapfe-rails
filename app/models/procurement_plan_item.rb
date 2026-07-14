class ProcurementPlanItem < ApplicationRecord
  RETURN_POLICIES = ProcurementProfile::RETURN_POLICIES

  belongs_to :procurement_plan
  belongs_to :offer_line_item, optional: true
  belongs_to :supplier_offering, optional: true

  validates :description, :unit, presence: true
  validates :quantity, numericality: { greater_than: 0 }
  validates :purchase_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :lead_time_days, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :return_policy, inclusion: { in: RETURN_POLICIES }, allow_blank: true

  def non_returnable?
    return_policy == "non_returnable"
  end
end
