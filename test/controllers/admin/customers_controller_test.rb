require "test_helper"

class Admin::CustomersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = admin_users(:one)
    post admin_login_url, params: { email: @admin.email, password: "password123" }
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
end
