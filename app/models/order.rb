class Order < ApplicationRecord
  STATUSES = %w[preparing offered confirmed in_progress completed cancelled].freeze

  belongs_to :inquiry, optional: true
  belongs_to :responsible_admin_user, class_name: "AdminUser", inverse_of: :responsible_orders
  has_many :activities, as: :subject, dependent: :destroy
  has_many :offers, dependent: :destroy
  has_many :invoices, dependent: :destroy
  has_many :time_entries, dependent: :destroy
  has_many :reservations, dependent: :destroy
  has_many :tasks, dependent: :destroy
  has_many :procurement_plans, dependent: :destroy
  has_many :checklists, class_name: "OrderChecklist", dependent: :destroy
  has_many :taggings, as: :taggable, dependent: :destroy
  has_many :tags, through: :taggings
  has_many :product_selections, class_name: "OrderProductSelection", dependent: :destroy
  has_rich_text :freeform_notes

  after_update_commit :recalculate_relative_task_dates, if: :saved_change_to_event_date?
  has_many_attached :attachments

  validate :attachments_are_safe

  validates :status, inclusion: { in: STATUSES }
  validates :customer_name, :event_location, presence: true

  def archived?
    archived_at.present?
  end

  private

  def recalculate_relative_task_dates
    tasks.find_each(&:recalculate_due_on!)
  end

  def attachments_are_safe
    attachments.each do |attachment|
      errors.add(:attachments, "dürfen höchstens 25 MB groß sein") if attachment.byte_size > 25.megabytes
      errors.add(:attachments, "müssen PDF- oder Bilddateien sein") unless attachment.content_type.in?(%w[application/pdf image/jpeg image/png image/webp])
    end
  end
end
