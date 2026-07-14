require "test_helper"

class Admin::TasksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = admin_users(:one)
    post admin_login_url, params: { email: @admin.email, password: "password123" }
    @order = orders(:from_inquiry)
  end

  test "creates a relative task and marks it done" do
    assert_difference("Task.count", 1) do
      post admin_order_tasks_url(@order), params: { task: { title: "Getränke bestellen", assigned_admin_user_id: @admin.id, relative_anchor: "event_date", relative_offset_days: -14 } }
    end

    task = Task.last
    assert_equal @order.event_date - 14.days, task.due_on

    patch admin_order_task_url(@order, task), params: { task: { status: "done" } }
    assert_equal "done", task.reload.status
  end
end
