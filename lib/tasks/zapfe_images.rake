# frozen_string_literal: true

require "net/http"
require "json"
require "open-uri"

namespace :zapfe do
  desc "Sync product images from Supabase bucket into Active Storage"
  task sync_supabase_images: :environment do
    source_env = ENV.fetch("SOURCE_ENV", "/home/leo/dev/projects/zapfe/.env")
    if File.exist?(source_env)
      env_values = Dotenv.parse(source_env)
      %w[SUPABASE_URL SUPABASE_STORAGE_URL SUPABASE_STORAGE_SERVICE_KEY SUPABASE_BUCKET].each do |key|
        ENV[key] ||= env_values[key]
      end
    end

    supabase_url = ENV["SUPABASE_URL"] || ENV["SUPABASE_STORAGE_URL"]&.split("/storage/")&.first
    service_key = ENV["SUPABASE_STORAGE_SERVICE_KEY"]
    bucket = ENV.fetch("SUPABASE_BUCKET", "zapfe-bucket")
    dry_run = ENV.fetch("DRY_RUN", "true") == "true"
    force = ENV.fetch("FORCE", "false") == "true"

    abort("SUPABASE_URL/SUPABASE_STORAGE_URL missing") if supabase_url.blank?
    abort("SUPABASE_STORAGE_SERVICE_KEY missing") if service_key.blank?

    products = Product.all.to_a
    matcher = Legacy::ImageKeyMatcher.new(products)

    objects = []
    offset = 0
    limit = 100

    loop do
      uri = URI("#{supabase_url}/storage/v1/object/list/#{bucket}")
      req = Net::HTTP::Post.new(uri)
      req["Authorization"] = "Bearer #{service_key}"
      req["apikey"] = service_key
      req["Content-Type"] = "application/json"
      req.body = {
        prefix: "",
        limit: limit,
        offset: offset,
        sortBy: { column: "name", order: "asc" }
      }.to_json

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") { |http| http.request(req) }
      abort("Supabase list failed: #{response.code} #{response.body}") unless response.is_a?(Net::HTTPSuccess)

      batch = JSON.parse(response.body)
      break if batch.empty?

      objects.concat(batch)
      offset += batch.size
      break if batch.size < limit
    end

    image_objects = objects.select { |obj| obj["name"].to_s.match?(/\.(png|jpg|jpeg|webp)\z/i) && !obj["name"].to_s.end_with?("_thumb.jpg", "_thumb.jpeg", "_thumb.png", "_thumb.webp") }

    matched = 0
    attached = 0
    skipped = 0

    image_objects.each do |obj|
      key = obj["name"]
      product = matcher.find_product(key)
      unless product
        skipped += 1
        next
      end

      matched += 1
      if product.image.attached? && !force
        skipped += 1
        next
      end

      public_url = "#{supabase_url}/storage/v1/object/public/#{bucket}/#{key}"

      if dry_run
        puts "[DRY_RUN] #{product.brand} #{product.name} <= #{key}"
        next
      end

      file_io = URI.open(public_url)
      filename = File.basename(key)
      content_type = obj["metadata"]&.dig("mimetype") || "image/jpeg"

      product.image.purge if product.image.attached? && force
      product.image.attach(io: file_io, filename: filename, content_type: content_type)
      attached += 1
      puts "Attached #{filename} to #{product.brand} #{product.name}"
    rescue OpenURI::HTTPError => e
      puts "Failed download for #{key}: #{e.message}"
      skipped += 1
    end

    puts "Done. objects=#{image_objects.size}, matched=#{matched}, attached=#{attached}, skipped=#{skipped}, dry_run=#{dry_run}"
  end
end
