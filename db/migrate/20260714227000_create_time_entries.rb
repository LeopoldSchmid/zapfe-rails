class CreateTimeEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :time_entries do |t|
      t.references :order, null: false, foreign_key: true
      t.references :offer, foreign_key: true
      t.references :admin_user, foreign_key: true
      t.string :entry_type, null: false
      t.string :category, null: false
      t.integer :minutes, null: false
      t.decimal :hourly_cost, precision: 10, scale: 2, null: false
      t.date :recorded_on
      t.text :note

      t.timestamps
    end
    add_index :time_entries, [ :offer_id, :entry_type ]
    add_index :time_entries, [ :order_id, :entry_type ]
  end
end
