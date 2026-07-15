class PushNotificationJob < ApplicationJob
  queue_as :default

  def perform(subscription, title:, body:, path:, tag: nil)
    PushNotifications::SendNotification.call(subscription:, title:, body:, path:, tag:)
  end
end
