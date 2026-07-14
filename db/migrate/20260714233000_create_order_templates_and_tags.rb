class CreateOrderTemplatesAndTags < ActiveRecord::Migration[8.1]
  def change
    create_table :tags do |t|
      t.string :name, null: false
      t.timestamps
    end
    add_index :tags, :name, unique: true

    create_table :taggings do |t|
      t.references :tag, null: false, foreign_key: true
      t.references :taggable, null: false, polymorphic: true
      t.timestamps
    end
    add_index :taggings, [ :tag_id, :taggable_type, :taggable_id ], unique: true

    create_table :order_templates do |t|
      t.string :name, null: false
      t.boolean :active, null: false, default: true
      t.references :responsible_admin_user, foreign_key: { to_table: :admin_users }
      t.string :event_type
      t.string :event_location
      t.integer :guests
      t.text :customer_message
      t.text :next_step
      t.boolean :skip_offer, null: false, default: false
      t.date :starts_on
      t.date :ends_on
      t.string :start_time
      t.string :end_time
      t.timestamps
    end

    create_table :order_template_resources do |t|
      t.references :order_template, null: false, foreign_key: true
      t.references :resource, null: false, foreign_key: true
      t.timestamps
    end
    add_index :order_template_resources, [ :order_template_id, :resource_id ], unique: true

    create_table :order_template_tasks do |t|
      t.references :order_template, null: false, foreign_key: true
      t.references :assigned_admin_user, foreign_key: { to_table: :admin_users }
      t.string :title, null: false
      t.text :details
      t.integer :relative_offset_days
      t.integer :position, null: false, default: 0
      t.timestamps
    end

    create_table :order_template_checklists do |t|
      t.references :order_template, null: false, foreign_key: true
      t.references :checklist_template, null: false, foreign_key: true
      t.timestamps
    end
    add_index :order_template_checklists, [ :order_template_id, :checklist_template_id ], unique: true, name: "idx_order_template_checklists_unique"
  end
end
