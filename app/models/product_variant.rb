class ProductVariant < ApplicationRecord
  belongs_to :product
  has_many :supplier_offerings, dependent: :destroy

  validates :sku, :size, :price, presence: true
  validates :sku, uniqueness: true
  validates :size, uniqueness: { scope: :product_id }
end
