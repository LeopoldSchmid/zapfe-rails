# frozen_string_literal: true

categories = [
  { name: "Bier", kind: "Beer", description: "Biersorten" },
  { name: "Softdrinks", kind: "Soft Drink", description: "Alkoholfreie Getränke" },
  { name: "Mietartikel", kind: "Rental", description: "Gläser, Kühlung und weitere Mietartikel" }
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

standard_profile_definitions = {
  "Lagerware" => { lead_time_days: 2, return_policy: "returnable" },
  "Bestellware" => { lead_time_days: 7, return_policy: "returnable" },
  "Sonderbestellung" => { lead_time_days: 14, return_policy: "non_returnable" }
}
standard_profiles = standard_profile_definitions.each_with_object({}) do |(name, attributes), profiles|
  profile = ProcurementProfile.find_or_initialize_by(name: name, supplier_id: nil)
  profile.assign_attributes(attributes.merge(standard: true))
  profile.save!
  profiles[name] = profile
end

suppliers = Supplier.where(name: [ "Getränkemarkt Südstar", "Getränke Beck" ]).index_by(&:name)
ProductVariant.find_each do |variant|
  {
    "Getränkemarkt Südstar" => standard_profiles.fetch("Lagerware"),
    "Getränke Beck" => standard_profiles.fetch("Sonderbestellung")
  }.each do |supplier_name, profile|
    offering = SupplierOffering.find_or_initialize_by(supplier: suppliers.fetch(supplier_name), product_variant: variant)
    offering.assign_attributes(procurement_profile: profile, active: true)
    offering.save!
    price = offering.supplier_prices.find_or_initialize_by(valid_from: Date.current)
    price.purchase_price = variant.size * 2
    price.valid_until = nil
    price.save!
  end
end

rental_category = Category.find_by!(name: "Mietartikel")
glass_definitions = [
  { article_number: "MIETE-BIERKRUG", brand: "Glasverleih", name: "Bierkrug", kind: "Gläser", variants: [ [ "MIETE-BIERKRUG-03", 0.3, 8.0 ], [ "MIETE-BIERKRUG-04", 0.4, 8.0 ], [ "MIETE-BIERKRUG-05", 0.5, 8.0 ] ] },
  { article_number: "MIETE-WEINGLAS", brand: "Glasverleih", name: "Weinglas", kind: "Gläser", variants: [ [ "MIETE-WEINGLAS-01", 0.1, 7.0 ], [ "MIETE-WEINGLAS-02", 0.2, 7.0 ] ] }
]

glass_definitions.each do |definition|
  product = Product.find_or_initialize_by(article_number: definition[:article_number])
  product.assign_attributes(name: definition[:name], brand: definition[:brand], kind: definition[:kind], category: rental_category, is_alcoholic: false, description: "Mietartikel")
  product.save!
  definition[:variants].each do |sku, size, sale_price|
    variant = product.product_variants.find_or_initialize_by(sku: sku)
    variant.assign_attributes(size: size, price: sale_price, is_available: true, availability: "Miete")
    variant.save!
    [ "Getränkemarkt Südstar", "Getränke Beck" ].each do |supplier_name|
      offering = SupplierOffering.find_or_initialize_by(supplier: suppliers.fetch(supplier_name), product_variant: variant)
      offering.assign_attributes(procurement_profile: standard_profiles.fetch("Lagerware"), active: true)
      offering.save!
      price = offering.supplier_prices.find_or_initialize_by(valid_from: Date.current)
      price.update!(purchase_price: 5.0, valid_until: nil)
    end
  end
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
