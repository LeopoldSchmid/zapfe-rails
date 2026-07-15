class AddRentalPositionToResourcesAndOffers < ActiveRecord::Migration[8.1]
  def change
    add_column :resources, :rental_position_name, :string
    add_column :resources, :rental_net_price, :decimal, precision: 10, scale: 2
    add_column :resources, :rental_unit, :string, null: false, default: "Tag"
    add_reference :offer_line_items, :resource, foreign_key: true
  end
end
