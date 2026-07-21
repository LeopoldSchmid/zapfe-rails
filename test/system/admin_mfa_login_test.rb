require "application_system_test_case"

class AdminMfaLoginTest < ApplicationSystemTestCase
  test "requires a second factor before opening the admin area" do
    admin = admin_users(:one)
    admin.update_columns(
      role: "owner",
      active: true,
      mfa_secret_ciphertext: AdminSecurity::SecretCipher.encrypt(ADMIN_TEST_MFA_SECRET),
      mfa_recovery_code_digests: [],
      mfa_enabled_at: Time.current,
      mfa_last_used_at: nil
    )

    visit admin_login_path
    fill_in "E-Mail", with: admin.email
    fill_in "Passwort", with: ADMIN_TEST_PASSWORD
    click_button "Anmelden"

    assert_current_path admin_login_mfa_path
    assert_text "Sicherheitscode eingeben"

    fill_in "Sicherheits- oder Wiederherstellungscode", with: ROTP::TOTP.new(ADMIN_TEST_MFA_SECRET, issuer: "Zapfe Admin").now
    click_button "Anmeldung abschließen"

    assert_current_path admin_root_path
    assert_text "Dashboard"
  end
end
