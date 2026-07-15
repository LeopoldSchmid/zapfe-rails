require "test_helper"

class Admin::ReservationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    admin = admin_users(:one)
    post admin_login_url, params: { email: admin.email, password: "password123" }
    @resource = Resource.create!(name: "Kegerator #1", resource_type: "Kegerator")
    @order = orders(:from_inquiry)
  end

  test "reserves an available resource and reports a conflict" do
    post admin_order_reservations_url(@order), params: { reservation: { resource_id: @resource.id, status: "reserved", starts_at: "2026-08-01T10:00", ends_at: "2026-08-01T22:00" } }
    assert_redirected_to admin_order_url(@order)
    assert_equal 1, @order.reservations.count

    other_order = Order.create!(responsible_admin_user: admin_users(:one), customer_name: "Andere GmbH", event_location: "Freiburg")
    post admin_order_reservations_url(other_order), params: { reservation: { resource_id: @resource.id, status: "reserved", starts_at: "2026-08-01T18:00", ends_at: "2026-08-02T10:00" } }

    assert_redirected_to admin_order_url(other_order)
    assert_equal 1, Reservation.count
  end

  test "keeps a requested resource non-blocking until it is confirmed" do
    post admin_order_reservations_url(@order), params: { reservation: { resource_id: @resource.id, status: "requested", starts_at: "2026-08-01T10:00", ends_at: "2026-08-01T22:00" } }
    request = @order.reservations.sole
    other_order = Order.create!(responsible_admin_user: admin_users(:one), customer_name: "Andere GmbH", event_location: "Freiburg")

    post admin_order_reservations_url(other_order), params: { reservation: { resource_id: @resource.id, status: "reserved", starts_at: "2026-08-01T18:00", ends_at: "2026-08-02T10:00" } }
    assert_equal "reserved", Reservation.find_by!(order: other_order).status

    patch admin_order_reservation_url(@order, request), params: { reservation: { status: "reserved" } }
    assert_equal "requested", request.reload.status
    assert_equal "reserved", Reservation.find_by!(order: other_order).status
  end
end
