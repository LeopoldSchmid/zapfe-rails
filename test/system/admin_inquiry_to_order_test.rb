require "application_system_test_case"

class AdminInquiryToOrderTest < ApplicationSystemTestCase
  test "an admin takes over an inquiry and converts it into one order" do
    admin = admin_users(:one)
    inquiry = inquiries(:two)
    admin.update!(name: "Systemtest Admin")

    sign_in_admin_through_ui(admin)

    click_link "Anfragen"
    within "article", text: inquiry.customer_name do
      click_link "Öffnen"
    end

    select "Systemtest Admin", from: "Verantwortlich"
    select "In Klärung", from: "Status"
    fill_in "Nächster Schritt", with: "Rückruf vereinbaren"
    click_button "Änderungen speichern"

    assert_text "Anfrage aktualisiert."
    assert_equal "Rückruf vereinbaren", find_field("Nächster Schritt").value

    click_button "In Auftrag umwandeln"

    assert_text "Anfrage wurde in einen Auftrag umgewandelt."
    assert_text inquiry.customer_name
    assert_text "In Vorbereitung"
    within(".admin-process") { assert_link "Anfrage" }
  end
end
