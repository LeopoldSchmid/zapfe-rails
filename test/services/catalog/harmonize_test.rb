require "test_helper"

module Catalog
  class HarmonizeTest < ActiveSupport::TestCase
    test "harmonizes category aliases, upserts hugo, normalizes prices, and syncs featured products" do
      beer = categories(:one)
      soft_drink = Category.create!(name: "Soft Drink", kind: "Soft Drink")
      sparkling_wine = Category.create!(name: "Sparkling Wine", kind: "Sparkling Wine")

      featured_target = Product.create!(
        article_number: "01765301",
        category: beer,
        name: "Rothaus Pils",
        brand: "Rothaus Badische Staatsbrauerei",
        kind: "Beer",
        subcategory: "Pils",
        description: "Test",
        is_alcoholic: true
      )
      featured_target.product_variants.create!(sku: "017653", size: 30, price: 99.99, is_available: true, availability: "Instant")

      Product.create!(
        article_number: "010062",
        category: beer,
        name: "Alpirsbacher Spezial",
        brand: "Alpirsbacher Klosterbrauerei",
        kind: "Beer",
        subcategory: "Other",
        description: "Test",
        is_alcoholic: true
      ).product_variants.create!(sku: "010062", size: 30, price: 99.99, is_available: true, availability: "Instant")

      Product.create!(
        article_number: "033620",
        category: soft_drink,
        name: "Schlor Apfelsaft Premix",
        brand: "Schlor",
        kind: "Soft Drink",
        subcategory: "Apple Juice",
        description: "Test",
        is_alcoholic: false
      ).product_variants.create!(sku: "033620", size: 19, price: 99.99, is_available: true, availability: "Instant")

      Product.create!(
        article_number: "045820",
        category: sparkling_wine,
        name: "Serena Bianco Frizzante Piu",
        brand: "Serena",
        kind: "Sparkling Wine",
        subcategory: "Frizzante",
        description: "Test",
        is_alcoholic: true
      ).product_variants.create!(sku: "045820", size: 25, price: 99.99, is_available: true, availability: "Instant")

      alcohol_free_beer = Product.create!(
        article_number: "010055",
        category: Category.create!(name: "0%", kind: "0%"),
        name: "Alkoholfreies Weizen",
        brand: "Testbrauerei",
        kind: "0%",
        subcategory: "Beer",
        description: "Test",
        is_alcoholic: false
      )
      alcohol_free_beer.product_variants.create!(sku: "010055", size: 20, price: 99.99, is_available: true, availability: "Instant")

      result = Catalog::Harmonize.new.call

      assert_equal "Bier", featured_target.reload.category.name
      assert_equal 95.0, featured_target.product_variants.first.price.to_f

      assert_equal "Sonstige", Product.find_by(article_number: "010062").subcategory

      apple_juice = Product.find_by(article_number: "033620")
      assert_equal "Softdrinks", apple_juice.category.name
      assert_equal "Apfelsaft", apple_juice.subcategory
      assert_not apple_juice.is_alcoholic?

      assert_equal "Bier", alcohol_free_beer.reload.category.name
      assert_equal "Weizen", alcohol_free_beer.subcategory
      assert_not alcohol_free_beer.is_alcoholic?

      frizzante = Product.find_by(article_number: "045820")
      assert_equal "Aperitif", frizzante.category.name

      hugo = Product.find_by(article_number: "29242200")
      assert_equal "ViniGrandi", hugo.brand
      assert_equal "Hugo", hugo.subcategory
      assert_equal 160.0, hugo.product_variants.first.price.to_f
      assert hugo.featured?
      assert_equal 5, hugo.featured_position

      assert_equal 1, result.created_products
      assert result.updated_products.positive?
      assert result.updated_variants.positive?
    end
  end
end
