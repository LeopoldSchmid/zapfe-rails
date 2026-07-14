require "test_helper"

class SupplierTest < ActiveSupport::TestCase
  test "allows only one default supplier" do
    supplier = suppliers(:beck)
    supplier.default_supplier = true

    assert_not supplier.valid?
    assert_includes supplier.errors.attribute_names, :default_supplier
  end
end
