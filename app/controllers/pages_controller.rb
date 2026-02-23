class PagesController < ApplicationController
  def home
    @events_preview = Event.published.ordered.limit(3)
  end

  def events
    @events = Event.published.ordered
  end

  def drinks
    scope = Product.includes(:category, :product_variants).order(:brand, :name)
    @categories = Category.order(:name)
    @brands = Product.distinct.order(:brand).pluck(:brand).compact
    @subcategories = Product.distinct.order(:subcategory).pluck(:subcategory).compact
    @products = scope
  end

  def calculator
    @products = Product.includes(:product_variants).order(:brand, :name)
  end

  def contact
  end

  def impressum
  end

  def datenschutz
  end
end
