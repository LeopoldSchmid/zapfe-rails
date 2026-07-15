require "test_helper"

class ReservationTest < ActiveSupport::TestCase
  setup do
    @resource = Resource.create!(name: "Ape #1", resource_type: "Ape")
    @order = orders(:from_inquiry)
  end

  test "blocks overlapping reservations for the same concrete resource" do
    Reservation.create!(resource: @resource, order: @order, starts_at: Time.zone.parse("2026-08-01 10:00"), ends_at: Time.zone.parse("2026-08-01 22:00"))
    overlap = Reservation.new(resource: @resource, order: @order, starts_at: Time.zone.parse("2026-08-01 18:00"), ends_at: Time.zone.parse("2026-08-02 10:00"))

    assert_not overlap.valid?
    assert_includes overlap.errors.attribute_names, :resource
  end

  test "allows adjacent reservations without an implicit buffer" do
    Reservation.create!(resource: @resource, order: @order, starts_at: Time.zone.parse("2026-08-01 10:00"), ends_at: Time.zone.parse("2026-08-01 22:00"))
    adjacent = Reservation.new(resource: @resource, order: @order, starts_at: Time.zone.parse("2026-08-01 22:00"), ends_at: Time.zone.parse("2026-08-02 10:00"))

    assert adjacent.valid?
  end

  test "allows overlapping resource requests but prevents confirming a conflicting request" do
    first = Reservation.create!(resource: @resource, order: @order, status: "requested", starts_at: Time.zone.parse("2026-08-01 10:00"), ends_at: Time.zone.parse("2026-08-01 22:00"))
    second = Reservation.create!(resource: @resource, order: @order, status: "requested", starts_at: Time.zone.parse("2026-08-01 18:00"), ends_at: Time.zone.parse("2026-08-02 10:00"))

    assert first.update(status: "reserved")
    assert_not second.update(status: "reserved")
    assert_includes second.errors.attribute_names, :resource
  end
end
