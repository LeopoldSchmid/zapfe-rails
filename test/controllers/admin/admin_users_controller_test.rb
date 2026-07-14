require "test_helper"

class Admin::AdminUsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = admin_users(:one)
    post admin_login_url, params: { email: @admin.email, password: "password123" }
  end

  test "creates an internal account" do
    assert_difference("AdminUser.count", 1) do
      post admin_admin_users_url, params: { admin_user: { name: "Neue Person", email: "new@example.com", password: "password123", password_confirmation: "password123", active: "1" } }
    end

    assert_redirected_to admin_admin_users_url
  end

  test "does not deactivate the final active account" do
    AdminUser.where.not(id: @admin.id).update_all(active: false)

    patch admin_admin_user_url(@admin), params: { admin_user: { name: @admin.name, email: @admin.email, active: "0" } }

    assert_response :unprocessable_entity
    assert @admin.reload.active?
  end
end
