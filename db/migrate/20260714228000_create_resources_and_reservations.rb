class CreateResourcesAndReservations < ActiveRecord::Migration[8.1]
  def change
    create_table :resources do |t|
      t.string :name, null: false
      t.string :resource_type, null: false
      t.boolean :active, null: false, default: true
      t.text :configuration_notes

      t.timestamps
    end
    add_index :resources, :name, unique: true
    add_index :resources, :resource_type

    create_table :reservations do |t|
      t.references :resource, null: false, foreign_key: true
      t.references :order, null: false, foreign_key: true
      t.references :offer, foreign_key: true
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.text :note

      t.timestamps
    end
    add_index :reservations, [ :resource_id, :starts_at, :ends_at ]
    add_index :reservations, [ :order_id, :starts_at ]
  end
end
