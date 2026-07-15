require "application_system_test_case"

class AdminInvoiceFlowTest < ApplicationSystemTestCase
  test "creates and finalizes an invoice from an accepted offer" do
    admin = admin_users(:one)
    order = orders(:from_inquiry)
    offer = order.offers.create!(version: 1, status: "draft", valid_until: Date.current + 14.days, recipient_name: "Verein Freiburg", recipient_email: "rechnung@verein.example", recipient_address: "Musterstraße 1\n79100 Freiburg")
    offer.line_items.create!(description: "Miete Zapfe", quantity: 1, unit: "Tag", net_unit_price: 100, tax_rate: 19, discount_type: "none")
    offer.update!(status: "accepted")

    visit admin_login_path
    fill_in "Email", with: admin.email
    fill_in "Password", with: "password123"
    click_button "Einloggen"
    assert_text "Login erfolgreich."

    visit admin_order_invoices_path(order)
    assert_text "Rechnungen"
    click_button "Rechnungsentwurf erstellen"
    assert_text "Noch nicht finalisiert"
    accept_confirm { click_button "Rechnung finalisieren" }
    assert_text "Rechnung R-#{Date.current.year}-"
    assert_link "PDF öffnen"
  end
end
