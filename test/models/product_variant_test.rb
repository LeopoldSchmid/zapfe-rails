require "test_helper"

class ProductVariantTest < ActiveSupport::TestCase
  test "requires product, sku, size, and price" do
    variant = ProductVariant.new
    assert_not variant.valid?
  end
end
