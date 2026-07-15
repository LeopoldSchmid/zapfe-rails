require "test_helper"

class Admin::DashboardControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = AdminUser.create!(email: "dash@example.com", password: "password123", password_confirmation: "password123")
  end

  test "requires login" do
    get admin_root_url
    assert_redirected_to admin_login_url
  end

  test "shows dashboard when logged in" do
    post admin_login_url, params: { email: @admin.email, password: "password123" }
    get admin_root_url
    assert_response :success
  end

  test "shows customer and external waiting states" do
    inquiry = inquiries(:two)
    inquiry.update!(status: "waiting_customer")

    post admin_login_url, params: { email: @admin.email, password: "password123" }
    get admin_root_url

    assert_select "section", text: /Wartet auf Rückmeldung/
    assert_select "a", text: /Wartet auf Kunde · #{Regexp.escape(inquiry.customer_name)}/
  end

  test "shows due operational tasks" do
    order = orders(:from_inquiry)
    task = Task.create!(order: order, assigned_admin_user: @admin, title: "Beschaffung bestellen", status: "open", due_on: Date.current + 1.day)

    post admin_login_url, params: { email: @admin.email, password: "password123" }
    get admin_root_url

    assert_select "section", text: /Offene Aufgaben und Fristen/
    assert_select "a", text: /Beschaffung bestellen/
    assert_select "a[href='#{execution_admin_order_path(order, task_id: task.id, anchor: "task-#{task.id}")}']", text: /Beschaffung bestellen/
  end

  test "links procurement tasks to the procurement work area" do
    order = orders(:from_inquiry)
    plan = order.procurement_plans.create!(status: "planned")
    Task.create!(order: order, procurement_plan: plan, assigned_admin_user: @admin, title: "Bestellung auslösen", status: "open", due_on: Date.current + 1.day)

    post admin_login_url, params: { email: @admin.email, password: "password123" }
    get admin_root_url

    assert_select "a[href='#{procurement_admin_order_path(order)}']", text: /Bestellung auslösen/
  end
end
