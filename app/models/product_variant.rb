class ProductVariant < ApplicationRecord
  MEASUREMENT_UNITS = %w[l ml Stk Tag].freeze

  belongs_to :product
  has_many :supplier_offerings, dependent: :destroy

  validates :sku, :size, :price, :unit, :sales_unit, presence: true
  validates :sku, uniqueness: true
  validates :unit, inclusion: { in: MEASUREMENT_UNITS }
  validates :size, uniqueness: { scope: [ :product_id, :unit ] }

  def measurement_label
    return label if label.present?

    "#{formatted_size} #{unit}"
  end

  def display_label
    "#{[ product.brand, product.name ].compact_blank.join(' ')} · #{measurement_label}"
  end

  def formatted_size
    size.to_d.frac.zero? ? size.to_i : size
  end
end
