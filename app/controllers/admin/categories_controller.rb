class Admin::CategoriesController < Admin::BaseController
  before_action :set_category, only: %i[edit update destroy]

  def index
    @categories = Category.order(:name)
  end

  def new
    @category = Category.new
  end

  def create
    @category = Category.new(category_params)

    if @category.save
      redirect_to admin_categories_path, notice: "Kategorie erstellt."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @category.update(category_params)
      redirect_to admin_categories_path, notice: "Kategorie aktualisiert."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @category.destroy
      redirect_to admin_categories_path, notice: "Kategorie gelöscht."
    else
      redirect_to admin_categories_path, alert: @category.errors.full_messages.to_sentence
    end
  end

  private

  def set_category
    @category = Category.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name, :kind, :description)
  end
end
