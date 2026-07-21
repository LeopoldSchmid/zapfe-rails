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

  test "requires MFA enrollment before first admin access" do
    post admin_login_url, params: { email: @admin.email, password: ADMIN_TEST_PASSWORD }
    assert_redirected_to admin_login_mfa_setup_url

    get admin_login_mfa_setup_url
    assert_response :success
    secret = response.parsed_body.at_css("code").text

    post admin_login_mfa_setup_url, params: { code: ROTP::TOTP.new(secret, issuer: "Zapfe Admin").now }
    assert_response :success
    assert @admin.reload.mfa_enabled?
    assert_select "ul[aria-label='Wiederherstellungscodes'] li", AdminSecurity::RecoveryCodes::COUNT

    get admin_root_url
    assert_response :success
  end

  test "requires a valid TOTP and rejects reuse" do
    enable_mfa(@admin)
    post admin_login_url, params: { email: @admin.email, password: ADMIN_TEST_PASSWORD }
    assert_redirected_to admin_login_mfa_url

    code = current_totp
    post admin_login_mfa_url, params: { code: code }
    assert_redirected_to admin_root_url

    delete admin_logout_url
    post admin_login_url, params: { email: @admin.email, password: ADMIN_TEST_PASSWORD }
    post admin_login_mfa_url, params: { code: code }
    assert_response :unprocessable_entity
    assert_match(/bereits verwendeter/, response.body)
  end

  test "consumes a recovery code exactly once" do
    recovery_code = enable_mfa(@admin).first
    post admin_login_url, params: { email: @admin.email, password: ADMIN_TEST_PASSWORD }
    post admin_login_mfa_url, params: { code: recovery_code }
    assert_redirected_to admin_root_url
    assert_equal AdminSecurity::RecoveryCodes::COUNT - 1, @admin.reload.recovery_codes_remaining

    delete admin_logout_url
    post admin_login_url, params: { email: @admin.email, password: ADMIN_TEST_PASSWORD }
    post admin_login_mfa_url, params: { code: recovery_code }
    assert_response :unprocessable_entity
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

  private

  def enable_mfa(admin)
    recovery_codes = AdminSecurity::RecoveryCodes.generate
    admin.enable_mfa!(secret: ADMIN_TEST_MFA_SECRET, recovery_codes: recovery_codes)
    recovery_codes
  end

  def current_totp
    ROTP::TOTP.new(ADMIN_TEST_MFA_SECRET, issuer: "Zapfe Admin").now
  end
end
