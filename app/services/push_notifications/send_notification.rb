module PushNotifications
  class SendNotification
    def self.call(subscription:, title:, body:, path:, tag: nil)
      return unless configured?

      Webpush.payload_send(
        message: { title: title, body: body, path: path, tag: tag }.to_json,
        endpoint: subscription.endpoint,
        p256dh: subscription.p256dh,
        auth: subscription.auth,
        vapid: {
          subject: ENV.fetch("VAPID_SUBJECT"),
          public_key: ENV.fetch("VAPID_PUBLIC_KEY"),
          private_key: ENV.fetch("VAPID_PRIVATE_KEY")
        }
      )
    rescue Webpush::ExpiredSubscription, Webpush::InvalidSubscription
      subscription.destroy!
    end

    def self.configured?
      ENV["VAPID_PUBLIC_KEY"].present? && ENV["VAPID_PRIVATE_KEY"].present? && ENV["VAPID_SUBJECT"].present?
    end
  end
end
