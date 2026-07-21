require "test_helper"

class Orders::CreateTest < ActiveSupport::TestCase
  class FailingApplier
    def initialize(order:, template:)
      @order = order
    end

    def apply_defaults! = @order.event_location = "Vorlage"
    def materialize! = raise(ActiveRecord::RecordInvalid, @order)
  end

  test "rolls the order back when template materialization fails" do
    attributes = {
      responsible_admin_user: admin_users(:one), customer_name: "Rollback GmbH",
      event_location: "Freiburg", status: "preparing"
    }

    assert_no_difference "Order.count" do
      assert_raises(ActiveRecord::RecordInvalid) do
        Orders::Create.new(attributes: attributes, template: Object.new, applier_class: FailingApplier).call
      end
    end
  end
end
