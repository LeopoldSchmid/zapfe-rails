require "test_helper"

class Admin::SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    ApplicationController::RATE_LIMIT_STORE.clear
    @admin = AdminUser.create!(
      name: "Security Admin",
      email: "admin@example.com",
      password: ADMIN_TEST_PASSWORD,
      password_confirmation: ADMIN_TEST_PASSWORD,
      role: :owner
    )
  end

  test "shows login page" do
    get admin_login_url
    assert_response :success
  end

  test "authenticates with the password and opens the admin area" do
    post admin_login_url, params: { email: @admin.email, password: ADMIN_TEST_PASSWORD }

    assert_redirected_to admin_root_url
    get admin_root_url
    assert_response :success
  end

  test "rejects an invalid password" do
    post admin_login_url, params: { email: @admin.email, password: "wrong-password-that-is-long-enough" }

    assert_response :unprocessable_entity
    assert_match(/Ungültige Zugangsdaten/, response.body)
  end

  test "credential change revokes an existing session" do
    sign_in_admin(@admin)
    @admin.update!(password: "another-correct-horse-passphrase", password_confirmation: "another-correct-horse-passphrase")

    get admin_root_url
    assert_redirected_to admin_login_url
  end

  test "idle timeout expires the session" do
    sign_in_admin(@admin)

    travel 31.minutes do
      get admin_root_url
      assert_redirected_to admin_login_url
    end
  end

  test "rate limits repeated password attempts without account lockout state" do
    11.times do
      post admin_login_url, params: { email: @admin.email, password: "definitely-wrong-password" }
    end

    assert_redirected_to admin_login_url
    assert_match(/Zu viele Anmeldeversuche/, flash[:alert])
    assert @admin.reload.active?
  end
end
