class CreateInvoices < ActiveRecord::Migration[8.1]
  def change
    create_table :invoices do |t|
      t.references :order, null: false, foreign_key: true
      t.references :offer, foreign_key: true
      t.string :invoice_number
      t.string :status, null: false, default: "draft"
      t.string :recipient_name, null: false
      t.string :recipient_email
      t.text :recipient_address
      t.date :delivery_on
      t.date :due_on
      t.date :issue_date
      t.string :global_discount_type, null: false, default: "none"
      t.decimal :global_discount_value, precision: 10, scale: 2, null: false, default: 0
      t.string :global_discount_reason
      t.text :internal_note
      t.text :document_snapshot
      t.datetime :finalized_at
      t.datetime :sent_at
      t.datetime :paid_at
      t.datetime :cancelled_at
      t.timestamps
    end
    add_index :invoices, :invoice_number, unique: true
    add_index :invoices, :status

    create_table :invoice_line_items do |t|
      t.references :invoice, null: false, foreign_key: true
      t.string :description, null: false
      t.decimal :quantity, precision: 10, scale: 2, null: false, default: 1
      t.string :unit, null: false, default: "Stk"
      t.decimal :net_unit_price, precision: 10, scale: 2, null: false, default: 0
      t.string :discount_type, null: false, default: "none"
      t.decimal :discount_value, precision: 10, scale: 2, null: false, default: 0
      t.string :discount_reason
      t.decimal :tax_rate, precision: 5, scale: 2, null: false, default: 19
      t.integer :position, null: false, default: 0
      t.timestamps
    end
    add_index :invoice_line_items, [ :invoice_id, :position ]
  end
end
