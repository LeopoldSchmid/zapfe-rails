class OrderProductSelection < ApplicationRecord
  belongs_to :order
  belongs_to :product_variant

  validates :quantity, numericality: { greater_than: 0 }
  validates :unit, presence: true
end
