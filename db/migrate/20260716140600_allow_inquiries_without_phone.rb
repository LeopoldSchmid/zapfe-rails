class AllowInquiriesWithoutPhone < ActiveRecord::Migration[8.1]
  def change
    change_column_null :inquiries, :phone, true
  end
end
