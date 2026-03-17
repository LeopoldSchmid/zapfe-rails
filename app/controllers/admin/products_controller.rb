class Admin::ProductsController < Admin::BaseController
  before_action :set_product, only: %i[edit update destroy]

  def index
    @products = Product.catalog_listing
  end

  def new
    @product = Product.new
    3.times { @product.product_variants.build }
    @categories = Category.order(:name)
  end

  def create
    @product = Product.new(product_params)
    @categories = Category.order(:name)

    if @product.save
      redirect_to admin_products_path, notice: "Produkt erstellt."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @categories = Category.order(:name)
    missing_slots = 3 - @product.product_variants.size
    missing_slots.times { @product.product_variants.build } if missing_slots.positive?
  end

  def update
    @categories = Category.order(:name)

    if @product.update(product_params)
      redirect_to admin_products_path, notice: "Produkt aktualisiert."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @product.destroy
    redirect_to admin_products_path, notice: "Produkt gelöscht."
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(
      :category_id,
      :article_number,
      :name,
      :brand,
      :kind,
      :subcategory,
      :alcohol_content,
      :is_alcoholic,
      :featured,
      :featured_position,
      :featured_note,
      :description,
      :image,
      product_variants_attributes: %i[id sku size price is_available availability _destroy]
    )
  end
end
