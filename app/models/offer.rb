class Offer < ApplicationRecord
  STATUSES = %w[draft finalized sent accepted rejected expired].freeze
  DISCOUNT_TYPES = OfferLineItem::DISCOUNT_TYPES

  belongs_to :order
  has_many :line_items, class_name: "OfferLineItem", dependent: :destroy
  has_many :activities, as: :subject, dependent: :destroy
  has_many :time_entries, dependent: :nullify
  has_many :reservations, dependent: :nullify
  has_many :procurement_plans, dependent: :nullify
  has_one_attached :document

  validates :version, numericality: { only_integer: true, greater_than: 0 }, uniqueness: { scope: :order_id }
  validates :status, inclusion: { in: STATUSES }
  validates :recipient_name, :valid_until, presence: true
  validates :global_discount_type, inclusion: { in: DISCOUNT_TYPES }
  validates :global_discount_value, numericality: { greater_than_or_equal_to: 0 }
  validate :global_discount_does_not_exceed_subtotal
  validate :cannot_change_finalized_offer, on: :update

  def editable?
    status == "draft"
  end

  def net_total
    subtotal_net - global_discount_amount
  end

  def tax_total
    return BigDecimal("0") if subtotal_net.zero?

    line_items.sum do |line_item|
      line_item.tax_amount - global_discount_amount * (line_item.net_total / subtotal_net) * line_item.tax_rate / 100
    end
  end

  def gross_total
    net_total + tax_total
  end

  def direct_cost_total
    line_items.sum(&:direct_cost_total) + planned_time_cost_total
  end

  def contribution_margin
    net_total - direct_cost_total
  end

  def contribution_margin_percent
    return BigDecimal("0") if net_total.zero?

    contribution_margin / net_total * 100
  end

  def subtotal_net
    line_items.sum(&:net_total)
  end

  def planned_time_cost_total
    time_entries.where(entry_type: "planned").sum do |entry|
      entry.cost_total
    end
  end

  def global_discount_amount
    case global_discount_type
    when "percent" then subtotal_net * global_discount_value / 100
    when "fixed" then global_discount_value
    else BigDecimal("0")
    end
  end

  def document_snapshot_data
    JSON.parse(document_snapshot.presence || "{}")
  rescue JSON::ParserError
    {}
  end

  private

  def cannot_change_finalized_offer
    return if status_in_database == "draft" || changes_to_save.except("updated_at").empty?
    return if %w[finalized sent].include?(status_in_database) && %w[sent accepted rejected expired].include?(status) && changes_to_save.except("status", "sent_at", "updated_at").empty?

    errors.add(:base, "Finalisierte Angebote können nicht mehr geändert werden. Bitte eine neue Version erstellen.")
  end

  def global_discount_does_not_exceed_subtotal
    return if global_discount_amount <= subtotal_net

    errors.add(:global_discount_value, "darf die Netto-Zwischensumme nicht übersteigen")
  end
end
