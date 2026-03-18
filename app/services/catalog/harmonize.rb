module Catalog
  class Harmonize
    CATEGORY_ALIASES = {
      "Beer" => "Bier",
      "Bier" => "Bier",
      "Soft Drink" => "Softdrinks",
      "Softdrinks" => "Softdrinks",
      "Wine" => "Wein",
      "Sparkling Wine" => "Aperitif",
      "0%" => "Bier",
      "Cider" => "Cider"
    }.freeze

    SUBCATEGORY_ALIASES = {
      "Other" => "Sonstige",
      "Apple Juice" => "Apfelsaft"
    }.freeze

    SPECIAL_PRODUCT_RULES = {
      "010055" => {
        category_name: "Bier",
        subcategory: "Weizen",
        is_alcoholic: false,
        alcohol_content: 0
      },
      "033620" => {
        category_name: "Softdrinks",
        subcategory: "Apfelsaft",
        is_alcoholic: false,
        alcohol_content: 0
      },
      "045820" => {
        category_name: "Aperitif",
        subcategory: "Frizzante"
      }
    }.freeze

    HUGO_ARTICLE_NUMBER = "29242200".freeze
    HUGO_IMAGE_PATH = Rails.root.join("app/assets/images/tmp/hugo.png").freeze

    Result = Struct.new(:updated_products, :created_products, :updated_variants, keyword_init: true)

    def call
      updated_products = 0
      created_products = 0
      updated_variants = 0

      Product.transaction do
        canonical_categories = ensure_canonical_categories
        updated_products += harmonize_products(canonical_categories)

        hugo_created, hugo_variant_updates = upsert_hugo(canonical_categories.fetch("Aperitif"))
        created_products += hugo_created
        updated_variants += hugo_variant_updates

        updated_variants += normalize_prices

        FeaturedProducts::Sync.new.call
      end

      Result.new(
        updated_products: updated_products,
        created_products: created_products,
        updated_variants: updated_variants
      )
    end

    private

    def ensure_canonical_categories
      CATEGORY_ALIASES.values.uniq.index_with do |name|
        Category.find_or_create_by!(name: name) { |category| category.kind = name }
      end
    end

    def harmonize_products(canonical_categories)
      updated = 0

      Product.includes(:category).find_each do |product|
        changes = {}

        current_category_name = product.category&.name.to_s
        target_category_name = SPECIAL_PRODUCT_RULES.dig(product.article_number, :category_name) ||
          CATEGORY_ALIASES[current_category_name] ||
          current_category_name.presence

        if target_category_name.present?
          target_category = canonical_categories[target_category_name] || Category.find_or_create_by!(name: target_category_name) { |category| category.kind = target_category_name }
          changes[:category_id] = target_category.id if product.category_id != target_category.id
          changes[:kind] = target_category_name if product.kind != target_category_name
        end

        target_subcategory = SPECIAL_PRODUCT_RULES.dig(product.article_number, :subcategory) ||
          SUBCATEGORY_ALIASES[product.subcategory] ||
          product.subcategory
        changes[:subcategory] = target_subcategory if target_subcategory != product.subcategory

        if SPECIAL_PRODUCT_RULES.key?(product.article_number)
          rule = SPECIAL_PRODUCT_RULES.fetch(product.article_number)
          changes[:is_alcoholic] = rule[:is_alcoholic] unless rule[:is_alcoholic].nil?
          changes[:alcohol_content] = rule[:alcohol_content] unless rule[:alcohol_content].nil?
        end

        next if changes.empty?

        product.update!(changes)
        updated += 1
      end

      CATEGORY_ALIASES.keys.uniq.each do |old_name|
        next if old_name == CATEGORY_ALIASES[old_name]

        Category.where(name: old_name).or(Category.where(kind: old_name)).find_each do |category|
          category.destroy! if category.products.none?
        end
      end

      Category.where(name: "Alkoholfrei").or(Category.where(kind: "Alkoholfrei")).find_each do |category|
        category.destroy! if category.products.none?
      end

      updated
    end

    def upsert_hugo(category)
      product = Product.find_or_initialize_by(article_number: HUGO_ARTICLE_NUMBER)
      created_product = product.new_record? ? 1 : 0

      product.assign_attributes(
        category: category,
        kind: category.name,
        brand: "ViniGrandi",
        name: "Hugo Cocktail",
        subcategory: "Hugo",
        alcohol_content: 5.5,
        is_alcoholic: true,
        description: "Weinhaltiger Hugo im KeyKeg 20L."
      )
      product.save!
      attach_local_image(product, HUGO_IMAGE_PATH, filename: "hugo-cocktail-keykeg-20l.png")

      variant = product.product_variants.find_or_initialize_by(sku: HUGO_ARTICLE_NUMBER)
      variant_updated = variant.new_record? ? 1 : 0
      variant.assign_attributes(
        size: 20.0,
        price: 160.0,
        is_available: true,
        availability: "Auf Anfrage"
      )
      variant.save!

      [created_product, variant_updated]
    end

    def normalize_prices
      updated = 0

      Product.includes(:category, :product_variants).find_each do |product|
        product.product_variants.each do |variant|
          target_price = target_price_for(product, variant)
          next unless target_price
          next if variant.price.to_f == target_price

          variant.update!(price: target_price)
          updated += 1
        end
      end

      updated
    end

    def target_price_for(product, variant)
      return 160.0 if product.article_number == HUGO_ARTICLE_NUMBER && variant.size.to_f == 20.0

      return unless product.category&.name == "Bier"

      case variant.size.to_f
      when 30.0 then 95.0
      when 50.0 then 145.0
      else nil
      end
    end

    def attach_local_image(product, path, filename:)
      return unless File.exist?(path)

      return if blob_file_present?(product.image.blob)

      product.image.purge if product.image.attached?

      data = File.binread(path)
      blob = ActiveStorage::Blob.create_and_upload!(
        io: StringIO.new(data),
        filename: filename,
        content_type: "image/png"
      )
      product.image.attach(blob)
    end

    def blob_file_present?(blob)
      return false unless blob

      blob.service.exist?(blob.key)
    end
  end
end
