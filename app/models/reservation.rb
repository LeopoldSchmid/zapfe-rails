class Reservation < ApplicationRecord
  STATUSES = %w[requested reserved].freeze
  belongs_to :resource
  belongs_to :order
  belongs_to :offer, optional: true

  validates :starts_at, :ends_at, presence: true
  validates :status, inclusion: { in: STATUSES }
  validate :ends_after_start
  validate :resource_is_available
  validate :offer_belongs_to_order

  def overlaps?(other)
    starts_at < other.ends_at && ends_at > other.starts_at
  end

  def requested?
    status == "requested"
  end

  def reserved?
    status == "reserved"
  end

  private

  def ends_after_start
    return if starts_at.blank? || ends_at.blank? || ends_at > starts_at

    errors.add(:ends_at, "muss nach dem Beginn liegen")
  end

  def resource_is_available
    return if resource.blank? || starts_at.blank? || ends_at.blank?

    return unless reserved?

    overlap = resource.reservations.where(status: "reserved").where.not(id: id).where("starts_at < ? AND ends_at > ?", ends_at, starts_at).exists?
    errors.add(:resource, "ist in diesem Zeitraum bereits reserviert") if overlap
  end

  def offer_belongs_to_order
    return if offer.blank? || order.blank? || offer.order_id == order_id

    errors.add(:offer, "muss zum selben Auftrag gehören")
  end

end
