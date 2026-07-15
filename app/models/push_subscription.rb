class PushSubscription < ApplicationRecord
  belongs_to :admin_user

  validates :endpoint, :p256dh, :auth, presence: true
  validates :endpoint, uniqueness: true
end
