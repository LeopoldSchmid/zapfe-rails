class AddProcurementPlanToTasks < ActiveRecord::Migration[8.1]
  def change
    add_reference :tasks, :procurement_plan, foreign_key: true
  end
end
