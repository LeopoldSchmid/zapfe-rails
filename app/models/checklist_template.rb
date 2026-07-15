class ChecklistTemplate < ApplicationRecord
  SECTION_LABELS = {
    "organisation" => "Organisation",
    "packing" => "Packen",
    "setup" => "Aufbau",
    "cleaning" => "Reinigung"
  }.freeze

  has_many :items, class_name: "ChecklistTemplateItem", dependent: :destroy
  has_many :order_checklists, dependent: :nullify

  accepts_nested_attributes_for :items, allow_destroy: true, reject_if: ->(attributes) { attributes["title"].blank? }

  before_validation :normalize_section

  validates :name, :section, presence: true

  scope :active, -> { where(active: true) }

  def section_label
    SECTION_LABELS.fetch(section, section.to_s.tr("_", " ").capitalize)
  end

  private

  def normalize_section
    self.section = section.to_s.strip.downcase.tr(" ", "_").presence
  end
end
