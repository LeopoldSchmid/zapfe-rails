class DocumentDelivery < ApplicationRecord
  STATUSES = %w[queued delivering delivered failed].freeze

  belongs_to :deliverable, polymorphic: true
  belongs_to :requested_by, class_name: "AdminUser"

  validates :recipient, :idempotency_key, :queued_at, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :idempotency_key, uniqueness: true

  scope :retryable, -> { where(status: %w[queued failed]) }

  def stable_message_id
    "<document-delivery-#{id}-#{idempotency_key.first(16)}@zapfe.jetzt>"
  end
end
