require "test_helper"

class Offers::ResolveTest < ActiveSupport::TestCase
  test "marks an offer as accepted and confirms its order" do
    offer = Offer.create!(order: orders(:from_inquiry), version: 1, valid_until: Date.current + 14.days, recipient_name: "Max Mustermann")
    offer.line_items.create!(description: "Miete", quantity: 1, unit: "Tag", net_unit_price: 100, tax_rate: 19)
    Offers::Finalize.new(offer: offer, admin_user: admin_users(:one)).call

    Offers::Resolve.new(offer: offer, status: "accepted", admin_user: admin_users(:one)).call

    assert_equal "accepted", offer.reload.status
    assert_equal "confirmed", offer.order.reload.status
    assert_match(/angenommen/, offer.activities.last.message)
  end
end
