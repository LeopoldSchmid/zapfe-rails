class MakeProcurementProfilesReusable < ActiveRecord::Migration[8.1]
  def change
    remove_index :procurement_profiles, column: [ :supplier_id, :name ]
    change_column_null :procurement_profiles, :supplier_id, true
    add_column :procurement_profiles, :standard, :boolean, null: false, default: false
    add_index :procurement_profiles, [ :supplier_id, :name ], unique: true
    add_index :procurement_profiles, :name, unique: true, where: "standard = 1", name: "idx_standard_procurement_profiles_name"
  end
end
