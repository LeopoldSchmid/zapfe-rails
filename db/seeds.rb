# frozen_string_literal: true

categories = [
  { name: "Bier", kind: "Beer", description: "Biersorten" },
  { name: "Softdrinks", kind: "Soft Drink", description: "Alkoholfreie Getränke" }
]

categories.each do |attrs|
  Category.find_or_create_by!(name: attrs[:name]) do |category|
    category.assign_attributes(attrs)
  end
end

beer = Category.find_by!(name: "Bier")

product = Product.find_or_create_by!(article_number: "017653") do |p|
  p.name = "Pils"
  p.brand = "Rothaus"
  p.kind = "Bier"
  p.subcategory = "Pils"
  p.category = beer
  p.alcohol_content = 5.1
  p.is_alcoholic = true
  p.description = "Klassisches Pils vom Fass"
end

[
  { sku: "017653-20", size: 20.0, price: 89.99 },
  { sku: "017653-30", size: 30.0, price: 129.99 },
  { sku: "017653-50", size: 50.0, price: 199.99 }
].each do |variant_attrs|
  product.product_variants.find_or_create_by!(sku: variant_attrs[:sku]) do |variant|
    variant.assign_attributes(variant_attrs.merge(is_available: true, availability: "Instant"))
  end
end


admin_email = ENV.fetch("ADMIN_EMAIL", "ape2tap.blackforest@gmail.com")
admin_password = ENV.fetch("ADMIN_PASSWORD", "change-me-now")

admin = AdminUser.find_or_initialize_by(email: admin_email)
admin.password = admin_password
admin.password_confirmation = admin_password
admin.save!

puts "Seed complete. Admin login: #{admin_email}"
