class SupplierPrice < ApplicationRecord
  belongs_to :supplier_offering

  before_validation :derive_net_purchase_price
  before_validation :derive_gross_purchase_price

  validates :purchase_price, numericality: { greater_than_or_equal_to: 0 }
  validates :gross_purchase_price, numericality: { greater_than_or_equal_to: 0 }
  validates :tax_rate, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :valid_from, presence: true, uniqueness: { scope: :supplier_offering_id }
  validate :valid_until_is_not_before_valid_from

  private

  def derive_net_purchase_price
    return if gross_purchase_price.blank? || tax_rate.blank?
    return unless will_save_change_to_gross_purchase_price? || will_save_change_to_tax_rate? || purchase_price.blank?

    self.purchase_price = (gross_purchase_price.to_d / (1 + tax_rate.to_d / 100)).round(2)
  end

  def derive_gross_purchase_price
    return if purchase_price.blank? || tax_rate.blank? || will_save_change_to_gross_purchase_price?
    return unless will_save_change_to_purchase_price? || gross_purchase_price.blank?

    self.gross_purchase_price = (purchase_price.to_d * (1 + tax_rate.to_d / 100)).round(2)
  end

  def valid_until_is_not_before_valid_from
    return if valid_until.blank? || valid_from.blank? || valid_until >= valid_from

    errors.add(:valid_until, "darf nicht vor dem Gültigkeitsbeginn liegen")
  end
end
