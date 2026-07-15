require "csv"

class Catalog::CsvImport
  HEADERS = %w[article_number brand name kind category subcategory alcohol_content is_alcoholic sku size price is_available availability].freeze
  Result = Data.define(:products, :variants)

  class ImportError < StandardError; end

  def initialize(content:)
    @content = content
  end

  def call
    rows = CSV.parse(@content.delete_prefix("\uFEFF"), headers: true)
    raise ImportError, "CSV-Kopfzeile stimmt nicht. Erwartet werden: #{HEADERS.join(', ')}" unless (HEADERS - rows.headers.compact).empty?

    products = variants = 0
    Product.transaction do
      rows.each_with_index do |row, index|
        attributes = row.to_h.slice(*HEADERS).transform_values { |value| value&.strip }
        next if attributes.values.all?(&:blank?)

        validate_row!(attributes, index + 2)
        product = Product.find_or_initialize_by(article_number: attributes.fetch("article_number"))
        product.assign_attributes(product_attributes(attributes))
        product.save!
        products += 1

        variant = ProductVariant.find_or_initialize_by(sku: attributes.fetch("sku"))
        raise ImportError, "Zeile #{index + 2}: SKU #{variant.sku} gehört bereits zu einem anderen Produkt." if variant.persisted? && variant.product_id != product.id

        variant.assign_attributes(variant_attributes(attributes).merge(product: product))
        variant.save!
        variants += 1
      rescue ActiveRecord::RecordInvalid => error
        raise ImportError, "Zeile #{index + 2}: #{error.record.errors.full_messages.to_sentence}"
      end
    end
    Result.new(products:, variants:)
  rescue CSV::MalformedCSVError => error
    raise ImportError, "CSV konnte nicht gelesen werden: #{error.message}"
  end

  private

  def validate_row!(attributes, line)
    %w[article_number brand name kind sku size price].each do |column|
      raise ImportError, "Zeile #{line}: #{column} muss ausgefüllt sein." if attributes[column].blank?
    end
  end

  def product_attributes(attributes)
    category = if attributes["category"].present?
      Category.find_or_create_by!(name: attributes["category"]) { |record| record.kind = attributes["kind"] }
    end
    {
      brand: attributes["brand"], name: attributes["name"], kind: attributes["kind"], category:,
      subcategory: attributes["subcategory"], alcohol_content: attributes["alcohol_content"],
      is_alcoholic: boolean(attributes["is_alcoholic"], default: true)
    }
  end

  def variant_attributes(attributes)
    {
      size: attributes["size"], price: attributes["price"],
      is_available: boolean(attributes["is_available"], default: true),
      availability: attributes["availability"].presence || "Instant"
    }
  end

  def boolean(value, default:)
    return default if value.blank?

    ActiveModel::Type::Boolean.new.cast(value)
  end
end
