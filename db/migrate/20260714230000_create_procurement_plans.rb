class CreateProcurementPlans < ActiveRecord::Migration[8.1]
  def change
    create_table :procurement_plans do |t|
      t.references :order, null: false, foreign_key: true
      t.references :offer, foreign_key: true
      t.string :status, null: false, default: "planned"
      t.date :order_by_on
      t.text :notes

      t.timestamps
    end
    add_index :procurement_plans, [ :order_id, :status ]

    create_table :procurement_plan_items do |t|
      t.references :procurement_plan, null: false, foreign_key: true
      t.references :offer_line_item, foreign_key: true
      t.references :supplier_offering, foreign_key: true
      t.string :description, null: false
      t.decimal :quantity, precision: 10, scale: 2, null: false
      t.string :unit, null: false
      t.decimal :purchase_price, precision: 10, scale: 2
      t.integer :lead_time_days
      t.string :return_policy
      t.date :order_by_on
      t.text :notes

      t.timestamps
    end
    add_index :procurement_plan_items, :order_by_on
  end
end
