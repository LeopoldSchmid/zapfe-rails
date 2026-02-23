require "test_helper"

class Admin::CategoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = AdminUser.create!(email: "cat@example.com", password: "password123", password_confirmation: "password123")
    post admin_login_url, params: { email: @admin.email, password: "password123" }
  end

  test "should get index" do
    get admin_categories_url
    assert_response :success
  end
end
