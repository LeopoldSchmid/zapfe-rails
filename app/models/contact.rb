class Contact < ApplicationRecord
  belongs_to :customer
  has_many :orders, dependent: :nullify

  validates :name, presence: true
  after_save :clear_other_primary_contacts, if: :primary?

  private
  def clear_other_primary_contacts
    customer.contacts.where.not(id: id).update_all(primary: false, updated_at: Time.current)
  end
end
