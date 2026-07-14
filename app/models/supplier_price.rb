class SupplierPrice < ApplicationRecord
  belongs_to :supplier_offering

  validates :purchase_price, numericality: { greater_than_or_equal_to: 0 }
  validates :valid_from, presence: true, uniqueness: { scope: :supplier_offering_id }
  validate :valid_until_is_not_before_valid_from

  private

  def valid_until_is_not_before_valid_from
    return if valid_until.blank? || valid_from.blank? || valid_until >= valid_from

    errors.add(:valid_until, "darf nicht vor dem Gültigkeitsbeginn liegen")
  end
end
