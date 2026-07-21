require "test_helper"

class Admin::CategoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = AdminUser.create!(email: "cat@example.com", password: "correct-horse-battery-staple", password_confirmation: "correct-horse-battery-staple")
    sign_in_admin(@admin)
  end

  test "should get index" do
    get admin_categories_url
    assert_response :success
  end
end
