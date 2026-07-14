class Activity < ApplicationRecord
  belongs_to :admin_user
  belongs_to :subject, polymorphic: true
  validates :event_type, :message, presence: true
end
