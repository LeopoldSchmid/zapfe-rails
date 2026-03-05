require "application_system_test_case"

class CalculatorSearchTest < ApplicationSystemTestCase
  setup do
    category = categories(:one)

    @matching_product = Product.create!(
      category: category,
      article_number: "C300",
      name: "Suchbier Hell",
      brand: "Zapf Such",
      kind: "Beer",
      subcategory: "Hell",
      alcohol_content: 4.9,
      is_alcoholic: true,
      description: "Suchtest"
    )
    @matching_product.product_variants.create!(
      sku: "C300-30",
      size: 30.0,
      price: 95,
      is_available: true,
      availability: "Instant"
    )

    @other_product = Product.create!(
      category: category,
      article_number: "C301",
      name: "Anderes Bier",
      brand: "Fremdmarke",
      kind: "Beer",
      subcategory: "Pils",
      alcohol_content: 5.1,
      is_alcoholic: true,
      description: "Suchtest"
    )
    @other_product.product_variants.create!(
      sku: "C301-30",
      size: 30.0,
      price: 95,
      is_available: true,
      availability: "Instant"
    )
  end

  test "filters calculator drinks live and shows empty state" do
    visit calculator_path

    fill_in "calc-drinks-search", with: "Zapf Such"
    page.execute_script("document.getElementById('calc-drinks-track').scrollIntoView({ block: 'center' })")
    assert_selector ".calc-drink-card", count: 1
    assert_no_selector ".calc-drink-card", text: "Fremdmarke"
    assert_selector "#calc-no-results", visible: false

    fill_in "calc-drinks-search", with: "nichtsmehr"
    page.execute_script("document.getElementById('calc-no-results').scrollIntoView({ block: 'center' })")
    assert_no_selector ".calc-drink-card", text: "Zapf Such"
    assert_no_selector ".calc-drink-card", text: "Fremdmarke"
    assert_selector "#calc-no-results", text: "Kein Getränk gefunden"
  end
end
