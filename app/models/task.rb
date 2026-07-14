class Task < ApplicationRecord
  STATUSES = %w[open in_progress done].freeze
  RELATIVE_ANCHORS = %w[event_date].freeze

  belongs_to :order
  belongs_to :procurement_plan, optional: true
  belongs_to :assigned_admin_user, class_name: "AdminUser", optional: true

  validates :title, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :relative_anchor, inclusion: { in: RELATIVE_ANCHORS }, allow_blank: true
  validates :relative_offset_days, numericality: { only_integer: true }, allow_nil: true
  validate :relative_due_date_is_configured_consistently

  before_validation :set_completed_at
  before_validation :calculate_relative_due_on

  def relative?
    relative_anchor.present? && relative_offset_days.present?
  end

  def recalculate_due_on!
    return unless relative?

    calculate_relative_due_on
    save! if due_on_changed?
  end

  private

  def relative_due_date_is_configured_consistently
    return if relative_offset_days.blank?
    return if relative_anchor.present?

    errors.add(:base, "Relativer Anker und Abstand müssen zusammen angegeben werden")
  end

  def calculate_relative_due_on
    return unless relative_anchor == "event_date" && relative_offset_days.present? && order&.event_date.present?

    self.due_on = order.event_date + relative_offset_days.days
  end

  def set_completed_at
    self.completed_at = Time.current if status == "done" && completed_at.blank?
    self.completed_at = nil unless status == "done"
  end
end
