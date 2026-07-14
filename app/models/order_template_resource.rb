class OrderTemplateResource < ApplicationRecord
  belongs_to :order_template
  belongs_to :resource
end
