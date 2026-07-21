class PrivacyLegalHold < ApplicationRecord
  belongs_to :created_by, class_name: "AdminUser"
  belongs_to :released_by, class_name: "AdminUser", optional: true

  validates :subject_digest, :reason, presence: true

  scope :active, -> { where(released_at: nil).where("expires_at IS NULL OR expires_at > ?", Time.current) }

  def self.for_email(email)
    active.where(subject_digest: Privacy::SubjectData.digest(email))
  end

  def release!(by:)
    update!(released_at: Time.current, released_by: by)
  end
end
