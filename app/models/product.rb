class Product < ApplicationRecord
  belongs_to :category, optional: true
  has_many :product_variants, dependent: :destroy
  has_one_attached :image

  accepts_nested_attributes_for :product_variants, allow_destroy: true

  validates :article_number, :name, :brand, :kind, presence: true
  validates :article_number, uniqueness: true
end
