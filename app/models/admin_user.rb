class AdminUser < ApplicationRecord
  PASSWORD_MINIMUM_LENGTH = 14
  COMMON_PASSWORDS = %w[
    password password123 passwort passwort123 admin administrator
    qwerty123456 letmein123456 welcome123456 changeme123456
  ].freeze

  has_secure_password
  generates_token_for :password_reset, expires_in: 30.minutes do
    password_salt&.last(10)
  end

  normalizes :email, with: ->(value) { value.to_s.strip.downcase }

  scope :active, -> { where(active: true) }

  enum :role, { member: "member", admin: "admin", owner: "owner" }, validate: true

  has_many :assigned_inquiries, class_name: "Inquiry", foreign_key: :assigned_admin_user_id, inverse_of: :assigned_admin_user, dependent: :restrict_with_error
  has_many :responsible_orders, class_name: "Order", foreign_key: :responsible_admin_user_id, inverse_of: :responsible_admin_user, dependent: :restrict_with_error
  has_many :activities, dependent: :restrict_with_error
  has_many :help_requests, dependent: :restrict_with_error
  has_many :push_subscriptions, dependent: :destroy
  has_many :security_events_as_actor, class_name: "AdminSecurityEvent", foreign_key: :actor_admin_user_id, dependent: :nullify
  has_many :security_events_as_target, class_name: "AdminSecurityEvent", foreign_key: :target_admin_user_id, dependent: :nullify

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :password, length: { minimum: PASSWORD_MINIMUM_LENGTH }, if: -> { password.present? }
  validate :password_is_not_common, if: -> { password.present? }
  validate :cannot_deactivate_last_active_admin, if: :deactivating?
  validate :cannot_remove_last_active_owner, if: :removing_owner_access?

  before_update :rotate_session_version, if: :security_state_changing?
  after_update :remove_push_subscriptions_after_offboarding, if: :saved_change_to_active?

  def active?
    active
  end

  def mfa_enabled?
    mfa_enabled_at.present? && mfa_secret_ciphertext.present?
  end

  def mfa_secret
    return if mfa_secret_ciphertext.blank?

    AdminSecurity::SecretCipher.decrypt(mfa_secret_ciphertext)
  rescue ActiveSupport::MessageEncryptor::InvalidMessage
    nil
  end

  def enable_mfa!(secret:, recovery_codes:)
    update!(
      mfa_secret_ciphertext: AdminSecurity::SecretCipher.encrypt(secret),
      mfa_recovery_code_digests: recovery_codes.map { |code| AdminSecurity::RecoveryCodes.digest(code) },
      mfa_last_used_at: nil,
      mfa_enabled_at: Time.current
    )
  end

  def reset_mfa!
    update!(mfa_secret_ciphertext: nil, mfa_recovery_code_digests: [], mfa_last_used_at: nil, mfa_enabled_at: nil)
  end

  def verify_mfa_code(code, at: Time.current)
    return unless mfa_enabled?

    secret = mfa_secret
    return if secret.blank?

    normalized_code = code.to_s.delete(" ")
    timestamp = ROTP::TOTP.new(secret, issuer: "Zapfe Admin").verify(
      normalized_code,
      drift_behind: 30,
      drift_ahead: 30,
      after: mfa_last_used_at,
      at: at
    )
    if timestamp
      update_column(:mfa_last_used_at, timestamp)
      return :totp
    end

    consume_recovery_code(normalized_code) ? :recovery : nil
  end

  def provisioning_uri(secret)
    ROTP::TOTP.new(secret, issuer: "Zapfe Admin").provisioning_uri(email)
  end

  def recovery_codes_remaining
    mfa_recovery_code_digests.size
  end

  private

  def consume_recovery_code(code)
    digest = AdminSecurity::RecoveryCodes.digest(code)
    consumed = false

    with_lock do
      codes = mfa_recovery_code_digests.dup
      index = codes.index { |stored| ActiveSupport::SecurityUtils.secure_compare(stored, digest) }
      if index
        codes.delete_at(index)
        update_column(:mfa_recovery_code_digests, codes)
        consumed = true
      end
    end

    consumed
  end

  def password_is_not_common
    normalized = password.to_s.downcase.gsub(/[^a-z0-9]/, "")
    email_local_part = email.to_s.split("@").first.to_s.downcase.gsub(/[^a-z0-9]/, "")
    name_part = name.to_s.downcase.gsub(/[^a-z0-9]/, "")

    if COMMON_PASSWORDS.include?(normalized) ||
        (email_local_part.length >= 4 && normalized.include?(email_local_part)) ||
        (name_part.length >= 4 && normalized.include?(name_part))
      errors.add(:password, "ist zu leicht zu erraten oder bereits als häufiges Passwort bekannt")
    end
  end

  def security_state_changing?
    will_save_change_to_password_digest? || will_save_change_to_role? ||
      will_save_change_to_active? || will_save_change_to_mfa_secret_ciphertext?
  end

  def rotate_session_version
    self.session_version += 1
  end

  def remove_push_subscriptions_after_offboarding
    push_subscriptions.destroy_all unless active?
  end

  def deactivating?
    will_save_change_to_active? && !active?
  end

  def cannot_deactivate_last_active_admin
    return if AdminUser.active.where.not(id: id).exists?

    errors.add(:active, "muss für mindestens ein Admin-Konto aktiv bleiben")
  end

  def removing_owner_access?
    persisted? && role_in_database == "owner" && (deactivating? || will_save_change_to_role?)
  end

  def cannot_remove_last_active_owner
    return if AdminUser.active.owner.where.not(id: id).exists?

    errors.add(:role, "muss für mindestens ein aktives Owner-Konto erhalten bleiben")
  end
end
