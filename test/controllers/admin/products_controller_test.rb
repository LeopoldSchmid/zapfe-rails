require "test_helper"

class Admin::ProductsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = AdminUser.create!(email: "products@example.com", password: "password123", password_confirmation: "password123")
    post admin_login_url, params: { email: @admin.email, password: "password123" }
  end

  test "should get index" do
    get admin_products_url
    assert_response :success
  end
end
