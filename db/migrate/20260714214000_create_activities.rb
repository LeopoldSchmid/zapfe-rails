class CreateActivities < ActiveRecord::Migration[8.1]
  def change
    create_table :activities do |t|
      t.references :admin_user, null: false, foreign_key: true
      t.references :subject, null: false, polymorphic: true
      t.string :event_type, null: false
      t.text :message, null: false
      t.json :metadata, null: false, default: {}
      t.timestamps
    end
    add_index :activities, [ :subject_type, :subject_id, :created_at ]
  end
end
