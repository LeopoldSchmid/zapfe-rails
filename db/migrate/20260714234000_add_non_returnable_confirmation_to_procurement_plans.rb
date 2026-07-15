class AddNonReturnableConfirmationToProcurementPlans < ActiveRecord::Migration[8.1]
  def change
    add_column :procurement_plans, :non_returnable_confirmed_at, :datetime
    add_reference :procurement_plans, :non_returnable_confirmed_by, foreign_key: { to_table: :admin_users }
  end
end
