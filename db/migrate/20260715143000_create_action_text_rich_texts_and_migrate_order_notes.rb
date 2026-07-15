class CreateActionTextRichTextsAndMigrateOrderNotes < ActiveRecord::Migration[8.1]
  class MigrationOrder < ActiveRecord::Base
    self.table_name = "orders"
  end

  class MigrationRichText < ActiveRecord::Base
    self.table_name = "action_text_rich_texts"
  end

  def up
    create_table :action_text_rich_texts do |t|
      t.string :name, null: false
      t.text :body
      t.references :record, null: false, polymorphic: true, index: false
      t.timestamps
      t.index [ :record_type, :record_id, :name ], name: "index_action_text_rich_texts_uniqueness", unique: true
    end

    MigrationOrder.where.not(freeform_notes: [ nil, "" ]).find_each do |order|
      MigrationRichText.create!(record_type: "Order", record_id: order.id, name: "freeform_notes", body: order.freeform_notes, created_at: Time.current, updated_at: Time.current)
    end
    remove_column :orders, :freeform_notes
  end

  def down
    add_column :orders, :freeform_notes, :text
    MigrationRichText.where(record_type: "Order", name: "freeform_notes").find_each do |rich_text|
      MigrationOrder.where(id: rich_text.record_id).update_all(freeform_notes: rich_text.body)
    end
    drop_table :action_text_rich_texts
  end
end
