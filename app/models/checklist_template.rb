class ChecklistTemplate < ApplicationRecord
  SECTIONS = %w[packing setup cleaning].freeze

  has_many :items, class_name: "ChecklistTemplateItem", dependent: :destroy
  has_many :order_checklists, dependent: :nullify

  accepts_nested_attributes_for :items, allow_destroy: true, reject_if: ->(attributes) { attributes["title"].blank? }

  validates :name, :section, presence: true
  validates :section, inclusion: { in: SECTIONS }

  scope :active, -> { where(active: true) }
end
