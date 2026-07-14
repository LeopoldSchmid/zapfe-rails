require "test_helper"

class TaskTest < ActiveSupport::TestCase
  test "calculates a relative due date from the event date" do
    order = orders(:from_inquiry)
    task = order.tasks.create!(title: "Getränke bestellen", relative_anchor: "event_date", relative_offset_days: -14)

    assert_equal order.event_date - 14.days, task.due_on
  end

  test "recalculates relative tasks after an event date change" do
    order = orders(:from_inquiry)
    task = order.tasks.create!(title: "Getränke bestellen", relative_anchor: "event_date", relative_offset_days: -14)

    order.update!(event_date: Date.new(2026, 9, 1))

    assert_equal Date.new(2026, 8, 18), task.reload.due_on
  end

  test "records the completion timestamp" do
    task = orders(:from_inquiry).tasks.create!(title: "Kundin anrufen", due_on: Date.current)
    task.update!(status: "done")

    assert_not_nil task.completed_at
  end
end
