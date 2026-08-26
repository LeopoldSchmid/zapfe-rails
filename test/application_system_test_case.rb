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
    admin_user.update_columns(role: role, active: true)

    visit admin_login_path
    fill_in "E-Mail", with: admin_user.email
    fill_in "Passwort", with: ADMIN_TEST_PASSWORD
    click_button "Anmelden"
    assert_current_path admin_root_path
  end
end
