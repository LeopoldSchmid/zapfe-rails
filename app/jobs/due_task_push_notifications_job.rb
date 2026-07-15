class DueTaskPushNotificationsJob < ApplicationJob
  queue_as :default

  def perform
    return unless PushNotifications::SendNotification.configured?

    Task.where.not(status: "done").where.not(assigned_admin_user_id: nil).where.not(due_on: nil).where(due_on: ..Date.current).find_each do |task|
      next if task.last_push_reminded_on == Date.current

      task.assigned_admin_user.push_subscriptions.find_each do |subscription|
        PushNotificationJob.perform_later(
          subscription,
          title: "Aufgabe fällig",
          body: "#{task.order.customer_name}: #{task.title}",
          path: Rails.application.routes.url_helpers.execution_admin_order_path(task.order, anchor: "task-#{task.id}"),
          tag: "task-#{task.id}-#{Date.current}"
        )
      end
      task.update_column(:last_push_reminded_on, Date.current)
    end
  end
end
