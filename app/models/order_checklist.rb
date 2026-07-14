class OrderChecklist < ApplicationRecord
  STATUSES = %w[open completed].freeze

  belongs_to :order
  belongs_to :checklist_template, optional: true
  has_many :items, class_name: "OrderChecklistItem", dependent: :destroy

  validates :name, :section, presence: true
  validates :status, inclusion: { in: STATUSES }

  def refresh_status!
    update!(status: items.any? && items.all?(&:completed?) ? "completed" : "open")
  end
end
