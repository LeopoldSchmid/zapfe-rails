class CreateCustomersAndContacts < ActiveRecord::Migration[8.1]
  def change
    create_table :customers do |t|
      t.string :name, null: false
      t.text :notes

      t.timestamps
    end
    add_index :customers, :name, unique: true

    create_table :contacts do |t|
      t.references :customer, null: false, foreign_key: true
      t.string :name, null: false
      t.string :role
      t.string :email
      t.string :phone
      t.boolean :primary, null: false, default: false

      t.timestamps
    end
    add_index :contacts, [ :customer_id, :name ]

    add_reference :orders, :customer, foreign_key: true
    add_reference :orders, :contact, foreign_key: true
  end
end
