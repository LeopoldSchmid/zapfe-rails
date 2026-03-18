require "application_system_test_case"

class DrinksSearchTest < ApplicationSystemTestCase
  setup do
    category = categories(:one)

    @matching_product = Product.create!(
      category: category,
      article_number: "B300",
      name: "Test Pils Extra",
      brand: "Suchbrauerei",
      kind: "Beer",
      subcategory: "Pils",
      alcohol_content: 5.0,
      is_alcoholic: true,
      featured: true,
      featured_position: 1,
      featured_note: "Beliebt fur unkomplizierte Events.",
      description: "Suchtest"
    )
    @matching_product.product_variants.create!(
      sku: "B300-30",
      size: 30.0,
      price: 95,
      is_available: true,
      availability: "Instant"
    )

    @other_product = Product.create!(
      category: category,
      article_number: "B301",
      name: "Dunkel Spezial",
      brand: "Anderebrauerei",
      kind: "Beer",
      subcategory: "Dunkel",
      alcohol_content: 5.2,
      is_alcoholic: true,
      featured: false,
      description: "Suchtest"
    )
    @other_product.product_variants.create!(
      sku: "B301-30",
      size: 30.0,
      price: 95,
      is_available: true,
      availability: "Instant"
    )
  end

  test "filters drinks live and shows empty state" do
    visit drinks_path

    fill_in "drinks-search", with: "Suchbrauerei"
    assert_selector ".drink-card", count: 1
    assert_selector ".drink-card", text: "Test Pils Extra"
    assert_no_selector ".drink-card", text: "Anderebrauerei"
    assert_selector "#drinks-no-results", visible: false

    fill_in "drinks-search", with: "unauffindbar"
    assert_no_selector ".drink-card", text: "Test Pils Extra"
    assert_no_selector ".drink-card", text: "Anderebrauerei"
    assert_selector "#drinks-no-results", text: "Kein Getränk gefunden"
  end

  test "can limit catalog to favorites" do
    visit drinks_path

    find("#toggle-drinks-filters").click if page.has_selector?("#toggle-drinks-filters", visible: true)
    find("details", text: "Weitere Filter").click if page.has_selector?("details", text: "Weitere Filter")
    check "Zapfe!Tipps"

    assert_selector ".drink-card", text: "Test Pils Extra"
    assert_no_selector ".drink-card", text: "Anderebrauerei"
  end
end
