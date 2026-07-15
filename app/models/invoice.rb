class Invoice < ApplicationRecord
  STATUSES = %w[draft finalized sent paid cancelled overdue].freeze
  DISCOUNT_TYPES = OfferLineItem::DISCOUNT_TYPES

  belongs_to :order
  belongs_to :offer, optional: true
  has_many :line_items, class_name: "InvoiceLineItem", dependent: :destroy
  has_many :activities, as: :subject, dependent: :destroy
  has_one_attached :document

  validates :status, inclusion: { in: STATUSES }
  validates :recipient_name, presence: true
  validates :global_discount_type, inclusion: { in: DISCOUNT_TYPES }
  validates :global_discount_value, numericality: { greater_than_or_equal_to: 0 }
  validate :global_discount_does_not_exceed_subtotal
  validate :cannot_change_finalized_invoice, on: :update

  def editable?
    status == "draft"
  end

  def subtotal_net = line_items.sum(&:net_total)
  def global_discount_amount
    case global_discount_type
    when "percent" then subtotal_net * global_discount_value / 100
    when "fixed" then global_discount_value
    else BigDecimal("0")
    end
  end
  def net_total = subtotal_net - global_discount_amount
  def tax_total
    return BigDecimal("0") if subtotal_net.zero?

    line_items.sum { |line_item| line_item.tax_amount - global_discount_amount * (line_item.net_total / subtotal_net) * line_item.tax_rate / 100 }
  end
  def gross_total = net_total + tax_total
  def document_snapshot_data = JSON.parse(document_snapshot.presence || "{}")

  private

  def global_discount_does_not_exceed_subtotal
    errors.add(:global_discount_value, "darf die Netto-Zwischensumme nicht übersteigen") if global_discount_amount > subtotal_net
  end

  def cannot_change_finalized_invoice
    return if status_in_database == "draft" || changes_to_save.except("updated_at").empty?
    return if %w[finalized sent overdue].include?(status_in_database) && %w[sent paid overdue cancelled].include?(status) && changes_to_save.except("status", "sent_at", "paid_at", "cancelled_at", "updated_at").empty?

    errors.add(:base, "Finalisierte Rechnungen können nicht mehr geändert werden.")
  end
end
