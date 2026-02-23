class Event < ApplicationRecord
  has_one_attached :image

  validates :title, presence: true
  validates :instagram_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) }, allow_blank: true

  scope :published, -> { where(published: true) }
  scope :ordered, -> { order(date_from: :asc, position: :asc, created_at: :desc) }
end
