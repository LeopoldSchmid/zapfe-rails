require "test_helper"

class Admin::OrderTemplatesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = admin_users(:one)
    sign_in_admin(@admin)
  end

  test "creates a weekly series from an order template" do
    template = OrderTemplate.create!(name: "Golf-Event", event_location: "Golfclub", responsible_admin_user: @admin)

    assert_difference("Order.count", 4) do
      post create_series_admin_order_template_url(template), params: { series: { start_on: "2026-07-14", weekday: 1, occurrences: 4 } }
    end

    assert_redirected_to admin_orders_url
    assert_equal "Golf-Event · 20.07.2026", Order.find_by!(event_date: Date.new(2026, 7, 20)).customer_name
  end

  test "creates multiple tasks attached to one template" do
    assert_difference("OrderTemplateTask.count", 2) do
      post admin_order_templates_url, params: {
        order_template: {
          name: "Golf-Event",
          template_tasks_attributes: {
            "0" => { title: "Aufbauen", relative_offset_days: -1 },
            "1" => { title: "Abbauen", relative_offset_days: 0 }
          }
        }
      }
    end

    assert_equal [ "Abbauen", "Aufbauen" ], OrderTemplate.last.template_tasks.order(:title).pluck(:title)
  end
end
