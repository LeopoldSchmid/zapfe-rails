require "test_helper"

class Orders::CreateFromInquiryTest < ActiveSupport::TestCase
  test "copies the inquiry data, assigns ownership, and is idempotent" do
    inquiry = inquiries(:two)
    admin = admin_users(:one)

    first_order = Orders::CreateFromInquiry.new(inquiry: inquiry, responsible_admin_user: admin).call
    second_order = Orders::CreateFromInquiry.new(inquiry: inquiry, responsible_admin_user: admin_users(:two)).call

    assert_equal first_order, second_order
    assert_equal 1, Order.where(inquiry: inquiry).count
    assert_equal admin, first_order.responsible_admin_user
    assert_equal inquiry.customer_name, first_order.customer_name
    assert_equal inquiry.email, first_order.customer_email
    assert_equal inquiry.delivery_address, first_order.event_location
    assert_equal inquiry.pricing_snapshot, first_order.inquiry_pricing_snapshot
    assert_equal "closed", inquiry.reload.status
    assert_equal "In Auftrag umgewandelt", inquiry.closure_reason
  end

  test "keeps an explicitly assigned inquiry owner" do
    inquiry = inquiries(:two)
    inquiry.update!(assigned_admin_user: admin_users(:two))

    order = Orders::CreateFromInquiry.new(inquiry: inquiry, responsible_admin_user: admin_users(:one)).call

    assert_equal admin_users(:two), order.responsible_admin_user
  end
end
