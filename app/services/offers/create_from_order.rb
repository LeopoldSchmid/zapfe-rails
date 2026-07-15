class Offers::CreateFromOrder
  def initialize(order:, admin_user:)
    @order = order
    @admin_user = admin_user
  end

  def call
    @order.with_lock do
      offer = @order.offers.create!(
        version: (@order.offers.maximum(:version) || 0) + 1,
        status: "draft",
        valid_until: Date.current + 14.days,
        recipient_name: @order.customer_name,
        recipient_email: @order.customer_email,
        recipient_address: @order.event_location
      )
      offer.activities.create!(admin_user: @admin_user, event_type: "created", message: "Angebotsentwurf v#{offer.version} erstellt")
      @order.product_selections.includes(product_variant: :product).find_each do |selection|
        variant = selection.product_variant
        product = variant.product
        supplier_offering = SupplierOffering.active.joins(:supplier)
          .where(product_variant: variant)
          .order("suppliers.default_supplier DESC", "suppliers.name ASC")
          .first
        offer.line_items.create!(
          position_type: "product",
          product_variant: variant,
          description: "#{product.brand} #{product.name} · #{variant.size} l",
          quantity: selection.quantity,
          unit: selection.unit,
          supplier_offering: supplier_offering,
          net_unit_price: variant.price,
          direct_cost_unit: supplier_offering&.current_price&.purchase_price,
          tax_rate: SystemSetting.current.standard_tax_rate,
          discount_type: "none",
          discount_value: 0
        )
      end
      offer
    end
  end
end
