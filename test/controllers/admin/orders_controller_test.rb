require "test_helper"

class Admin::OrdersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = admin_users(:one)
    post admin_login_url, params: { email: @admin.email, password: "password123" }
  end

  test "creates a manual order with the required fields" do
    assert_difference("Order.count", 1) do
      post admin_orders_url, params: { order: { responsible_admin_user_id: @admin.id, customer_name: "Verein Freiburg", event_date: Date.new(2026, 8, 1), event_location: "Freiburg", status: "preparing" } }
    end

    assert_redirected_to admin_order_url(Order.last)
  end

  test "creates a manual order before the event date is known" do
    assert_difference("Order.count", 1) do
      post admin_orders_url, params: { order: { responsible_admin_user_id: @admin.id, customer_name: "Verein Freiburg", event_location: "Freiburg", status: "preparing" } }
    end

    assert_nil Order.last.event_date
  end

  test "updates event and contact details on an order" do
    order = orders(:from_inquiry)

    patch admin_order_url(order), params: { order: { responsible_admin_user_id: @admin.id, status: "offered", customer_name: "Verein Freiburg", customer_email: "kontakt@verein.example", customer_phone: "+497611234", event_date: Date.new(2026, 9, 10), event_location: "Freiburg", customer_message: "Termin abgestimmt", next_step: "Angebot senden", next_step_due_on: Date.new(2026, 8, 20) } }

    assert_redirected_to admin_order_url(order)
    order.reload
    assert_equal Date.new(2026, 9, 10), order.event_date
    assert_equal "kontakt@verein.example", order.customer_email
    assert_equal "Angebot senden", order.next_step
    assert_equal "offered", order.status
    assert_equal 2, order.activities.count
  end

  test "adds a personal internal note" do
    order = orders(:from_inquiry)

    assert_difference("Activity.count", 1) { post add_note_admin_order_url(order), params: { note: "Aufbau abstimmen" } }
    assert_equal "Aufbau abstimmen", order.activities.last.message
  end

  test "archives an order and excludes it from the active list" do
    order = orders(:from_inquiry)
    patch archive_admin_order_url(order)

    assert order.reload.archived?
    get admin_orders_url
    assert_select "article", text: /#{Regexp.escape(order.customer_name)}/, count: 0
    get admin_orders_url, params: { archived: 1 }
    assert_select "article", text: /#{Regexp.escape(order.customer_name)}/
  end

  test "restores an archived order to the active list" do
    order = orders(:from_inquiry)
    order.update!(archived_at: Time.current)

    patch unarchive_admin_order_url(order)

    assert_redirected_to admin_orders_url
    assert_not order.reload.archived?
    get admin_orders_url
    assert_select "article", text: /#{Regexp.escape(order.customer_name)}/
  end

  test "downloads an attachment through the protected order route" do
    order = orders(:from_inquiry)
    order.attachments.attach(io: StringIO.new("Beispiel-PDF"), filename: "auftrag.pdf", content_type: "application/pdf")

    get attachment_admin_order_url(order, order.attachments.last)

    assert_response :success
    assert_equal "Beispiel-PDF", response.body
    assert_equal "application/pdf", response.media_type
  end

  test "renders dedicated procurement and execution work areas" do
    order = orders(:from_inquiry)

    get procurement_admin_order_url(order)
    assert_response :success
    assert_select "h2", text: "Bestellungen vorbereiten und verfolgen"

    get execution_admin_order_url(order)
    assert_response :success
    assert_select "h2", text: "Ist-Zeit erfassen"
  end

  test "saves freeform test notes in their own workspace" do
    order = orders(:from_inquiry)

    patch notes_admin_order_url(order), params: { order: { freeform_notes: "Kunde fragt nach Gläsern und Kühlung." } }

    assert_redirected_to notes_admin_order_url(order)
    assert_equal "Kunde fragt nach Gläsern und Kühlung.", order.reload.freeform_notes.to_plain_text
    assert_equal "Freie Testnotizen aktualisiert", order.activities.order(:created_at).last.message

    get notes_admin_order_url(order)
    assert_select "h2", text: "Freie Notizen"
    assert_select "lexxy-editor.lexxy-content.admin-rich-text"
    assert_select "link[href*='tailwind']"
  end
end
