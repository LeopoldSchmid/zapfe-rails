class CreateProductVariants < ActiveRecord::Migration[8.1]
  def change
    create_table :product_variants do |t|
      t.references :product, null: false, foreign_key: true
      t.string :sku, null: false
      t.decimal :size, precision: 4, scale: 1, null: false
      t.decimal :price, precision: 10, scale: 2, null: false
      t.boolean :is_available, null: false, default: true
      t.string :availability, null: false, default: "Instant"

      t.timestamps
    end

    add_index :product_variants, :sku, unique: true
    add_index :product_variants, [ :product_id, :size ], unique: true
  end
end
