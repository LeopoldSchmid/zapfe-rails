# frozen_string_literal: true

module Legacy
  class ImageKeyMatcher
    def self.normalize(value)
      value.to_s.downcase.gsub(/[^a-z0-9]+/, "_").gsub(/\A_+|_+\z/, "")
    end

    def self.product_key(product)
      normalize("#{product.brand}_#{product.name}")
    end

    def self.key_from_object_name(object_name)
      filename = File.basename(object_name.to_s)
      stem = filename.sub(/\.[^.]+\z/, "")
      stem = stem.sub(/_thumb\z/, "")
      stem = stem.sub(/\A\d+_/, "")
      normalize(stem)
    end

    def initialize(products)
      @index = products.each_with_object({}) do |product, hash|
        key = self.class.product_key(product)
        hash[key] ||= []
        hash[key] << product
      end
    end

    def find_product(object_name)
      key = self.class.key_from_object_name(object_name)
      exact = @index[key]
      return exact.first if exact&.one?

      return exact.first if exact&.any?

      # fallback: fuzzy contains match
      @index.each do |product_key, products|
        return products.first if key.include?(product_key) || product_key.include?(key)
      end

      nil
    end
  end
end
