class AddReturnPeriodsToProcurementConditions < ActiveRecord::Migration[8.1]
  def change
    add_column :procurement_profiles, :return_period_days, :integer
    add_column :supplier_offerings, :return_period_days_override, :integer
    add_column :procurement_plan_items, :return_period_days, :integer
  end
end
