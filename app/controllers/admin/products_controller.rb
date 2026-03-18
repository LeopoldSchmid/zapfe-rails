class Admin::ProductsController < Admin::BaseController
  before_action :set_product, only: %i[edit update destroy]
  before_action :load_index_dependencies, only: %i[index bulk_update_prices]

  def index
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
      redirect_to params[:return_to].presence || admin_products_path, notice: "Produkt aktualisiert."
    else
      if params[:return_to].present?
        @products = Product.catalog_listing.to_a
        index = @products.index { |product| product.id == @product.id }
        @products[index] = @product if index
        flash.now[:alert] = @product.errors.full_messages.to_sentence
        render :index, status: :unprocessable_entity
      else
        render :edit, status: :unprocessable_entity
      end
    end
  end

  def bulk_update_prices
    result = Catalog::BulkPriceUpdate.new(
      category_id: bulk_price_params[:category_id],
      sizes: bulk_price_params[:bulk_sizes],
      prices: bulk_price_params[:bulk_prices]
    ).call

    if result.success?
      redirect_to admin_products_path, notice: "#{result.updated_variants} Varianten in #{result.category_name} aktualisiert (#{result.summary_label})."
    else
      flash.now[:alert] = result.error_message
      render :index, status: :unprocessable_entity
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

  def load_index_dependencies
    @products = Product.catalog_listing
    @categories = Category.order(:name)
    @bulk_price_categories = Category.where(name: Catalog::BulkPriceUpdate.canonical_category_names).order(:name)
    @bulk_variant_sizes = ProductVariant.distinct.order(:size).pluck(:size)
    @bulk_price_slots = [ 20.0, 30.0, 50.0 ]
  end

  def bulk_price_params
    params.permit(:category_id, bulk_sizes: [], bulk_prices: [])
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
