class Customer < ApplicationRecord
  has_many :contacts, dependent: :destroy
  has_many :orders, dependent: :nullify

  accepts_nested_attributes_for :contacts, allow_destroy: true, reject_if: ->(attributes) { attributes["name"].blank? }

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  def primary_contact
    contacts.find(&:primary?) || contacts.first
  end
end
