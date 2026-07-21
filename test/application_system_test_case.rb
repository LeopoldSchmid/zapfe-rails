require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :playwright,
    screen_size: [ 1400, 1400 ],
    options: {
      browser_type: :chromium,
      headless: ENV["PLAYWRIGHT_HEADED"].blank?
    }

  def sign_in_admin_through_ui(admin_user, role: "owner")
    ApplicationController::RATE_LIMIT_STORE.clear
    admin_user.update_columns(
      role: role,
      active: true,
      mfa_secret_ciphertext: AdminSecurity::SecretCipher.encrypt(ADMIN_TEST_MFA_SECRET),
      mfa_recovery_code_digests: AdminSecurity::RecoveryCodes.generate.map { |code| AdminSecurity::RecoveryCodes.digest(code) },
      mfa_enabled_at: Time.current,
      mfa_last_used_at: nil
    )

    visit admin_login_path
    fill_in "E-Mail", with: admin_user.email
    fill_in "Passwort", with: ADMIN_TEST_PASSWORD
    click_button "Anmelden"
    fill_in "Sicherheits- oder Wiederherstellungscode", with: ROTP::TOTP.new(ADMIN_TEST_MFA_SECRET, issuer: "Zapfe Admin").now
    click_button "Anmeldung abschließen"
  end
end
