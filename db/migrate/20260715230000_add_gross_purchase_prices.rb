class AddGrossPurchasePrices < ActiveRecord::Migration[8.1]
  def up
    add_column :supplier_prices, :gross_purchase_price, :decimal, precision: 10, scale: 2
    add_column :supplier_prices, :tax_rate, :decimal, precision: 5, scale: 2, null: false, default: 19

    execute <<~SQL.squish
      UPDATE supplier_prices
      SET gross_purchase_price = ROUND(purchase_price * 1.19, 2)
      WHERE gross_purchase_price IS NULL
    SQL

    change_column_null :supplier_prices, :gross_purchase_price, false
  end

  def down
    remove_column :supplier_prices, :tax_rate
    remove_column :supplier_prices, :gross_purchase_price
  end
end
