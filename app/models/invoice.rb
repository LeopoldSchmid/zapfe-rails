class Invoice < ApplicationRecord
  include TransitionPolicy

  STATUSES = %w[draft finalized sent paid cancelled overdue].freeze
  allows_status_transitions(
    "draft" => %w[finalized],
    "finalized" => %w[sent paid cancelled overdue],
    "sent" => %w[paid cancelled overdue],
    "overdue" => %w[paid cancelled],
    "paid" => [], "cancelled" => []
  )
  INVOICE_TYPES = %w[invoice credit_note correction].freeze
  DISCOUNT_TYPES = OfferLineItem::DISCOUNT_TYPES

  belongs_to :order
  belongs_to :offer, optional: true
  belongs_to :correction_of, class_name: "Invoice", optional: true
  has_many :corrections, class_name: "Invoice", foreign_key: :correction_of_id, dependent: :restrict_with_error
  has_many :line_items, class_name: "InvoiceLineItem", dependent: :destroy
  has_many :activities, as: :subject, dependent: :destroy
  has_one_attached :document
  has_one_attached :e_invoice

  validates :status, inclusion: { in: STATUSES }
  validates :invoice_type, inclusion: { in: INVOICE_TYPES }
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
  def tax_breakdown
    return [] if subtotal_net.zero?

    line_items.group_by(&:tax_rate).map do |rate, items|
      group_net = items.sum(&:net_total)
      discount_share = global_discount_amount * group_net / subtotal_net
      taxable_basis = (group_net - discount_share).round(2)
      { rate: rate.to_d, allowance_amount: discount_share.round(2), taxable_basis: taxable_basis, tax_amount: (taxable_basis * rate / 100).round(2) }
    end.sort_by { |entry| entry.fetch(:rate) }
  end
  def tax_total = tax_breakdown.sum { |entry| entry.fetch(:tax_amount) }
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
