class CreateSupplierCatalog < ActiveRecord::Migration[8.1]
  def change
    create_table :suppliers do |t|
      t.string :name, null: false
      t.string :email
      t.string :phone
      t.text :notes
      t.boolean :active, null: false, default: true
      t.boolean :default_supplier, null: false, default: false

      t.timestamps
    end
    add_index :suppliers, :name, unique: true

    create_table :procurement_profiles do |t|
      t.references :supplier, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :lead_time_days, null: false, default: 0
      t.string :return_policy, null: false, default: "unknown"
      t.text :delivery_notes
      t.text :cancellation_notes

      t.timestamps
    end
    add_index :procurement_profiles, [ :supplier_id, :name ], unique: true

    create_table :supplier_offerings do |t|
      t.references :supplier, null: false, foreign_key: true
      t.references :product_variant, null: false, foreign_key: true
      t.references :procurement_profile, null: false, foreign_key: true
      t.string :supplier_sku
      t.boolean :active, null: false, default: true
      t.integer :lead_time_days_override
      t.string :return_policy_override
      t.text :notes

      t.timestamps
    end
    add_index :supplier_offerings, [ :supplier_id, :product_variant_id ], unique: true

    create_table :supplier_prices do |t|
      t.references :supplier_offering, null: false, foreign_key: true
      t.decimal :purchase_price, precision: 10, scale: 2, null: false
      t.date :valid_from, null: false
      t.date :valid_until

      t.timestamps
    end
    add_index :supplier_prices, [ :supplier_offering_id, :valid_from ], unique: true
  end
end
