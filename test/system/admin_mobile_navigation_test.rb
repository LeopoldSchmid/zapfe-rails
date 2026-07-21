require "application_system_test_case"

class AdminMobileNavigationTest < ApplicationSystemTestCase
  driven_by :playwright,
    screen_size: [ 390, 844 ],
    options: {
      browser_type: :chromium,
      headless: ENV["PLAYWRIGHT_HEADED"].blank?
    }

  test "opens the mobile menu and navigates between order work areas" do
    page.current_window.resize_to(390, 844)
    admin = admin_users(:one)
    order = orders(:from_inquiry)

    sign_in_admin_through_ui(admin)

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
