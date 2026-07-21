class PrivacyErasureTombstone < ApplicationRecord
  belongs_to :performed_by, class_name: "AdminUser"

  validates :subject_digest, :erased_at, presence: true

  before_update { throw :abort }
  before_destroy { throw :abort }
end
