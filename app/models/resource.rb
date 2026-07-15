class Resource < ApplicationRecord
  has_many :reservations, dependent: :restrict_with_error
  has_many :offer_line_items, dependent: :restrict_with_error

  scope :active, -> { where(active: true) }

  validates :name, :resource_type, presence: true
  validates :name, uniqueness: true
  validates :rental_net_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :rental_unit, presence: true

  def rental_position_label
    rental_position_name.presence || "Miete #{name}"
  end
end
