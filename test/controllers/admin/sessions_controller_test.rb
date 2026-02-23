require "test_helper"

class Admin::SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = AdminUser.create!(email: "admin@example.com", password: "password123", password_confirmation: "password123")
  end

  test "should get login page" do
    get admin_login_url
    assert_response :success
  end

  test "should login" do
    post admin_login_url, params: { email: @admin.email, password: "password123" }
    assert_redirected_to admin_root_url
  end
end
