require "test_helper"

class EventTest < ActiveSupport::TestCase
  test "requires title" do
    event = Event.new
    assert_not event.valid?
  end
end
