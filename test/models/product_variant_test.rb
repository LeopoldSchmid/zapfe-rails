require "test_helper"

class ProductVariantTest < ActiveSupport::TestCase
  test "requires product, sku, size, and price" do
    variant = ProductVariant.new
    assert_not variant.valid?
  end

  test "uses translated validation messages in german locale" do
    I18n.with_locale(:de) do
      variant = ProductVariant.new
      variant.valid?

      assert_no_match "Translation missing", variant.errors.full_messages.join("\n")
      assert_includes variant.errors.full_messages, "SKU muss ausgefüllt werden"
      assert_includes variant.errors.full_messages, "Größe muss ausgefüllt werden"
      assert_includes variant.errors.full_messages, "Preis muss ausgefüllt werden"
    end
  end
end
