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

  test "does not render umami script when disabled" do
    with_umami_env("UMAMI_ENABLED" => "false", "UMAMI_SCRIPT_URL" => "https://analytics.example.test/script.js", "UMAMI_WEBSITE_ID" => "site-id") do
      assert_nil umami_script_tag
    end
  end

  test "does not render umami script when required values are missing" do
    with_umami_env("UMAMI_ENABLED" => "true", "UMAMI_SCRIPT_URL" => "", "UMAMI_WEBSITE_ID" => "site-id") do
      assert_nil umami_script_tag
    end
  end

  test "renders privacy preserving umami script when configured" do
    with_umami_env(
      "UMAMI_ENABLED" => "true",
      "UMAMI_SCRIPT_URL" => "https://analytics.example.test/script.js",
      "UMAMI_WEBSITE_ID" => "site-id",
      "UMAMI_DOMAINS" => "example.test,www.example.test"
    ) do
      html = umami_script_tag

      assert_includes html, "src=\"https://analytics.example.test/script.js\""
      assert_includes html, "defer=\"defer\""
      assert_includes html, "data-website-id=\"site-id\""
      assert_includes html, "data-do-not-track=\"true\""
      assert_includes html, "data-exclude-search=\"true\""
      assert_includes html, "data-exclude-hash=\"true\""
      assert_includes html, "data-domains=\"example.test,www.example.test\""
    end
  end

  private

  def with_umami_env(values)
    keys = %w[UMAMI_ENABLED UMAMI_SCRIPT_URL UMAMI_WEBSITE_ID UMAMI_DOMAINS]
    original_values = keys.index_with { |key| ENV[key] }

    values.each { |key, value| ENV[key] = value }
    (keys - values.keys).each { |key| ENV.delete(key) }

    yield
  ensure
    original_values.each do |key, value|
      value.nil? ? ENV.delete(key) : ENV[key] = value
    end
  end
end
