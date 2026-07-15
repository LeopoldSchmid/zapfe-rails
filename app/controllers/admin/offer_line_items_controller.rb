class Admin::OfferLineItemsController < Admin::BaseController
  before_action :set_offer
  before_action :set_line_item, only: %i[update destroy]

  def create
    @line_item = @offer.line_items.build(line_item_params)
    populate_derived_fields(@line_item)

    if @line_item.save
      redirect_to admin_offer_path(@offer), notice: "Position hinzugefügt."
    else
      redirect_to admin_offer_path(@offer), alert: @line_item.errors.full_messages.to_sentence
    end
  end

  def update
    @line_item.assign_attributes(line_item_params)
    populate_derived_fields(@line_item)

    if @line_item.save
      redirect_to admin_offer_path(@offer), notice: "Position aktualisiert."
    else
      redirect_to admin_offer_path(@offer), alert: @line_item.errors.full_messages.to_sentence
    end
  end

  def destroy
    return redirect_to(admin_offer_path(@offer), alert: "Finalisierte Angebote können nicht mehr geändert werden.") unless @offer.editable?

    @line_item.destroy!
    redirect_to admin_offer_path(@offer), notice: "Position entfernt."
  end

  private

  def set_offer
    @offer = Offer.find(params[:offer_id])
  end

  def set_line_item
    @line_item = @offer.line_items.find(params[:id])
  end

  def line_item_params
    params.require(:offer_line_item).permit(
      :position_type, :product_variant_id, :supplier_offering_id, :resource_id, :description, :quantity, :unit,
      :net_unit_price, :discount_type, :discount_value, :discount_reason, :internal_note, :tax_rate, :direct_cost_unit
    )
  end

  def populate_derived_fields(line_item)
    if line_item.supplier_offering.present? && line_item.product_variant.blank?
      line_item.product_variant = line_item.supplier_offering.product_variant
    end

    if line_item.resource.present?
      line_item.product_variant = nil
      line_item.supplier_offering = nil
      line_item.position_type = "free"
      line_item.description = line_item.resource.rental_position_label if line_item.description.blank?
      line_item.unit = line_item.resource.rental_unit if line_item.unit.blank?
      line_item.net_unit_price = line_item.resource.rental_net_price if line_item.net_unit_price.blank? && line_item.resource.rental_net_price.present?
    end
    if line_item.product_variant.present? && line_item.description.blank?
      product = line_item.product_variant.product
      line_item.description = "#{product.brand} #{product.name} · #{line_item.product_variant.size} l"
      line_item.position_type = "product"
    end
    if line_item.product_variant.present? && (line_item.net_unit_price.nil? || line_item.net_unit_price.zero?)
      line_item.net_unit_price = line_item.product_variant.price
    end
    if line_item.product_variant.present? && line_item.supplier_offering.blank?
      line_item.supplier_offering = SupplierOffering.active.joins(:supplier).where(product_variant: line_item.product_variant).order("suppliers.default_supplier DESC", "suppliers.name ASC").first
    end
    if line_item.direct_cost_unit.blank? || line_item.will_save_change_to_supplier_offering_id?
      line_item.direct_cost_unit = line_item.supplier_offering&.current_price&.purchase_price
    end
  end
end
