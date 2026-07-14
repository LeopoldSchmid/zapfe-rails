class OfferLineItem < ApplicationRecord
  POSITION_TYPES = %w[product free].freeze
  DISCOUNT_TYPES = %w[none percent fixed].freeze

  belongs_to :offer
  belongs_to :product_variant, optional: true
  belongs_to :supplier_offering, optional: true

  validates :position_type, inclusion: { in: POSITION_TYPES }
  validates :discount_type, inclusion: { in: DISCOUNT_TYPES }
  validates :description, :unit, presence: true
  validates :quantity, numericality: { greater_than: 0 }
  validates :net_unit_price, :discount_value, numericality: { greater_than_or_equal_to: 0 }
  validates :tax_rate, numericality: { greater_than_or_equal_to: 0 }
  validates :direct_cost_unit, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validate :supplier_offering_matches_product_variant
  validate :discount_does_not_exceed_line_amount
  validate :offer_must_be_editable

  def gross_before_discount
    (quantity || BigDecimal("0")) * (net_unit_price || BigDecimal("0"))
  end

  def discount_amount
    case discount_type
    when "percent" then gross_before_discount * discount_value / 100
    when "fixed" then discount_value
    else BigDecimal("0")
    end
  end

  def net_total
    gross_before_discount - discount_amount
  end

  def tax_amount
    net_total * (tax_rate || BigDecimal("0")) / 100
  end

  def gross_total
    net_total + tax_amount
  end

  def direct_cost_total
    (quantity || BigDecimal("0")) * (direct_cost_unit || BigDecimal("0"))
  end

  private

  def supplier_offering_matches_product_variant
    return if supplier_offering.blank? || product_variant.blank? || supplier_offering.product_variant_id == product_variant_id

    errors.add(:supplier_offering, "muss zur Produktvariante passen")
  end

  def discount_does_not_exceed_line_amount
    return if gross_before_discount.blank? || discount_amount <= gross_before_discount

    errors.add(:discount_value, "darf den Positionsbetrag nicht übersteigen")
  end

  def offer_must_be_editable
    return if offer.blank? || offer.editable?

    errors.add(:base, "Positionen eines finalisierten Angebots können nicht geändert werden")
  end
end
