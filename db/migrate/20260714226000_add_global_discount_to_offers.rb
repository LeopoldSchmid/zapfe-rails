class AddGlobalDiscountToOffers < ActiveRecord::Migration[8.1]
  def change
    add_column :offers, :global_discount_type, :string, null: false, default: "none"
    add_column :offers, :global_discount_value, :decimal, precision: 10, scale: 2, null: false, default: 0
    add_column :offers, :global_discount_reason, :string
  end
end
