class CreateChecklists < ActiveRecord::Migration[8.1]
  def change
    create_table :checklist_templates do |t|
      t.string :name, null: false
      t.string :resource_type
      t.string :section, null: false
      t.boolean :active, null: false, default: true

      t.timestamps
    end
    add_index :checklist_templates, [ :resource_type, :section ]

    create_table :checklist_template_items do |t|
      t.references :checklist_template, null: false, foreign_key: true
      t.string :title, null: false
      t.text :instructions
      t.string :link_url
      t.string :video_url
      t.text :notes
      t.integer :position, null: false, default: 0

      t.timestamps
    end
    add_index :checklist_template_items, [ :checklist_template_id, :position ]

    create_table :order_checklists do |t|
      t.references :order, null: false, foreign_key: true
      t.references :checklist_template, foreign_key: true
      t.string :name, null: false
      t.string :section, null: false
      t.string :status, null: false, default: "open"

      t.timestamps
    end
    add_index :order_checklists, [ :order_id, :status ]

    create_table :order_checklist_items do |t|
      t.references :order_checklist, null: false, foreign_key: true
      t.references :checklist_template_item, foreign_key: true
      t.string :title, null: false
      t.text :instructions
      t.string :link_url
      t.string :video_url
      t.text :notes
      t.integer :position, null: false, default: 0
      t.boolean :completed, null: false, default: false
      t.datetime :completed_at

      t.timestamps
    end
    add_index :order_checklist_items, [ :order_checklist_id, :position ]
  end
end
