class Supplier < ApplicationRecord
  has_many :procurement_profiles, dependent: :destroy
  has_many :supplier_offerings, dependent: :destroy

  accepts_nested_attributes_for :procurement_profiles, allow_destroy: true, reject_if: ->(attributes) { attributes["name"].blank? }

  scope :active, -> { where(active: true) }

  validates :name, presence: true, uniqueness: true
  validate :only_one_default_supplier

  private

  def only_one_default_supplier
    return unless default_supplier? && Supplier.where(default_supplier: true).where.not(id: id).exists?

    errors.add(:default_supplier, "kann nur für einen Händler gesetzt sein")
  end
end
