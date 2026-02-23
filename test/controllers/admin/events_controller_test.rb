require "test_helper"

class Admin::EventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = AdminUser.create!(email: "event@example.com", password: "password123", password_confirmation: "password123")
    post admin_login_url, params: { email: @admin.email, password: "password123" }
  end

  test "should get index" do
    get admin_events_url
    assert_response :success
  end
end
