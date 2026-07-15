require "application_system_test_case"

class AdminMobileNavigationTest < ApplicationSystemTestCase
  driven_by :playwright,
    screen_size: [ 390, 844 ],
    options: {
      browser_type: :chromium,
      headless: ENV["PLAYWRIGHT_HEADED"].blank?
    }

  test "opens the mobile menu and navigates between order work areas" do
    admin = admin_users(:one)
    order = orders(:from_inquiry)

    visit admin_login_path
    fill_in "Email", with: admin.email
    fill_in "Password", with: "password123"
    click_button "Einloggen"

    click_button "Menü"
    assert_link "Aufträge"
    click_link "Aufträge"
    assert_current_path admin_orders_path

    click_link "Öffnen", match: :first
    within(".admin-process") { click_link "Angebot" }
    assert_current_path admin_order_offers_path(order)
    assert_text "Angebote erstellen und bearbeiten"

    within(".admin-process") { click_link "Durchführung" }
    assert_current_path execution_admin_order_path(order)
    assert_text "Aufgaben"
  end
end
