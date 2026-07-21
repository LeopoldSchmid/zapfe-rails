class PushNotificationDelivery < ApplicationRecord
  STATUSES = %w[queued delivering delivered failed].freeze

  belongs_to :task
  belongs_to :push_subscription

  validates :kind, :notification_on, presence: true
  validates :status, inclusion: { in: STATUSES }
end
