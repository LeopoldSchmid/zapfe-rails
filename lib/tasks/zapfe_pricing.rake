# frozen_string_literal: true

namespace :zapfe do
  desc "Normalize beer keg prices (30L => 95 EUR, 50L => 145 EUR)"
  task normalize_beer_prices: :environment do
    beer_scope = Product.joins(:category).where(categories: { name: [ "Beer", "Bier" ] })
      .or(Product.joins(:category).where(categories: { kind: [ "Beer", "Bier" ] }))
      .distinct

    updated = 0

    beer_scope.includes(:product_variants).find_each do |product|
      product.product_variants.each do |variant|
        target_price =
          case variant.size.to_f
          when 30.0 then 95
          when 50.0 then 145
          end

        next unless target_price
        next if variant.price.to_f == target_price

        variant.update!(price: target_price)
        updated += 1
        puts "Updated #{product.brand} #{product.name} #{variant.size.to_f}L => #{target_price} EUR"
      end
    end

    puts "Beer price normalization completed. Updated variants: #{updated}"
  end
end
