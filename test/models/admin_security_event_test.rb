require "test_helper"

class AdminSecurityEventTest < ActiveSupport::TestCase
  test "security events are append only" do
    event = AdminSecurityEvent.create!(event_type: "login_failed", metadata: {})

    assert_not event.update(event_type: "login_succeeded")
    assert_not event.destroy
    assert AdminSecurityEvent.exists?(event.id)
  end
end
