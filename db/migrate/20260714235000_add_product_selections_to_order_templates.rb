class AddProductSelectionsToOrderTemplates < ActiveRecord::Migration[8.1]
  def change
    create_table :order_template_product_variants do |t|
      t.references :order_template, null: false, foreign_key: true
      t.references :product_variant, null: false, foreign_key: true
      t.decimal :quantity, precision: 10, scale: 2, null: false, default: 1
      t.string :unit, null: false, default: "Stk"
      t.timestamps
    end
    add_index :order_template_product_variants, [ :order_template_id, :product_variant_id ], unique: true, name: "idx_template_product_variants_unique"

    create_table :order_product_selections do |t|
      t.references :order, null: false, foreign_key: true
      t.references :product_variant, null: false, foreign_key: true
      t.decimal :quantity, precision: 10, scale: 2, null: false, default: 1
      t.string :unit, null: false, default: "Stk"
      t.timestamps
    end
    add_index :order_product_selections, [ :order_id, :product_variant_id ], unique: true, name: "idx_order_product_selections_unique"
  end
end
