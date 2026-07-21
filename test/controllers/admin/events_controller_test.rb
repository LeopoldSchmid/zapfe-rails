require "test_helper"

class Admin::EventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = AdminUser.create!(email: "event@example.com", password: "correct-horse-battery-staple", password_confirmation: "correct-horse-battery-staple")
    sign_in_admin(@admin)
  end

  test "should get index" do
    get admin_events_url
    assert_response :success
  end
end
