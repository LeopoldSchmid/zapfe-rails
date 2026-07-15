require "test_helper"

class Orders::ApplyTemplateTest < ActiveSupport::TestCase
  test "materializes tags, tasks, checklists and resources for one dated order" do
    admin = admin_users(:one)
    resource = Resource.create!(name: "Ape Vorlage", resource_type: "Ape")
    checklist_template = ChecklistTemplate.create!(name: "Ape · Aufbau Test", resource_type: "Ape", section: "setup")
    checklist_template.items.create!(title: "Anlage prüfen", position: 1)
    template = OrderTemplate.create!(name: "Golfplatz", event_location: "Clubhaus", start_time: "10:00", end_time: "18:00")
    template.tag_names = "Golfplatz, wiederkehrend"
    template.persist_tags!
    template.resources << resource
    template.product_variants << product_variants(:one)
    template.checklist_templates << checklist_template
    template.template_tasks.create!(title: "Ansprechpartner informieren", relative_offset_days: -3, position: 1)
    order = Order.new(customer_name: "Golfverein", event_date: Date.new(2026, 9, 12), responsible_admin_user: admin, status: "preparing")

    applier = Orders::ApplyTemplate.new(order: order, template: template)
    applier.apply_defaults!
    order.save!
    applier.materialize!

    assert_equal "Clubhaus", order.event_location
    assert_equal %w[golfplatz wiederkehrend], order.tags.order(:name).pluck(:name)
    assert_equal product_variants(:one), order.product_selections.sole.product_variant
    assert_equal Date.new(2026, 9, 9), order.tasks.sole.due_on
    assert_equal "Ape · Aufbau Test", order.checklists.sole.name
    reservation = order.reservations.sole
    assert_equal resource, reservation.resource
    assert_equal Time.zone.parse("2026-09-12 10:00"), reservation.starts_at
  end
end
