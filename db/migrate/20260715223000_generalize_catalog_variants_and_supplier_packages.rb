class GeneralizeCatalogVariantsAndSupplierPackages < ActiveRecord::Migration[8.1]
  def change
    add_column :product_variants, :label, :string
    add_column :product_variants, :unit, :string, null: false, default: "l"
    add_column :product_variants, :sales_unit, :string, null: false, default: "Fass"

    remove_index :product_variants, name: "index_product_variants_on_product_id_and_size"
    add_index :product_variants, [ :product_id, :size, :unit ], unique: true

    add_column :supplier_offerings, :package_unit, :string, null: false, default: "Fass"
    add_column :supplier_offerings, :package_quantity, :decimal, precision: 10, scale: 2, null: false, default: 1
  end
end
