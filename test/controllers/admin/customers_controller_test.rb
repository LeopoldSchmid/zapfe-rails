require "test_helper"

class Admin::CustomersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = admin_users(:one)
    sign_in_admin(@admin)
  end

  test "creates a customer with a primary contact" do
    assert_difference([ "Customer.count", "Contact.count" ], 1) do
      post admin_customers_url, params: { customer: { name: "Golfclub Freiburg", contacts_attributes: { "0" => { name: "Eva Event", email: "eva@golf.test", primary: "1" } } } }
    end

    customer = Customer.last
    assert customer.contacts.where(primary: true).exists?
    get contact_options_admin_customer_url(customer)
    assert_response :success
    assert_equal "Eva Event", JSON.parse(response.body).first.fetch("label")
  end

  test "paginates growing customer lists" do
    51.times { |index| Customer.create!(name: format("Pagination %02d", index)) }

    get admin_customers_url

    assert_response :success
    assert_select ".admin-panel", maximum: 50
    assert_select "a[rel=next]", "Nächste Seite →"
  end
end
