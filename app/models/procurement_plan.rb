class ProcurementPlan < ApplicationRecord
  STATUSES = %w[planned requested confirmed done].freeze

  belongs_to :order
  belongs_to :offer, optional: true
  has_many :items, class_name: "ProcurementPlanItem", dependent: :destroy
  has_many :tasks, dependent: :nullify

  validates :status, inclusion: { in: STATUSES }
  validate :offer_belongs_to_order

  private

  def offer_belongs_to_order
    return if offer.blank? || offer.order_id == order_id

    errors.add(:offer, "muss zum selben Auftrag gehören")
  end
end
