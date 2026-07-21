class CreateAdminSecurityEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :admin_security_events do |t|
      t.references :actor_admin_user, foreign_key: { to_table: :admin_users }
      t.references :target_admin_user, foreign_key: { to_table: :admin_users }
      t.string :event_type, null: false
      t.string :request_id
      t.string :ip_address_digest
      t.string :user_agent_family
      t.json :metadata, null: false, default: {}
      t.timestamps
    end

    add_index :admin_security_events, [ :event_type, :created_at ]
    add_index :admin_security_events, :request_id
  end
end
