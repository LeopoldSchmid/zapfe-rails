class AdminUser < ApplicationRecord
  has_secure_password
  generates_token_for :password_reset, expires_in: 30.minutes do
    password_salt&.last(10)
  end

  normalizes :email, with: ->(value) { value.to_s.strip.downcase }

  validates :email, presence: true, uniqueness: true
end
