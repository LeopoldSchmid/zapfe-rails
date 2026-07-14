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

Supplier.find_or_create_by!(name: "Getränkemarkt Südstar") do |supplier|
  supplier.active = true
  supplier.default_supplier = true
end
Supplier.find_or_create_by!(name: "Getränke Beck") do |supplier|
  supplier.active = true
end

{
  "Ape" => {
    "packing" => [ "Ape und Zubehör auf Vollständigkeit prüfen", "Verbrauchsmaterial und Werkzeug einladen" ],
    "setup" => [ "Standort und sicheren Stand prüfen", "Anschlüsse und Zapfanlage testen" ],
    "cleaning" => [ "Zapfanlage gemäß Reinigungsablauf säubern", "Ape und Zubehör auf Schäden prüfen" ]
  },
  "Kegerator" => {
    "packing" => [ "Kegerator und Zubehör auf Vollständigkeit prüfen", "Verbrauchsmaterial und Werkzeug einladen" ],
    "setup" => [ "Standort und Stromversorgung prüfen", "Anschlüsse und Kühlung testen" ],
    "cleaning" => [ "Leitungen gemäß Reinigungsablauf säubern", "Kegerator außen und innen reinigen" ]
  }
}.each do |resource_type, sections|
  sections.each do |section, items|
    label = { "packing" => "Packen", "setup" => "Aufbau", "cleaning" => "Reinigung" }.fetch(section)
    template = ChecklistTemplate.find_or_create_by!(name: "#{resource_type} · #{label}") do |record|
      record.resource_type = resource_type
      record.section = section
      record.active = true
    end
    items.each_with_index do |title, position|
      template.items.find_or_create_by!(title: title) { |item| item.position = position + 1 }
    end
  end
end


admin_accounts = [
  [ "Leopold Schmid", ENV["LEOPOLD_ADMIN_EMAIL"], ENV["LEOPOLD_ADMIN_PASSWORD"] ],
  [ "Dennis Bühler", ENV["DENNIS_ADMIN_EMAIL"], ENV["DENNIS_ADMIN_PASSWORD"] ],
  [ "Johannes Wiese", ENV["JOHANNES_ADMIN_EMAIL"], ENV["JOHANNES_ADMIN_PASSWORD"] ]
]

admin_accounts.each do |name, email, password|
  next if email.blank? || password.blank?

  admin = AdminUser.find_or_initialize_by(email: email)
  admin.name = name
  admin.active = true
  admin.password = password
  admin.password_confirmation = password
  admin.save!
end

puts "Seed complete. Set LEOPOLD_ADMIN_EMAIL/PASSWORD, DENNIS_ADMIN_EMAIL/PASSWORD and JOHANNES_ADMIN_EMAIL/PASSWORD to create the three internal accounts."
