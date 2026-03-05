class Product < ApplicationRecord
  belongs_to :category, optional: true
  has_many :product_variants, dependent: :destroy
  has_one_attached :image

  accepts_nested_attributes_for :product_variants, allow_destroy: true

  validates :article_number, :name, :brand, :kind, presence: true
  validates :article_number, uniqueness: true

  scope :catalog_listing, -> { includes(:category, :product_variants).order(:brand, :name) }

  def self.catalog_brands
    distinct.order(:brand).pluck(:brand).compact
  end

  def self.catalog_subcategories
    distinct.order(:subcategory).pluck(:subcategory).compact
  end
end
