class ChecklistTemplateItem < ApplicationRecord
  belongs_to :checklist_template
  has_many :order_checklist_items, dependent: :nullify
  has_one_attached :attachment

  validates :title, presence: true
end
