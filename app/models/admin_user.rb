class AdminUser < ApplicationRecord
  has_secure_password
  generates_token_for :password_reset, expires_in: 30.minutes do
    password_salt&.last(10)
  end

  normalizes :email, with: ->(value) { value.to_s.strip.downcase }

  scope :active, -> { where(active: true) }

  has_many :assigned_inquiries, class_name: "Inquiry", foreign_key: :assigned_admin_user_id, inverse_of: :assigned_admin_user, dependent: :restrict_with_error
  has_many :responsible_orders, class_name: "Order", foreign_key: :responsible_admin_user_id, inverse_of: :responsible_admin_user, dependent: :restrict_with_error
  has_many :activities, dependent: :restrict_with_error
  has_many :help_requests, dependent: :restrict_with_error
  has_many :push_subscriptions, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validate :cannot_deactivate_last_active_admin, if: :deactivating?

  def active?
    active
  end

  private

  def deactivating?
    will_save_change_to_active? && !active?
  end

  def cannot_deactivate_last_active_admin
    return if AdminUser.active.where.not(id: id).exists?

    errors.add(:active, "muss für mindestens ein Admin-Konto aktiv bleiben")
  end
end
