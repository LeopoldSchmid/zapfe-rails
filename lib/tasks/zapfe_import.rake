# frozen_string_literal: true

require "csv"

namespace :zapfe do
  desc "Import products + variants from legacy suedstar_2025_01.txt"
  task import_legacy_products: :environment do
    source_path = ENV.fetch("SOURCE", "/home/leo/dev/projects/zapfe/suedstar_2025_01.txt")

    unless File.exist?(source_path)
      abort("Source file not found: #{source_path}")
    end

    rows = CSV.read(source_path, headers: true)
    grouped = rows.group_by do |row|
      [
        row["brand"].to_s.strip,
        row["product_name"].to_s.strip,
        row["category"].to_s.strip,
        row["subcategory"].to_s.strip,
        row["alcohol_content"].to_s.strip
      ]
    end

    created_products = 0
    created_variants = 0

    grouped.each_value do |items|
      first = items.first
      brand = first["brand"].to_s.strip
      name = first["product_name"].to_s.strip
      category_name = first["category"].to_s.strip.presence || "Other"
      subcategory = first["subcategory"].to_s.strip
      alcohol_raw = first["alcohol_content"].to_s.strip

      category = Category.find_or_create_by!(name: category_name) do |c|
        c.kind = category_name
      end

      alcohol_content = if alcohol_raw.casecmp("non-alcoholic").zero?
        0
      elsif alcohol_raw.casecmp("alcoholic").zero?
        nil
      else
        alcohol_raw.tr(",", ".").to_f
      end

      is_alcoholic = !alcohol_raw.casecmp("non-alcoholic").zero?

      product = Product.find_or_initialize_by(brand: brand, name: name, kind: category_name, subcategory: subcategory)
      if product.new_record?
        seed_article = items.first["article_number"].to_s.rjust(6, "0")
        seed_article = seed_article[0, 10]

        # Keep unique article numbers even when legacy data has collisions.
        candidate = seed_article
        suffix = 1
        while Product.where(article_number: candidate).where.not(id: product.id).exists?
          base = seed_article[0, 8]
          candidate = "#{base}#{suffix.to_s.rjust(2, "0")}"[0, 10]
          suffix += 1
        end

        product.article_number = candidate
        product.category = category
        product.alcohol_content = alcohol_content
        product.is_alcoholic = is_alcoholic
        product.description ||= "Import aus Legacy-Daten"
        product.save!
        created_products += 1
      else
        product.update!(category: category, alcohol_content: alcohol_content, is_alcoholic: is_alcoholic)
      end

      items.each do |row|
        sku = row["article_number"].to_s.rjust(6, "0")
        size = row["keg_size"].to_s.downcase.gsub("l", "").tr(",", ".").to_f
        availability = row["availability"].to_s.strip.presence || "Instant"

        variant = product.product_variants.find_or_initialize_by(sku: sku)
        if variant.new_record?
          variant.size = size
          variant.price = 99.99
          variant.is_available = true
          variant.availability = availability
          variant.save!
          created_variants += 1
        end
      end
    end

    puts "Legacy import completed. New products: #{created_products}, new variants: #{created_variants}"
  end

  desc "Create event samples from the old website content"
  task import_legacy_event_samples: :environment do
    samples = [
      {
        title: "Lichterfest Schopfheim",
        subtitle: "Vergangene Veranstaltung",
        description: "Zapfe! mobile Zapflösung beim Lichterfest mit erfrischenden Getränken für Festivalgäste.",
        date_from: Date.new(2024, 11, 29),
        location: "Schopfheim",
        published: true,
        position: 1
      },
      {
        title: "Firmen-Sommerparty",
        subtitle: "Vergangene Veranstaltung",
        description: "Ape Truck als Getränkestation für ein Firmenevent mit über 200 Mitarbeitenden.",
        date_from: Date.new(2024, 7, 15),
        location: "Freiburg",
        published: true,
        position: 2
      }
    ]

    samples.each do |attrs|
      Event.find_or_create_by!(title: attrs[:title], date_from: attrs[:date_from]) do |event|
        event.assign_attributes(attrs)
      end
    end

    puts "Legacy event samples imported."
  end
end
