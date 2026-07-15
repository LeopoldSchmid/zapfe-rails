require "test_helper"

class OrderCustomerContactTest < ActiveSupport::TestCase
  test "uses the selected contact as the order snapshot" do
    customer = Customer.create!(name: "Muster GmbH")
    contact = customer.contacts.create!(name: "Mia Muster", email: "mia@muster.test", phone: "0761 123", primary: true)
    order = Order.create!(customer:, contact:, responsible_admin_user: admin_users(:one), status: "preparing", event_location: "Freiburg")

    assert_equal "Muster GmbH", order.customer_name
    assert_equal "mia@muster.test", order.customer_email
    assert_equal "0761 123", order.customer_phone
  end

  test "rejects a contact from another customer" do
    first_customer = Customer.create!(name: "Erster Kunde")
    second_customer = Customer.create!(name: "Zweiter Kunde")
    foreign_contact = second_customer.contacts.create!(name: "Fremder Kontakt")
    order = Order.new(customer: first_customer, contact: foreign_contact, responsible_admin_user: admin_users(:one), status: "preparing", customer_name: "Erster Kunde", event_location: "Freiburg")

    assert_not order.valid?
    assert_includes order.errors[:contact], "muss zum gewählten Kunden gehören"
  end
end
