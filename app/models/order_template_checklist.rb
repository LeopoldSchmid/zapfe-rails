class OrderTemplateChecklist < ApplicationRecord
  belongs_to :order_template
  belongs_to :checklist_template
end
