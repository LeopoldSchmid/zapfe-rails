class ProductVariant < ApplicationRecord
  belongs_to :product

  validates :sku, :size, :price, presence: true
  validates :sku, uniqueness: true
  validates :size, uniqueness: { scope: :product_id }
end
