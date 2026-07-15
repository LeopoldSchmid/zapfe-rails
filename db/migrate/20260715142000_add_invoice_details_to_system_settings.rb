class AddInvoiceDetailsToSystemSettings < ActiveRecord::Migration[8.1]
  def change
    add_column :system_settings, :company_name, :string, default: "Ape2tap UG"
    add_column :system_settings, :company_address, :text, default: "Habsburgerstraße 38\n79104 Freiburg"
    add_column :system_settings, :vat_id, :string, default: "DE369035041"
    add_column :system_settings, :bank_name, :string, default: "Finom PAYMENTS B.V."
    add_column :system_settings, :iban, :string, default: "DE61100180000698968244"
    add_column :system_settings, :bic, :string, default: "FNOMDEB2XXXX"
    add_column :system_settings, :payment_terms_days, :integer, null: false, default: 14
  end
end
