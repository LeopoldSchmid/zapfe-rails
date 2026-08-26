require "application_system_test_case"

class AdminPasswordLoginTest < ApplicationSystemTestCase
  test "opens the admin area with the personal password" do
    admin = admin_users(:one)
    admin.update_columns(role: "owner", active: true)

    visit admin_login_path
    fill_in "E-Mail", with: admin.email
    fill_in "Passwort", with: ADMIN_TEST_PASSWORD
    click_button "Anmelden"

    assert_current_path admin_root_path
    assert_text "Dashboard"
  end
end
