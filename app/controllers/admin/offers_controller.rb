class Admin::OffersController < Admin::BaseController
  before_action :set_offer, only: %i[show update finalize duplicate document send_mail resolve position_options supplier_options]

  def index
    @order = Order.includes(:responsible_admin_user, :inquiry).find(params[:order_id])
  end

  def create
    order = Order.find(params[:order_id])
    offer = Offers::CreateFromOrder.new(order: order, admin_user: current_admin_user).call
    redirect_to admin_offer_path(offer), notice: "Angebotsentwurf erstellt."
  end

  def show
    prepare_show
  end

  def position_options
    render json: Resource.active.order(:resource_type, :name).map { |resource|
      { id: resource.id, label: "#{resource.resource_type} · #{resource.rental_position_label}", price: resource.rental_net_price, unit: resource.rental_unit }
    }
  end

  def supplier_options
    product_variant = ProductVariant.find(params.require(:product_variant_id))
    offerings = SupplierOffering.active.includes(:supplier).where(product_variant: product_variant).order("suppliers.default_supplier DESC", "suppliers.name ASC")
    render json: {
      net_unit_price: product_variant.price,
      offerings: offerings.map { |offering|
        { id: offering.id, label: "#{offering.supplier.name} · #{helpers.number_to_currency(offering.current_price&.purchase_price || 0, unit: "€", format: "%n %u")} · #{offering.lead_time_days} Tage", preferred: offering.supplier.default_supplier? }
      }
    }
  end

  def update
    if @offer.update(offer_params)
      redirect_to admin_offer_path(@offer), notice: "Angebotsdaten aktualisiert."
    else
      prepare_show
      render :show, status: :unprocessable_entity
    end
  end

  def finalize
    Offers::Finalize.new(offer: @offer, admin_user: current_admin_user).call
    redirect_to admin_offer_path(@offer), notice: "Angebot #{@offer.offer_number} finalisiert."
  rescue Offers::Finalize::NotFinalizable => error
    redirect_to admin_offer_path(@offer), alert: error.message
  end

  def duplicate
    duplicate = Offers::Duplicate.new(offer: @offer, admin_user: current_admin_user).call
    redirect_to admin_offer_path(duplicate), notice: "Neue Angebotsversion erstellt."
  end

  def document
    return redirect_to(admin_offer_path(@offer), alert: "Für diesen Entwurf gibt es noch kein PDF.") unless @offer.document.attached?

    send_data @offer.document.download, filename: @offer.document.filename.to_s, type: "application/pdf", disposition: "attachment"
  end

  def send_mail
    Offers::SendMail.new(offer: @offer, admin_user: current_admin_user).call
    redirect_to admin_offer_path(@offer), notice: "Angebot wurde zum Versand eingeplant."
  rescue Offers::SendMail::NotSendable => error
    redirect_to admin_offer_path(@offer), alert: error.message
  end

  def resolve
    Offers::Resolve.new(offer: @offer, status: params.require(:status), admin_user: current_admin_user).call
    redirect_to admin_offer_path(@offer), notice: "Angebotsstatus aktualisiert."
  rescue Offers::Resolve::NotResolvable => error
    redirect_to admin_offer_path(@offer), alert: error.message
  end

  private

  def set_offer
    @offer = Offer.includes(line_items: [ :product_variant, :supplier_offering ]).find(params[:id])
  end

  def offer_params
    params.require(:offer).permit(:recipient_name, :recipient_email, :recipient_address, :valid_until, :internal_note, :global_discount_type, :global_discount_value, :global_discount_reason)
  end

  def prepare_show
    @product_variants = ProductVariant.includes(:product).order("products.brand", "products.name", :size).references(:product)
    @resources = Resource.active.order(:resource_type, :name)
    @supplier_offerings = SupplierOffering.active.includes(:supplier, product_variant: :product).references(:supplier)
    @supplier_offerings_by_variant = @supplier_offerings.group_by(&:product_variant_id).transform_values do |offerings|
      offerings.sort_by { |offering| procurement_score(offering) }
    end
    @supplier_offerings = @supplier_offerings.sort_by { |offering| [ offering.product_variant.product.name, *procurement_score(offering) ] }
    @line_item = @offer.line_items.build(quantity: 1, unit: "Stk", tax_rate: SystemSetting.current.standard_tax_rate, discount_type: "none")
  end

  def procurement_score(offering)
    [
      offering.current_price&.purchase_price || BigDecimal("999999999"),
      offering.lead_time_days,
      offering.return_policy == "non_returnable" ? 1 : 0
    ]
  end
end
