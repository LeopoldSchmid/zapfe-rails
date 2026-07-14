class CreateOffers < ActiveRecord::Migration[8.1]
  def change
    create_table :offers do |t|
      t.references :order, null: false, foreign_key: true
      t.integer :version, null: false, default: 1
      t.string :status, null: false, default: "draft"
      t.date :valid_until, null: false
      t.string :recipient_name, null: false
      t.string :recipient_email
      t.text :recipient_address
      t.text :internal_note
      t.datetime :finalized_at
      t.datetime :sent_at

      t.timestamps
    end
    add_index :offers, [ :order_id, :version ], unique: true
    add_index :offers, :status

    create_table :offer_line_items do |t|
      t.references :offer, null: false, foreign_key: true
      t.references :product_variant, foreign_key: true
      t.references :supplier_offering, foreign_key: true
      t.string :position_type, null: false, default: "free"
      t.string :description, null: false
      t.decimal :quantity, precision: 10, scale: 2, null: false, default: 1
      t.string :unit, null: false, default: "Stk"
      t.decimal :net_unit_price, precision: 10, scale: 2, null: false, default: 0
      t.string :discount_type, null: false, default: "none"
      t.decimal :discount_value, precision: 10, scale: 2, null: false, default: 0
      t.string :discount_reason
      t.text :internal_note
      t.decimal :tax_rate, precision: 5, scale: 2, null: false, default: 19
      t.decimal :direct_cost_unit, precision: 10, scale: 2
      t.integer :position, null: false, default: 0

      t.timestamps
    end
    add_index :offer_line_items, [ :offer_id, :position ]
  end
end
