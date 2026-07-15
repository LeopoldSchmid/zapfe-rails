class OrderTemplateTask < ApplicationRecord
  belongs_to :order_template
  belongs_to :assigned_admin_user, class_name: "AdminUser", optional: true

  validates :title, presence: true
  validates :relative_offset_days, numericality: { only_integer: true }, allow_nil: true

  before_validation :assign_position, on: :create

  private

  def assign_position
    self.position ||= order_template.template_tasks.maximum(:position).to_i + 1
  end
end
