class PagesController < ApplicationController
  def home; end

  def events
    @events = Event.public_listing
  end

  def solutions; end

  def cta_preview; end

  def drinks
    @categories = Category.catalog_listing
    @brands = Product.catalog_brands
    @subcategories = Product.catalog_subcategories
    @products = sort_products_for_display(Product.catalog_listing.to_a)
    @featured_products = @products.select(&:featured)
    @catalog_products = @products.reject(&:featured)
  end

  def calculator
    @products = sort_products_for_display(Product.catalog_listing.to_a)
    @featured_products = @products.select(&:featured)
    @catalog_products = @products.reject(&:featured)
  end

  def contact
  end

  def impressum
  end

  def datenschutz
  end

  def sitemap
    @static_pages = [
      root_url,
      calculator_url,
      drinks_url,
      events_url,
      contact_url,
      solutions_url,
      impressum_url,
      datenschutz_url
    ]

    render layout: false
  end

  private

  def sort_products_for_display(products)
    products.sort_by do |product|
      [
        product.featured? ? 0 : 1,
        product.short_display_name.downcase,
        product.brand.to_s.downcase
      ]
    end
  end
end
