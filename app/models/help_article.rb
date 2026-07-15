class HelpArticle < ApplicationRecord
  has_rich_text :body
  has_many :faqs, -> { order(:position, :id) }, class_name: "HelpFaq", dependent: :destroy
  has_many :help_requests, dependent: :nullify

  accepts_nested_attributes_for :faqs, allow_destroy: true, reject_if: ->(attributes) { attributes["question"].blank? && attributes["answer"].blank? }

  validates :topic, :title, presence: true
  validates :topic, uniqueness: true
end
