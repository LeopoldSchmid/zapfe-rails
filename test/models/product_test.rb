require "test_helper"

class ProductTest < ActiveSupport::TestCase
  test "requires key attributes" do
    product = Product.new
    assert_not product.valid?
  end
end
