class CreateCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.string :kind, null: false
      t.text :description

      t.timestamps
    end

    add_index :categories, :name, unique: true
    add_index :categories, :kind
  end
end
