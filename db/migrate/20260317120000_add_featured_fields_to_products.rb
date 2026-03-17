class AddFeaturedFieldsToProducts < ActiveRecord::Migration[8.1]
  def change
    add_column :products, :featured, :boolean, null: false, default: false
    add_column :products, :featured_position, :integer
    add_column :products, :featured_note, :string

    add_index :products, :featured
    add_index :products, [ :featured, :featured_position ]
  end
end
