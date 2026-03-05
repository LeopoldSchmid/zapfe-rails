class AddStructuredFieldsToInquiries < ActiveRecord::Migration[8.1]
  def change
    change_table :inquiries, bulk: true do |t|
      t.string :rental_mode
      t.integer :rental_days
      t.date :starts_on
      t.date :ends_on
      t.string :start_time
      t.string :end_time
      t.string :delivery_street
      t.string :delivery_postcode
      t.string :delivery_city
      t.boolean :bring_own_drinks, null: false, default: false
      t.boolean :glasses_requested, null: false, default: false
    end

    add_index :inquiries, :starts_on
    add_index :inquiries, :rental_mode
  end
end
