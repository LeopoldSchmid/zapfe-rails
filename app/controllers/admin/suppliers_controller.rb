class Admin::SuppliersController < Admin::BaseController
  before_action :set_supplier, only: %i[edit update]

  def index
    @suppliers = Supplier.includes(
      :procurement_profiles,
      supplier_offerings: [ :procurement_profile, :supplier_prices, { product_variant: :product } ]
    ).order(:name)
  end

  def new
    @supplier = Supplier.new
    @supplier.procurement_profiles.build(return_policy: "unknown")
  end

  def create
    @supplier = Supplier.new(supplier_params)

    if @supplier.save
      redirect_to admin_suppliers_path, notice: "Lieferant angelegt."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @supplier.procurement_profiles.build(return_policy: "unknown")
  end

  def update
    if @supplier.update(supplier_params)
      redirect_to admin_suppliers_path, notice: "Lieferant aktualisiert."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_supplier
    @supplier = Supplier.includes(supplier_offerings: [ :procurement_profile, { product_variant: :product } ]).find(params[:id])
  end

  def supplier_params
    params.require(:supplier).permit(
      :name, :email, :phone, :notes, :active, :default_supplier,
      procurement_profiles_attributes: %i[id name lead_time_days return_policy return_period_days delivery_notes cancellation_notes _destroy]
    )
  end
end
