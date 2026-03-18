require "test_helper"

class AdminUserTest < ActiveSupport::TestCase
  test "valid with email and password" do
    user = AdminUser.new(email: "valid@example.com", password: "password123", password_confirmation: "password123")
    assert user.valid?
  end

  test "normalizes email before validation" do
    user = AdminUser.create!(email: "  MIXED.Case@Example.com ", password: "password123", password_confirmation: "password123")

    assert_equal "mixed.case@example.com", user.email
  end
end
