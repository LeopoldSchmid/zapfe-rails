module FeaturedProducts
  class Sync
    CONFIG_PATH = Rails.root.join("config/featured_products.yml").freeze

    Result = Struct.new(:updated_article_numbers, :missing_article_numbers, keyword_init: true)

    def initialize(config_path: CONFIG_PATH)
      @config_path = Pathname(config_path)
    end

    def call
      entries = load_entries
      updated = []
      missing = []

      Product.transaction do
        Product.update_all(featured: false, featured_position: nil, featured_note: nil)

        entries.each do |entry|
          product = Product.find_by(article_number: entry.fetch("article_number"))

          unless product
            missing << entry.fetch("article_number")
            next
          end

          product.update!(
            featured: true,
            featured_position: entry.fetch("featured_position"),
            featured_note: entry["featured_note"]
          )

          updated << product.article_number
        end
      end

      Result.new(updated_article_numbers: updated, missing_article_numbers: missing)
    end

    private

    attr_reader :config_path

    def load_entries
      raw = YAML.safe_load_file(config_path, permitted_classes: [], aliases: false) || {}
      Array(raw.fetch("default"))
    end
  end
end
