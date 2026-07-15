class InvoiceLineItem < ApplicationRecord
  DISCOUNT_TYPES = OfferLineItem::DISCOUNT_TYPES

  belongs_to :invoice

  validates :description, :unit, presence: true
  validates :quantity, numericality: { greater_than: 0 }
  validates :net_unit_price, :discount_value, numericality: { greater_than_or_equal_to: 0 }
  validates :tax_rate, numericality: { greater_than_or_equal_to: 0 }
  validates :discount_type, inclusion: { in: DISCOUNT_TYPES }
  validate :discount_does_not_exceed_line_amount
  validate :invoice_must_be_editable
  validate :quantity_is_a_whole_number

  def gross_before_discount = quantity * net_unit_price
  def discount_amount
    case discount_type
    when "percent" then gross_before_discount * discount_value / 100
    when "fixed" then discount_value
    else BigDecimal("0")
    end
  end
  def net_total = gross_before_discount - discount_amount
  def tax_amount = net_total * tax_rate / 100
  def gross_total = net_total + tax_amount

  private

  def discount_does_not_exceed_line_amount
    errors.add(:discount_value, "darf den Positionsbetrag nicht übersteigen") if discount_amount > gross_before_discount
  end

  def invoice_must_be_editable
    errors.add(:base, "Positionen einer finalisierten Rechnung können nicht geändert werden") if invoice.present? && !invoice.editable?
  end

  def quantity_is_a_whole_number
    errors.add(:quantity, :not_an_integer) if quantity.present? && !quantity.to_d.frac.zero?
  end
end
