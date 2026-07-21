class PushNotificationJob < ApplicationJob
  queue_as :default
  retry_on StandardError, wait: :polynomially_longer, attempts: 5

  def perform(subscription_or_delivery, title: nil, body: nil, path: nil, tag: nil)
    return perform_tracked(subscription_or_delivery) if subscription_or_delivery.is_a?(PushNotificationDelivery)

    send_notification(subscription: subscription_or_delivery, title:, body:, path:, tag:)
  end

  private

  def perform_tracked(delivery)
    return if delivery.status == "delivered"

    delivery.update!(status: "delivering", attempts: delivery.attempts + 1, failed_at: nil)
    task = delivery.task
    send_notification(
      subscription: delivery.push_subscription,
      title: "Aufgabe fällig",
      body: "Details nach sicherer Anmeldung öffnen.",
      path: Rails.application.routes.url_helpers.execution_admin_order_path(task.order, anchor: "task-#{task.id}"),
      tag: "task-#{task.id}-#{delivery.notification_on}"
    )
    delivery.update!(status: "delivered", delivered_at: Time.current, last_error_class: nil, last_error_digest: nil)
    mark_task_reminded_if_complete(task, delivery.notification_on)
  rescue StandardError => error
    delivery.update!(
      status: "failed", failed_at: Time.current, last_error_class: error.class.name,
      last_error_digest: Digest::SHA256.hexdigest(error.message.to_s)
    )
    raise
  end

  def mark_task_reminded_if_complete(task, notification_on)
    scope = PushNotificationDelivery.where(task: task, kind: "due_reminder", notification_on: notification_on)
    task.update_column(:last_push_reminded_on, notification_on) if scope.exists? && scope.where.not(status: "delivered").none?
  end

  def send_notification(**arguments)
    PushNotifications::SendNotification.call(**arguments)
  end
end
