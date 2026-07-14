class Tag < ApplicationRecord
  has_many :taggings, dependent: :destroy
  has_many :orders, through: :taggings, source: :taggable, source_type: "Order"
  has_many :order_templates, through: :taggings, source: :taggable, source_type: "OrderTemplate"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
