# frozen_string_literal: true

namespace :zapfe do
  desc "Sync featured products from config/featured_products.yml"
  task sync_featured_products: :environment do
    result = FeaturedProducts::Sync.new.call

    puts "Featured products updated: #{result.updated_article_numbers.join(', ')}"

    if result.missing_article_numbers.any?
      puts "Missing article numbers: #{result.missing_article_numbers.join(', ')}"
    end
  end
end
