class DueTaskPushNotificationsJob < ApplicationJob
  queue_as :default

  def perform
    return unless PushNotifications::SendNotification.configured?

    Task.where.not(status: "done").where.not(assigned_admin_user_id: nil).where.not(due_on: nil).where(due_on: ..Date.current).find_each do |task|
      next if task.last_push_reminded_on == Date.current

      task.assigned_admin_user.push_subscriptions.find_each do |subscription|
        delivery = PushNotificationDelivery.find_or_create_by!(
          task: task,
          push_subscription: subscription,
          kind: "due_reminder",
          notification_on: Date.current
        )
        PushNotificationJob.perform_later(delivery) unless delivery.status.in?(%w[delivering delivered])
      end
    end
  end
end
