class AddCockpitFieldsToAdminUsersAndInquiries < ActiveRecord::Migration[8.1]
  def change
    add_column :admin_users, :name, :string, null: false, default: "Unbekannt"
    add_column :admin_users, :active, :boolean, null: false, default: true
    add_column :admin_users, :phone, :string
    add_column :admin_users, :email_signature, :text
    add_column :admin_users, :notification_preferences, :json, null: false, default: {}

    change_table :inquiries, bulk: true do |t|
      t.references :assigned_admin_user, foreign_key: { to_table: :admin_users }
      t.string :status, null: false, default: "new"
      t.text :next_step
      t.date :next_step_due_on
      t.string :closure_reason
    end

    add_index :inquiries, :status
    add_index :inquiries, :next_step_due_on
  end
end
