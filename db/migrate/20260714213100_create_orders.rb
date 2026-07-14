class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.references :inquiry, foreign_key: true, index: { unique: true }
      t.references :responsible_admin_user, null: false, foreign_key: { to_table: :admin_users }
      t.string :status, null: false, default: "preparing"
      t.string :customer_name, null: false
      t.string :customer_email
      t.string :customer_phone
      t.string :event_type
      t.date :event_date
      t.date :starts_on
      t.date :ends_on
      t.string :start_time
      t.string :end_time
      t.string :event_location, null: false
      t.integer :guests
      t.text :customer_message
      t.text :inquiry_pricing_snapshot
      t.text :next_step
      t.date :next_step_due_on

      t.timestamps
    end

    add_index :orders, :status
    add_index :orders, :event_date
    add_index :orders, :next_step_due_on
  end
end
