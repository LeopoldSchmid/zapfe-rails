class Resource < ApplicationRecord
  has_many :reservations, dependent: :restrict_with_error

  scope :active, -> { where(active: true) }

  validates :name, :resource_type, presence: true
  validates :name, uniqueness: true
end
