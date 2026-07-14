class AllowOrdersWithoutEventDate < ActiveRecord::Migration[8.1]
  def change
    change_column_null :orders, :event_date, true
  end
end
