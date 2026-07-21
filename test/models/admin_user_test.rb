require "test_helper"

class AdminUserTest < ActiveSupport::TestCase
  test "valid with email and password" do
    user = AdminUser.new(email: "valid@example.com", password: ADMIN_TEST_PASSWORD, password_confirmation: ADMIN_TEST_PASSWORD)
    assert user.valid?
  end

  test "normalizes email before validation" do
    user = AdminUser.create!(email: "  MIXED.Case@Example.com ", password: ADMIN_TEST_PASSWORD, password_confirmation: ADMIN_TEST_PASSWORD)

    assert_equal "mixed.case@example.com", user.email
  end

  test "rejects short and common passwords" do
    user = AdminUser.new(email: "weak@example.com", password: "password123", password_confirmation: "password123")

    assert_not user.valid?
    assert user.errors[:password].any?
  end

  test "rejects passwords derived from the account email" do
    password = "valid-user-super-secret"
    user = AdminUser.new(email: "valid-user@example.com", password: password, password_confirmation: password)

    assert_not user.valid?
    assert_match(/leicht zu erraten/, user.errors[:password].to_sentence)
  end

  test "does not expose the encrypted MFA secret at rest" do
    user = AdminUser.create!(name: "MFA", email: "mfa@example.com", password: ADMIN_TEST_PASSWORD, password_confirmation: ADMIN_TEST_PASSWORD)
    user.enable_mfa!(secret: ADMIN_TEST_MFA_SECRET, recovery_codes: AdminSecurity::RecoveryCodes.generate)

    assert_not_includes user.mfa_secret_ciphertext, ADMIN_TEST_MFA_SECRET
    assert_equal ADMIN_TEST_MFA_SECRET, user.mfa_secret
  end

  test "keeps at least one active owner" do
    owner = AdminUser.create!(name: "Owner", email: "owner@example.com", password: ADMIN_TEST_PASSWORD, password_confirmation: ADMIN_TEST_PASSWORD, role: :owner)
    AdminUser.where.not(id: owner.id).update_all(active: false)

    owner.role = :member
    assert_not owner.valid?
    assert_match(/Owner-Konto/, owner.errors[:role].to_sentence)
  end

  test "removes browser push subscriptions when an account is offboarded" do
    admin = admin_users(:two)
    admin.update_columns(name: "Offboard Test", role: "member", active: true)
    admin.push_subscriptions.create!(endpoint: "https://push.example.test/offboard", p256dh: "key", auth: "secret")

    assert_difference("PushSubscription.count", -1) do
      admin.update!(active: false)
    end
  end
end
