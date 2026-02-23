class Category < ApplicationRecord
  has_many :products, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true
  validates :kind, presence: true
end
