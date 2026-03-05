class PagesController < ApplicationController
  def home
    @events_preview = Event.preview_listing
  end

  def events
    @events = Event.public_listing
  end

  def solutions
  end

  def zapfanlage_freiburg
  end

  def firmenveranstaltungen
  end

  def hochzeiten
  end

  def drinks
    @categories = Category.catalog_listing
    @brands = Product.catalog_brands
    @subcategories = Product.catalog_subcategories
    @products = Product.catalog_listing
  end

  def calculator
    @products = Product.catalog_listing
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
      zapfanlage_mieten_freiburg_url,
      loesungen_firmenveranstaltungen_url,
      loesungen_hochzeiten_url,
      impressum_url,
      datenschutz_url
    ]

    render layout: false
  end
end
