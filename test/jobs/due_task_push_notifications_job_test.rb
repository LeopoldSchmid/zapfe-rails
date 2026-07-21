require "test_helper"

class DueTaskPushNotificationsJobTest < ActiveJob::TestCase
  test "does not place customer or task data in lock-screen payloads" do
    task = orders(:from_inquiry).tasks.create!(
      title: "Vertrauliche Kundenaufgabe",
      assigned_admin_user: admin_users(:one),
      due_on: Date.current
    )
    subscription = PushSubscription.create!(
      admin_user: admin_users(:one),
      endpoint: "https://push.example.test/subscription",
      p256dh: "public-key",
      auth: "auth-secret"
    )

    with_vapid_configuration do
      assert_enqueued_with(job: PushNotificationJob) do
        DueTaskPushNotificationsJob.perform_now
      end
    end

    delivery = PushNotificationDelivery.find_by!(task: task, push_subscription: subscription)
    assert_equal "queued", delivery.status
    assert_nil task.reload.last_push_reminded_on

    payload = nil
    job = PushNotificationJob.new
    job.define_singleton_method(:send_notification) { |**arguments| payload = arguments }
    job.perform(delivery)

    assert_equal "delivered", delivery.reload.status
    assert_equal Date.current, task.reload.last_push_reminded_on
    assert_equal "Details nach sicherer Anmeldung öffnen.", payload.fetch(:body)
    assert_not_includes payload.fetch(:body), task.title
    assert_not_includes payload.fetch(:body), task.order.customer_name
  end

  test "does not mark a reminder delivered when push fails and permits retry" do
    task = orders(:from_inquiry).tasks.create!(
      title: "Retry reminder", assigned_admin_user: admin_users(:one), due_on: Date.current
    )
    subscription = PushSubscription.create!(
      admin_user: admin_users(:one), endpoint: "https://push.example.test/retry",
      p256dh: "public-key", auth: "auth-secret"
    )
    delivery = PushNotificationDelivery.create!(
      task: task, push_subscription: subscription, kind: "due_reminder", notification_on: Date.current
    )
    job = PushNotificationJob.new
    job.define_singleton_method(:send_notification) { |**_arguments| raise StandardError, "synthetic endpoint detail" }

    assert_raises(StandardError) { job.perform(delivery) }
    assert_equal "failed", delivery.reload.status
    assert_nil task.reload.last_push_reminded_on
    assert_not_includes delivery.last_error_digest, "endpoint"

    retry_job = PushNotificationJob.new
    retry_job.define_singleton_method(:send_notification) { |**_arguments| true }
    retry_job.perform(delivery)
    assert_equal "delivered", delivery.reload.status
    assert_equal Date.current, task.reload.last_push_reminded_on
  end

  private

  def with_vapid_configuration
    previous = ENV.values_at("VAPID_PUBLIC_KEY", "VAPID_PRIVATE_KEY", "VAPID_SUBJECT")
    ENV["VAPID_PUBLIC_KEY"] = "test-public"
    ENV["VAPID_PRIVATE_KEY"] = "test-private"
    ENV["VAPID_SUBJECT"] = "mailto:privacy@example.test"
    yield
  ensure
    %w[VAPID_PUBLIC_KEY VAPID_PRIVATE_KEY VAPID_SUBJECT].zip(previous).each do |key, value|
      value.nil? ? ENV.delete(key) : ENV[key] = value
    end
  end
end
