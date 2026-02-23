class Inquiry < ApplicationRecord
  SOURCES = %w[contact calculator].freeze

  validates :source, inclusion: { in: SOURCES }
  validates :first_name, :last_name, :email, :phone, presence: true
  validates :privacy_accepted, acceptance: true
end
