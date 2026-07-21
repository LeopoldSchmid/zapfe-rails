class AddSecurityControlsToAdminUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :admin_users, :role, :string, null: false, default: "owner"
    add_column :admin_users, :session_version, :integer, null: false, default: 1
    add_column :admin_users, :mfa_secret_ciphertext, :text
    add_column :admin_users, :mfa_recovery_code_digests, :json, null: false, default: []
    add_column :admin_users, :mfa_last_used_at, :integer
    add_column :admin_users, :mfa_enabled_at, :datetime
    add_column :admin_users, :last_signed_in_at, :datetime

    add_index :admin_users, :role
  end
end
