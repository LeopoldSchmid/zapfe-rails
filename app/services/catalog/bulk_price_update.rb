module Catalog
  class BulkPriceUpdate
    Result = Struct.new(
      :success?,
      :updated_variants,
      :category_name,
      :applied_updates,
      :error_message,
      keyword_init: true
    ) do
      def summary_label
        applied_updates.map do |update|
          size = update.fetch(:size)
          price = update.fetch(:price)
          size_label = "#{size.to_f % 1 == 0 ? size.to_i : size}L"
          price_label = ActionController::Base.helpers.number_to_currency(price, unit: "€", separator: ",", delimiter: ".")
          "#{size_label} -> #{price_label}"
        end.join(", ")
      end
    end

    def self.canonical_category_names
      Catalog::Harmonize::CATEGORY_ALIASES.values.uniq
    end

    def initialize(category_id:, sizes:, prices:)
      @category_id = category_id
      @sizes = Array(sizes)
      @prices = Array(prices)
    end

    def call
      return error("Bitte wähle eine harmonisierte Kategorie.") if category.blank?
      return error("Bitte gib mindestens einen gültigen Preis für eine Größe an.") if parsed_updates.empty?

      updated_count = 0

      parsed_updates.each do |update|
        updated_count += ProductVariant.joins(product: :category)
          .where(products: { category_id: category.id })
          .where(size: update.fetch(:size))
          .update_all(price: update.fetch(:price), updated_at: Time.current)
      end

      Result.new(
        success?: true,
        updated_variants: updated_count,
        category_name: category.name,
        applied_updates: parsed_updates
      )
    end

    private

    attr_reader :category_id, :sizes, :prices

    def category
      @category ||= Category.where(name: self.class.canonical_category_names).find_by(id: category_id)
    end

    def parsed_updates
      @parsed_updates ||= sizes.zip(prices).filter_map do |size_value, price_value|
        next if price_value.blank?

        parsed_size = parse_decimal(size_value)&.to_f
        parsed_price = parse_decimal(price_value)
        next if parsed_size.nil? || parsed_price.nil? || parsed_price.negative?

        { size: parsed_size, price: parsed_price }
      end
    end

    def parse_decimal(value)
      normalized = value.to_s.strip.tr(",", ".")
      return nil if normalized.blank?

      BigDecimal(normalized)
    rescue ArgumentError
      nil
    end

    def error(message)
      Result.new(success?: false, updated_variants: 0, applied_updates: [], error_message: message)
    end
  end
end
