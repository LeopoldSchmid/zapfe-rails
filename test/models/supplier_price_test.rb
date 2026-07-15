require "test_helper"

class SupplierPriceTest < ActiveSupport::TestCase
  test "derives the net purchase price from gross price and tax" do
    price = SupplierPrice.create!(supplier_offering: supplier_offerings(:suedstar_variant), gross_purchase_price: 35.70, tax_rate: 19, valid_from: Date.new(2027, 1, 1))

    assert_equal 30.to_d, price.purchase_price
  end

  test "keeps legacy net price entry working and derives its gross counterpart" do
    price = SupplierPrice.create!(supplier_offering: supplier_offerings(:suedstar_variant), purchase_price: 30, tax_rate: 19, valid_from: Date.new(2027, 2, 1))

    assert_equal 35.70.to_d, price.gross_purchase_price
  end
end
