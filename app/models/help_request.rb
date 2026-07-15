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
    return if screenshot.content_type.in?(%w[image/png image/jpeg image/webp])

    errors.add(:screenshot, "muss ein PNG-, JPG- oder WebP-Bild sein")
  end
end
