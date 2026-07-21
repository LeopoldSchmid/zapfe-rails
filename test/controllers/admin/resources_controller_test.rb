require "test_helper"

class Admin::ResourcesControllerTest < ActionDispatch::IntegrationTest
  setup do
    admin = admin_users(:one)
    sign_in_admin(admin)
  end

  test "creates a concrete active resource" do
    assert_difference("Resource.count", 1) do
      post admin_resources_url, params: { resource: { name: "Ape #1", resource_type: "Ape", active: "1", configuration_notes: "2 Zapfhähne" } }
    end

    assert_redirected_to admin_resources_url
  end

  test "shows a weekly reservation calendar" do
    resource = Resource.create!(name: "Ape Kalender", resource_type: "Ape")
    day = Date.current.beginning_of_week + 1.day
    Reservation.create!(resource: resource, order: orders(:from_inquiry), starts_at: Time.zone.parse("#{day} 10:00"), ends_at: Time.zone.parse("#{day} 18:00"))

    get admin_resources_url, params: { week: Date.current.beginning_of_week.iso8601 }

    assert_select "h2", "Belegungskalender"
    assert_select "td a", orders(:from_inquiry).customer_name
  end

  test "keeps the resource calendar within a fixed query budget at volume" do
    day = Date.current.beginning_of_week + 1.day
    30.times do |index|
      resource = Resource.create!(name: "Query budget #{index}", resource_type: "Ape")
      Reservation.create!(resource: resource, order: orders(:from_inquiry), starts_at: day.in_time_zone + 10.hours, ends_at: day.in_time_zone + 18.hours)
    end

    selects = 0
    subscriber = ActiveSupport::Notifications.subscribe("sql.active_record") do |_name, _start, _finish, _id, payload|
      selects += 1 if payload[:sql].match?(/\ASELECT/i) && payload[:name] != "SCHEMA"
    end
    get admin_resources_url, params: { week: Date.current.beginning_of_week.iso8601 }
    ActiveSupport::Notifications.unsubscribe(subscriber)

    assert_response :success
    assert_operator selects, :<=, 12
  ensure
    ActiveSupport::Notifications.unsubscribe(subscriber) if subscriber
  end

  test "stores a reusable rental position on a resource" do
    post admin_resources_url, params: { resource: { name: "Kegerator Position", resource_type: "Kegerator", active: "1", rental_position_name: "Miete Kegerator", rental_net_price: 95, rental_unit: "Tag" } }

    resource = Resource.last
    assert_equal "Miete Kegerator", resource.rental_position_label
    assert_equal 95.to_d, resource.rental_net_price
    assert_equal "Tag", resource.rental_unit
  end
end
