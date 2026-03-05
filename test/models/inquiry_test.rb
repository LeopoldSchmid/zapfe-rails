require "test_helper"

class InquiryTest < ActiveSupport::TestCase
  test "requires mandatory contact data" do
    inquiry = Inquiry.new
    assert_not inquiry.valid?
  end

  test "derives structured calculator fields from pricing snapshot" do
    inquiry = Inquiry.new(
      source: "calculator",
      first_name: "Erika",
      last_name: "Musterfrau",
      email: "erika@example.com",
      phone: "+49124",
      pricing_snapshot: {
        rentalOption: "self",
        days: 2,
        bringOwnDrinks: true,
        glassesRental: true,
        timing: {
          startsOn: "2026-04-04",
          endsOn: "2026-04-05",
          startTime: "17:00",
          endTime: "23:00"
        },
        deliveryAddress: {
          street: "Musterstrasse 2",
          postcode: "79100",
          city: "Freiburg"
        }
      }.to_json,
      privacy_accepted: true
    )

    assert inquiry.valid?
    assert_equal "self", inquiry.rental_mode
    assert_equal Date.new(2026, 4, 4), inquiry.starts_on
    assert_equal 2, inquiry.rental_days
    assert_equal "Musterstrasse 2", inquiry.delivery_street
    assert inquiry.bring_own_drinks
    assert inquiry.glasses_requested
  end
end
