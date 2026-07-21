class ProcurementPlan < ApplicationRecord
  include TransitionPolicy

  STATUSES = %w[planned requested confirmed done].freeze
  allows_status_transitions(
    "planned" => %w[requested confirmed],
    "requested" => %w[planned confirmed],
    "confirmed" => %w[requested done],
    "done" => %w[confirmed]
  )

  belongs_to :order
  belongs_to :offer, optional: true
  belongs_to :non_returnable_confirmed_by, class_name: "AdminUser", optional: true
  has_many :items, class_name: "ProcurementPlanItem", dependent: :destroy
  has_many :tasks, dependent: :nullify
  has_many_attached :attachments

  validates :status, inclusion: { in: STATUSES }
  validate :offer_belongs_to_order
  validate :attachments_are_safe

  def requires_non_returnable_confirmation?
    items.any?(&:non_returnable?)
  end

  private

  def offer_belongs_to_order
    return if offer.blank? || offer.order_id == order_id

    errors.add(:offer, "muss zum selben Auftrag gehören")
  end

  def attachments_are_safe
    attachments.each do |attachment|
      AttachmentSafety.validate(self, attachment)
    end
  end
end
