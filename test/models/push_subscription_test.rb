require "test_helper"

class PushSubscriptionTest < ActiveSupport::TestCase
  test "requires browser subscription data" do
    subscription = PushSubscription.new(admin_user: admin_users(:one))

    assert_not subscription.valid?
    assert_includes subscription.errors[:endpoint], "muss ausgefüllt werden"
  end
end
