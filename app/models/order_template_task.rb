class OrderTemplateTask < ApplicationRecord
  belongs_to :order_template
  belongs_to :assigned_admin_user, class_name: "AdminUser", optional: true

  validates :title, presence: true
  validates :relative_offset_days, numericality: { only_integer: true }, allow_nil: true
end
