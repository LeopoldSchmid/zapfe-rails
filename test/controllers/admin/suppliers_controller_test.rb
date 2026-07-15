require "test_helper"

class Admin::SuppliersControllerTest < ActionDispatch::IntegrationTest
  setup do
    admin = admin_users(:one)
    post admin_login_url, params: { email: admin.email, password: "password123" }
  end

  test "creates a supplier with a procurement profile" do
    assert_difference([ "Supplier.count", "ProcurementProfile.count" ], 1) do
      post admin_suppliers_url, params: { supplier: { name: "Freiburger Getränkehandel", active: "1", procurement_profiles_attributes: { "0" => { name: "Lagerware", lead_time_days: 1, return_policy: "returnable" } } } }
    end

    assert_redirected_to admin_suppliers_url
  end

  test "creates an offering with its first historical purchase price" do
    supplier = suppliers(:suedstar)
    profile = procurement_profiles(:stock)
    variant = product_variants(:two)

    assert_difference([ "SupplierOffering.count", "SupplierPrice.count" ], 1) do
      post admin_supplier_offerings_url, params: { supplier_offering: { supplier_id: supplier.id, procurement_profile_id: profile.id, product_variant_id: variant.id, active: "1", supplier_prices_attributes: { "0" => { purchase_price: 79.5, valid_from: Date.current } } } }
    end

    assert_redirected_to admin_suppliers_url
  end

  test "shows supplier offerings with their current purchase price" do
    offering = supplier_offerings(:suedstar_variant)
    SupplierPrice.create!(supplier_offering: offering, purchase_price: 72.5, valid_from: Date.current)

    get admin_suppliers_url

    assert_response :success
    assert_match(/72[,.]50 €/, response.body)
    assert_select "a[href='#{edit_admin_supplier_offering_path(offering)}']", text: "Bearbeiten"
  end
end
