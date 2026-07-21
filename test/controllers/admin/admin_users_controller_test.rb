require "test_helper"

class Admin::AdminUsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = admin_users(:one)
    sign_in_admin(@admin)
  end

  test "creates an internal account" do
    assert_difference("AdminUser.count", 1) do
      post admin_admin_users_url, params: { admin_user: { name: "Neue Person", email: "new@example.com", password: "correct-horse-battery-staple", password_confirmation: "correct-horse-battery-staple", active: "1" } }
    end

    assert_redirected_to admin_admin_users_url
    assert_equal "member", AdminUser.find_by!(email: "new@example.com").role
    assert AdminSecurityEvent.exists?(event_type: "admin_user_created", target_admin_user: AdminUser.find_by!(email: "new@example.com"))
  end

  test "role change revokes the target sessions" do
    target = admin_users(:two)
    previous_version = target.session_version

    patch admin_admin_user_url(target), params: { admin_user: { name: target.name, email: target.email, role: "member", active: "1" } }

    assert_redirected_to admin_admin_users_url
    assert_equal "member", target.reload.role
    assert_operator target.session_version, :>, previous_version
  end

  test "owner can reset MFA and invalidate sessions" do
    target = admin_users(:two)
    target.enable_mfa!(secret: ADMIN_TEST_MFA_SECRET, recovery_codes: AdminSecurity::RecoveryCodes.generate)
    previous_version = target.session_version

    post reset_mfa_admin_admin_user_url(target)

    assert_redirected_to admin_admin_users_url
    assert_not target.reload.mfa_enabled?
    assert_operator target.session_version, :>, previous_version
    assert AdminSecurityEvent.exists?(event_type: "mfa_reset", target_admin_user: target)
  end

  test "does not deactivate the final active account" do
    AdminUser.where.not(id: @admin.id).update_all(active: false)

    patch admin_admin_user_url(@admin), params: { admin_user: { name: @admin.name, email: @admin.email, active: "0" } }

    assert_response :unprocessable_entity
    assert @admin.reload.active?
  end
end
