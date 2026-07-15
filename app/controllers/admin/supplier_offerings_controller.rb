class Admin::SupplierOfferingsController < Admin::BaseController
  before_action :set_offering, only: %i[edit update]
  before_action :load_form_data, only: %i[new create edit update]

  def new
    @supplier_offering = SupplierOffering.new(active: true, supplier_id: params[:supplier_id])
    @supplier_offering.supplier_prices.build(valid_from: Date.current)
  end

  def create
    @supplier_offering = SupplierOffering.new(offering_params)

    if @supplier_offering.save
      redirect_to admin_suppliers_path, notice: "Händlerangebot angelegt."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @supplier_offering.supplier_prices.build(valid_from: Date.current)
  end

  def update
    if @supplier_offering.update(offering_params)
      redirect_to admin_suppliers_path, notice: "Händlerangebot aktualisiert."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_offering
    @supplier_offering = SupplierOffering.find(params[:id])
  end

  def load_form_data
    @suppliers = Supplier.active.order(:name)
    selected_supplier_id = @supplier_offering&.supplier_id
    @profiles = ProcurementProfile.where(supplier_id: [ nil, selected_supplier_id ].compact).includes(:supplier).order(:standard, :name)
    @product_variants = ProductVariant.includes(:product).order("products.brand", "products.name", :size).references(:product)
  end

  def offering_params
    params.require(:supplier_offering).permit(
      :supplier_id, :product_variant_id, :procurement_profile_id, :supplier_sku, :active,
      :lead_time_days_override, :return_policy_override, :return_period_days_override, :notes,
      supplier_prices_attributes: %i[id purchase_price valid_from valid_until]
    )
  end
end
