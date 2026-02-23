require "test_helper"

class Admin::DashboardControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = AdminUser.create!(email: "dash@example.com", password: "password123", password_confirmation: "password123")
  end

  test "requires login" do
    get admin_root_url
    assert_redirected_to admin_login_url
  end

  test "shows dashboard when logged in" do
    post admin_login_url, params: { email: @admin.email, password: "password123" }
    get admin_root_url
    assert_response :success
  end
end
