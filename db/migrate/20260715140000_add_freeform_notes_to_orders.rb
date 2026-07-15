class AddFreeformNotesToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :freeform_notes, :text
  end
end
