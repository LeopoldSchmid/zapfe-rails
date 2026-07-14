class AddFinalizationToOffers < ActiveRecord::Migration[8.1]
  def change
    add_column :offers, :offer_number, :string
    add_column :offers, :document_snapshot, :text
    add_index :offers, :offer_number, unique: true
  end
end
