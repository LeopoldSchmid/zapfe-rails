class OrderTemplate < ApplicationRecord
  belongs_to :responsible_admin_user, class_name: "AdminUser", optional: true
  has_many :order_template_resources, dependent: :destroy
  has_many :resources, through: :order_template_resources
  has_many :template_tasks, class_name: "OrderTemplateTask", dependent: :destroy
  has_many :order_template_checklists, dependent: :destroy
  has_many :checklist_templates, through: :order_template_checklists
  has_many :taggings, as: :taggable, dependent: :destroy
  has_many :tags, through: :taggings

  accepts_nested_attributes_for :template_tasks, allow_destroy: true, reject_if: ->(attributes) { attributes["title"].blank? }

  validates :name, presence: true
  scope :active, -> { where(active: true) }

  def tag_names=(value)
    @tag_names = value
  end

  def tag_names
    @tag_names || tags.order(:name).pluck(:name).join(", ")
  end

  def persist_tags!
    names = tag_names.to_s.split(",").map { |name| name.strip.downcase }.reject(&:blank?).uniq
    self.tags = names.map { |name| Tag.find_or_create_by!(name: name) }
  end
end
