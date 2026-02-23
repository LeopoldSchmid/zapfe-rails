class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.references :category, foreign_key: true
      t.string :article_number, null: false
      t.string :name, null: false
      t.string :brand, null: false
      t.string :kind, null: false
      t.string :subcategory
      t.decimal :alcohol_content, precision: 3, scale: 1
      t.boolean :is_alcoholic, null: false, default: true
      t.text :description

      t.timestamps
    end

    add_index :products, :article_number, unique: true
    add_index :products, [ :brand, :name ]
    add_index :products, :kind
  end
end
