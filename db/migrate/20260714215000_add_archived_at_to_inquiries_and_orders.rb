class AddArchivedAtToInquiriesAndOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :inquiries, :archived_at, :datetime
    add_column :orders, :archived_at, :datetime
    add_index :inquiries, :archived_at
    add_index :orders, :archived_at
  end
end
