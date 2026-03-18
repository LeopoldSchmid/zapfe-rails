# frozen_string_literal: true

namespace :zapfe do
  desc "Harmonize catalog categories, add Hugo, normalize prices, and resync featured products"
  task harmonize_catalog: :environment do
    result = Catalog::Harmonize.new.call

    puts "Catalog harmonization completed."
    puts "Updated products: #{result.updated_products}"
    puts "Created products: #{result.created_products}"
    puts "Updated variants: #{result.updated_variants}"
  end
end
