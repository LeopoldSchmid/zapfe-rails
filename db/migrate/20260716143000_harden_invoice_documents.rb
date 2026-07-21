class HardenInvoiceDocuments < ActiveRecord::Migration[8.1]
  def change
    create_table :invoice_sequences do |t|
      t.integer :year, null: false
      t.integer :next_value, null: false, default: 1
      t.timestamps

      t.index :year, unique: true
    end

    add_column :invoices, :document_sha256, :string
    add_column :invoices, :e_invoice_sha256, :string
    add_column :invoices, :invoice_type, :string, null: false, default: "invoice"
    add_reference :invoices, :correction_of, foreign_key: { to_table: :invoices }, index: true
  end
end
