class HelpRequest < ApplicationRecord
  STATUSES = %w[open resolved].freeze

  belongs_to :admin_user
  belongs_to :help_article, optional: true
  has_one_attached :screenshot

  validates :topic, :page_path, :subject, :message, presence: true
  validates :status, inclusion: { in: STATUSES }
  validate :acceptable_screenshot

  private

  def acceptable_screenshot
    return unless screenshot.attached?
    AttachmentSafety.validate(self, screenshot, allowed_types: AttachmentSafety::IMAGE_TYPES, max_bytes: 10.megabytes)
  end
end
