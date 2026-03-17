class Product < ApplicationRecord
  belongs_to :category, optional: true
  has_many :product_variants, dependent: :destroy
  has_one_attached :image

  accepts_nested_attributes_for :product_variants, allow_destroy: true

  validates :article_number, :name, :brand, :kind, presence: true
  validates :article_number, uniqueness: true
  validates :featured_position, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true

  scope :with_catalog_includes, -> { includes(:category, :product_variants) }
  scope :featured_only, -> { where(featured: true) }
  scope :featured_first, lambda {
    order(Arel.sql(<<~SQL.squish))
      CASE WHEN products.featured THEN 0 ELSE 1 END ASC,
      CASE WHEN products.featured_position IS NULL THEN 1 ELSE 0 END ASC,
      products.featured_position ASC,
      products.brand ASC,
      products.name ASC
    SQL
  }
  scope :catalog_listing, -> { with_catalog_includes.featured_first }
  scope :catalog_featured_listing, -> { with_catalog_includes.featured_only.featured_first }

  def self.catalog_brands
    distinct.order(:brand).pluck(:brand).compact
  end

  def self.catalog_subcategories
    distinct.order(:subcategory).pluck(:subcategory).compact
  end

  def short_display_name
    display_name = name.to_s.squish
    display_name = subcategory.to_s.squish if display_name.blank?
    display_name = kind.to_s.squish if display_name.blank?
    brand_name = brand.to_s.squish

    return brand_name if display_name.blank?

    display_name
  end
end
