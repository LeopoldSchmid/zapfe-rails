require "test_helper"

class OrderChecklistTest < ActiveSupport::TestCase
  test "is completed only when every item is completed" do
    order = Order.create!(customer_name: "Checklisten GmbH", event_location: "Freiburg", status: "preparing", responsible_admin_user: admin_users(:one))
    checklist = order.checklists.create!(name: "Ape · Packen", section: "packing")
    checklist.items.create!(title: "Ausrüstung prüfen", completed: true)
    checklist.items.create!(title: "Werkzeug einladen", completed: false)

    checklist.refresh_status!
    assert_equal "open", checklist.status

    checklist.items.last.update!(completed: true)
    checklist.refresh_status!
    assert_equal "completed", checklist.status
  end
end
