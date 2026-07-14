class CreateTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :tasks do |t|
      t.references :order, null: false, foreign_key: true
      t.references :assigned_admin_user, foreign_key: { to_table: :admin_users }
      t.string :title, null: false
      t.text :details
      t.string :status, null: false, default: "open"
      t.date :due_on
      t.string :relative_anchor
      t.integer :relative_offset_days
      t.datetime :completed_at

      t.timestamps
    end
    add_index :tasks, [ :order_id, :status ]
    add_index :tasks, :due_on
  end
end
