class OrderChecklistItem < ApplicationRecord
  belongs_to :order_checklist
  belongs_to :checklist_template_item, optional: true
  has_one_attached :attachment

  before_validation :set_completed_at

  validates :title, presence: true

  private

  def set_completed_at
    self.completed_at = Time.current if completed? && completed_at.blank?
    self.completed_at = nil unless completed?
  end
end
