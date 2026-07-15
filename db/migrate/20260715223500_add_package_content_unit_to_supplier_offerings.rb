class AddPackageContentUnitToSupplierOfferings < ActiveRecord::Migration[8.1]
  def change
    add_column :supplier_offerings, :package_content_unit, :string, null: false, default: "Stk"
  end
end
