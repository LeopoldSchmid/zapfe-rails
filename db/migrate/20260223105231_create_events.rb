class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.string :title, null: false
      t.string :subtitle
      t.text :description
      t.date :date_from
      t.date :date_to
      t.string :location
      t.string :instagram_url
      t.integer :position, null: false, default: 0
      t.boolean :published, null: false, default: true

      t.timestamps
    end

    add_index :events, :date_from
    add_index :events, :position
    add_index :events, :published
  end
end
