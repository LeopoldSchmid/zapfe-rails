require "test_helper"

class Admin::InquiriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = admin_users(:one)
    post admin_login_url, params: { email: @admin.email, password: "password123" }
  end

  test "lists unassigned inquiries and permits a conscious assignment" do
    inquiry = inquiries(:two)

    get admin_inquiries_url, params: { unassigned: 1 }
    assert_response :success
    assert_select "article", text: /#{Regexp.escape(inquiry.customer_name)}/

    patch assign_admin_inquiry_url(inquiry), params: { inquiry: { assigned_admin_user_id: @admin.id, status: "clarifying", next_step: "Kundin anrufen", next_step_due_on: Date.current } }

    assert_redirected_to admin_inquiry_url(inquiry)
    inquiry.reload
    assert_equal @admin, inquiry.assigned_admin_user
    assert_equal "clarifying", inquiry.status
    assert_equal "Kundin anrufen", inquiry.next_step
  end

  test "updates known contact and event details on an inquiry" do
    inquiry = inquiries(:two)

    patch assign_admin_inquiry_url(inquiry), params: { inquiry: { first_name: "Erika", last_name: "Musterfrau", email: "erika@beispiel.de", phone: "+497611234", event_type: "Sommerfest", event_date: Date.new(2026, 9, 10), starts_on: Date.new(2026, 9, 10), ends_on: Date.new(2026, 9, 11), start_time: "16:00", end_time: "23:00", delivery_street: "Hauptstraße 1", delivery_postcode: "79098", delivery_city: "Freiburg", guests: 120, message: "Details abgestimmt" } }

    assert_redirected_to admin_inquiry_url(inquiry)
    inquiry.reload
    assert_equal Date.new(2026, 9, 10), inquiry.event_date
    assert_equal "Sommerfest", inquiry.event_type
    assert_equal 120, inquiry.guests
    assert_equal "Freiburg", inquiry.delivery_city
  end

  test "converts an inquiry once and redirects to its order" do
    inquiry = inquiries(:two)

    assert_difference("Order.count", 1) { post convert_to_order_admin_inquiry_url(inquiry) }
    assert_redirected_to admin_order_url(Order.last)
    assert_no_difference("Order.count") { post convert_to_order_admin_inquiry_url(inquiry) }
  end

  test "adds a personal internal note" do
    inquiry = inquiries(:two)

    assert_difference("Activity.count", 1) { post add_note_admin_inquiry_url(inquiry), params: { note: "Telefonat geführt" } }

    activity = inquiry.activities.last
    assert_equal "note", activity.event_type
    assert_equal @admin, activity.admin_user
    assert_equal "Telefonat geführt", activity.message
  end

  test "archives an inquiry and excludes it from the active list" do
    inquiry = inquiries(:two)
    patch archive_admin_inquiry_url(inquiry)

    assert_redirected_to admin_inquiries_url
    assert inquiry.reload.archived?
    get admin_inquiries_url
    assert_select "article", text: /#{Regexp.escape(inquiry.customer_name)}/, count: 0
    get admin_inquiries_url, params: { archived: 1 }
    assert_select "article", text: /#{Regexp.escape(inquiry.customer_name)}/
  end

  test "filters inquiries by responsibility and next-step due date" do
    inquiry = inquiries(:two)
    inquiry.update!(assigned_admin_user: @admin, next_step_due_on: Date.current, next_step: "Anrufen")

    get admin_inquiries_url, params: { assigned_admin_user_id: @admin.id, due: "overdue" }

    assert_response :success
    assert_select "article", text: /#{Regexp.escape(inquiry.customer_name)}/
  end

  test "downloads an attachment through the protected inquiry route" do
    inquiry = inquiries(:two)
    inquiry.attachments.attach(io: StringIO.new("Beispiel-PDF"), filename: "angebot.pdf", content_type: "application/pdf")

    get attachment_admin_inquiry_url(inquiry, inquiry.attachments.last)

    assert_response :success
    assert_equal "Beispiel-PDF", response.body
    assert_equal "application/pdf", response.media_type
  end

  test "requires an admin login to download an inquiry attachment" do
    inquiry = inquiries(:two)
    inquiry.attachments.attach(io: StringIO.new("Beispiel-PDF"), filename: "angebot.pdf", content_type: "application/pdf")
    delete admin_logout_url

    get attachment_admin_inquiry_url(inquiry, inquiry.attachments.last)

    assert_redirected_to admin_login_url
  end
end
