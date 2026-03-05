require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  test "builds product labels from brand and name" do
    product = Product.new(
      brand: "Rothaus",
      name: "Pils",
      kind: "Bier",
      subcategory: "Other"
    )

    assert_equal "Rothaus Pils", short_product_label(product)
  end

  test "does not duplicate the brand when name already starts with it" do
    product = Product.new(
      brand: "Waldhaus",
      name: "Waldhaus Ungefiltert",
      kind: "Bier",
      subcategory: "Zwickel"
    )

    assert_equal "Waldhaus Ungefiltert", short_product_label(product)
  end

  test "falls back to subcategory when name is blank" do
    product = Product.new(
      brand: "Afri",
      name: "",
      kind: "Limonade",
      subcategory: "Cola"
    )

    assert_equal "Afri Cola", short_product_label(product)
  end
end
