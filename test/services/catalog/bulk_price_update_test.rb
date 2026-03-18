require "test_helper"

module Catalog
  class BulkPriceUpdateTest < ActiveSupport::TestCase
    test "updates only matching variants for canonical category and selected sizes" do
      beer = Category.find_or_create_by!(name: "Bier") { |category| category.kind = "Bier" }
      legacy = Category.find_or_create_by!(name: "Beer") { |category| category.kind = "Beer" }

      matching_product = Product.create!(
        article_number: "CANON-1",
        category: beer,
        name: "Pils",
        brand: "Zapfe",
        kind: "Bier",
        subcategory: "Pils",
        description: "Test",
        is_alcoholic: true
      )
      matching_variant_20 = matching_product.product_variants.create!(sku: "CANON-1-20", size: 20.0, price: 95.0, is_available: true, availability: "Instant")
      matching_variant_30 = matching_product.product_variants.create!(sku: "CANON-1-30", size: 30.0, price: 120.0, is_available: true, availability: "Instant")

      legacy_product = Product.create!(
        article_number: "LEGACY-1",
        category: legacy,
        name: "Legacy Bier",
        brand: "Zapfe",
        kind: "Beer",
        subcategory: "Pils",
        description: "Test",
        is_alcoholic: true
      )
      legacy_variant = legacy_product.product_variants.create!(sku: "LEGACY-1-20", size: 20.0, price: 101.0, is_available: true, availability: "Instant")

      result = Catalog::BulkPriceUpdate.new(
        category_id: beer.id,
        sizes: [ "20", "30", "50" ],
        prices: [ "80", "111", "" ]
      ).call

      assert result.success?
      assert_equal 2, result.updated_variants
      assert_equal 80.0, matching_variant_20.reload.price.to_f
      assert_equal 111.0, matching_variant_30.reload.price.to_f
      assert_equal 101.0, legacy_variant.reload.price.to_f
    end

    test "rejects non canonical categories" do
      legacy = Category.find_or_create_by!(name: "Beer") { |category| category.kind = "Beer" }

      result = Catalog::BulkPriceUpdate.new(category_id: legacy.id, sizes: [ "20" ], prices: [ "80" ]).call

      assert_not result.success?
      assert_equal "Bitte wähle eine harmonisierte Kategorie.", result.error_message
    end

    test "rejects empty bulk update payload" do
      beer = Category.find_or_create_by!(name: "Bier") { |category| category.kind = "Bier" }

      result = Catalog::BulkPriceUpdate.new(category_id: beer.id, sizes: [ "20", "30" ], prices: [ "", "" ]).call

      assert_not result.success?
      assert_equal "Bitte gib mindestens einen gültigen Preis für eine Größe an.", result.error_message
    end
  end
end
