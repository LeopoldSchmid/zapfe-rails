require "test_helper"

class AdminUserTest < ActiveSupport::TestCase
  test "valid with email and password" do
    user = AdminUser.new(email: "valid@example.com", password: "password123", password_confirmation: "password123")
    assert user.valid?
  end
end
