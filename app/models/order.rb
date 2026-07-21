class Order < ApplicationRecord
  include TransitionPolicy

  STATUSES = %w[preparing offered confirmed in_progress completed cancelled].freeze
  allows_status_transitions(
    "preparing" => %w[offered confirmed cancelled],
    "offered" => %w[preparing confirmed cancelled],
    "confirmed" => %w[in_progress cancelled],
    "in_progress" => %w[confirmed completed cancelled],
    "completed" => [],
    "cancelled" => []
  )

  belongs_to :inquiry, optional: true
  belongs_to :customer, optional: true
  belongs_to :contact, optional: true
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
  validate :contact_belongs_to_customer

  before_validation :apply_selected_contact

  def archived?
    archived_at.present?
  end

  private

  def apply_selected_contact
    self.customer ||= contact&.customer
    return unless customer_id_changed? || contact_id_changed?

    self.customer_name = customer.name if customer.present?
    return unless contact.present?

    self.customer_email = contact.email if contact.email.present?
    self.customer_phone = contact.phone if contact.phone.present?
  end

  def contact_belongs_to_customer
    return if contact.blank? || customer.blank? || contact.customer_id == customer_id

    errors.add(:contact, "muss zum gewählten Kunden gehören")
  end

  def recalculate_relative_task_dates
    tasks.find_each(&:recalculate_due_on!)
  end

  def attachments_are_safe
    attachments.each do |attachment|
      AttachmentSafety.validate(self, attachment)
    end
  end
end
