class PushSubscription < ApplicationRecord
  belongs_to :admin_user
  has_many :notification_deliveries, class_name: "PushNotificationDelivery", dependent: :destroy

  validates :endpoint, :p256dh, :auth, presence: true
  validates :endpoint, uniqueness: true
end
