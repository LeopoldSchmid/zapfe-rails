class CreateInquiries < ActiveRecord::Migration[8.1]
  def change
    create_table :inquiries do |t|
      t.string :source, null: false
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false
      t.string :phone, null: false
      t.string :event_type
      t.date :event_date
      t.integer :guests
      t.text :message
      t.text :selected_options
      t.decimal :total_price, precision: 10, scale: 2
      t.text :pricing_snapshot
      t.boolean :privacy_accepted, null: false, default: false

      t.timestamps
    end

    add_index :inquiries, :source
    add_index :inquiries, :created_at
  end
end
