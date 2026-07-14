class CreateSystemSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :system_settings do |t|
      t.decimal :standard_tax_rate, precision: 5, scale: 2, null: false, default: 19
      t.decimal :internal_hourly_cost, precision: 10, scale: 2

      t.timestamps
    end
  end
end
