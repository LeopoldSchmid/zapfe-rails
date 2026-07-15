require "application_system_test_case"

class AdminOfferToProcurementTest < ApplicationSystemTestCase
  test "an admin creates, finalizes and accepts an offer before creating procurement" do
    admin = admin_users(:one)
    admin.update!(name: "Systemtest Admin")
    order = orders(:from_inquiry)
    order.update!(event_date: Date.current + 30.days)

    visit admin_login_path
    fill_in "Email", with: admin.email
    fill_in "Password", with: "password123"
    click_button "Einloggen"
    assert_text "Login erfolgreich."

    visit admin_order_path(order)
    click_button "Angebotsentwurf erstellen"
    assert_text "Noch keine Angebotsnummer"

    select "Rothaus Pils · 20.0 l", from: "Produktvariante (optional)"
    fill_in "Menge", with: "2"
    fill_in "Netto-Einzelpreis", with: "120"
    click_button "Position hinzufügen"
    assert_text "Position hinzugefügt."

    click_button "Angebot finalisieren"
    assert_text "Angebot A-"
    click_button "Als angenommen markieren"
    assert_text "Angebotsstatus aktualisiert."
    click_link "Zum Auftrag"
    assert_text "Beauftragt"

    click_button "Beschaffungsplan erstellen"
    assert_text "Beschaffungsplan mit 1 Positionen erstellt."
    assert_text "Bestellung bis"
    assert_text "Beschaffung bestellen"
  end

  test "an admin removes an offer line item" do
    admin = admin_users(:one)
    offer = Offer.create!(order: orders(:from_inquiry), version: 1, valid_until: Date.current + 14.days, recipient_name: "Max Mustermann")
    offer.line_items.create!(description: "Zu löschende Position", quantity: 1, unit: "Stk", net_unit_price: 50, tax_rate: 19)

    visit admin_login_path
    fill_in "Email", with: admin.email
    fill_in "Password", with: "password123"
    click_button "Einloggen"
    assert_text "Login erfolgreich."

    visit admin_offer_path(offer)
    accept_confirm("Position wirklich entfernen?") { click_button "Entfernen" }

    assert_text "Position entfernt."
    assert_no_text "Zu löschende Position"
  end
end
