class AdminSecurityEvent < ApplicationRecord
  belongs_to :actor_admin_user, class_name: "AdminUser", optional: true
  belongs_to :target_admin_user, class_name: "AdminUser", optional: true

  validates :event_type, presence: true, inclusion: { in: AdminSecurity::Audit::EVENT_TYPES }

  before_update { throw :abort }
  before_destroy { throw :abort }
end
