class BackfillDraftOfferLineItemPricing < ActiveRecord::Migration[8.1]
  def up
    OfferLineItem.joins(:offer).where(offers: { status: "draft" }, net_unit_price: 0).where.not(product_variant_id: nil).find_each do |line_item|
      variant = line_item.product_variant
      next if variant.price.to_d.zero?

      supplier_offering = SupplierOffering.active.joins(:supplier)
        .where(product_variant: variant)
        .order("suppliers.default_supplier DESC", "suppliers.name ASC")
        .first
      line_item.update_columns(
        net_unit_price: variant.price,
        supplier_offering_id: supplier_offering&.id,
        direct_cost_unit: supplier_offering&.current_price&.purchase_price,
        updated_at: Time.current
      )
    end
  end

  def down
  end
end
