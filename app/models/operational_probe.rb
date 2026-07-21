class OperationalProbe < ApplicationRecord
  validates :nonce, presence: true, uniqueness: true
end
