require "test_helper"

class ProductTest < ActiveSupport::TestCase
  test "requires key attributes" do
    product = Product.new
    assert_not product.valid?
  end

  test "orders featured products first by position" do
    featured_later = Product.create!(
      category: categories(:one),
      article_number: "A300",
      name: "Later",
      brand: "Featured",
      kind: "Bier",
      is_alcoholic: true,
      featured: true,
      featured_position: 3,
      description: "Test"
    )

    featured_earlier = Product.create!(
      category: categories(:one),
      article_number: "A301",
      name: "Earlier",
      brand: "Featured",
      kind: "Bier",
      is_alcoholic: true,
      featured: true,
      featured_position: 1,
      description: "Test"
    )

    regular = Product.create!(
      category: categories(:one),
      article_number: "A302",
      name: "Regular",
      brand: "Standard",
      kind: "Bier",
      is_alcoholic: true,
      featured: false,
      description: "Test"
    )

    ordered_ids = Product.catalog_listing.where(id: [
      featured_later.id,
      featured_earlier.id,
      regular.id,
      products(:one).id
    ]).to_a.map(&:id)

    assert_equal [ featured_earlier.id, products(:one).id, featured_later.id, regular.id ], ordered_ids
  end
end
