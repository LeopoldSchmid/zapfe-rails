require "test_helper"

class Admin::ProductsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = AdminUser.create!(email: "products@example.com", password: "password123", password_confirmation: "password123")
    post admin_login_url, params: { email: @admin.email, password: "password123" }
  end

  test "should get index" do
    get admin_products_url
    assert_response :success
    assert_select "table.admin-products-table"
  end

  test "updates featured attributes" do
    product = products(:one)
    variant = product.product_variants.first

    patch admin_product_url(product), params: {
      product: {
        category_id: product.category_id,
        article_number: product.article_number,
        name: product.name,
        brand: product.brand,
        kind: product.kind,
        subcategory: product.subcategory,
        alcohol_content: product.alcohol_content,
        is_alcoholic: product.is_alcoholic ? "1" : "0",
        featured: "1",
        featured_position: "1",
        featured_note: "Perfekt fur grosse Gruppen und unkomplizierte Bierauswahl.",
        description: product.description,
        product_variants_attributes: {
          "0" => {
            id: variant.id,
            sku: variant.sku,
            size: variant.size,
            price: variant.price,
            is_available: variant.is_available ? "1" : "0",
            availability: variant.availability
          }
        }
      }
    }

    assert_redirected_to admin_products_url
    product.reload
    assert product.featured?
    assert_equal 1, product.featured_position
    assert_equal "Perfekt fur grosse Gruppen und unkomplizierte Bierauswahl.", product.featured_note
  end

  test "updates quick edit row and returns to index" do
    product = products(:two)

    patch admin_product_url(product), params: {
      return_to: admin_products_url,
      product: {
        article_number: "A200-NEU",
        brand: "Fritz-Kola",
        name: "Cola Zero",
        kind: "Softdrink",
        subcategory: "Zero",
        category_id: categories(:two).id,
        alcohol_content: "",
        is_alcoholic: "0",
        featured: "1",
        featured_position: "3",
        featured_note: "Starker Quick-Pick fur alkoholfreie Events."
      }
    }

    assert_redirected_to admin_products_url
    product.reload
    assert_equal "A200-NEU", product.article_number
    assert_equal "Fritz-Kola", product.brand
    assert_equal "Cola Zero", product.name
    assert product.featured?
    assert_equal 3, product.featured_position
  end

  test "bulk updates prices for matching variants in a harmonized category across several sizes" do
    beer = Category.find_or_create_by!(name: "Bier") { |category| category.kind = "Bier" }
    softdrinks = Category.find_or_create_by!(name: "Softdrinks") { |category| category.kind = "Softdrinks" }

    pils = Product.create!(
      article_number: "B100",
      category: beer,
      name: "Pils",
      brand: "Zapfe",
      kind: "Bier",
      subcategory: "Pils",
      description: "Test",
      is_alcoholic: true
    )
    pils_20l = pils.product_variants.create!(sku: "B100-20", size: 20.0, price: 92.0, is_available: true, availability: "Instant")
    pils.product_variants.create!(sku: "B100-30", size: 30.0, price: 110.0, is_available: true, availability: "Instant")

    weizen = Product.create!(
      article_number: "B200",
      category: beer,
      name: "Weizen",
      brand: "Zapfe",
      kind: "Bier",
      subcategory: "Weizen",
      description: "Test",
      is_alcoholic: true
    )
    weizen_20l = weizen.product_variants.create!(sku: "B200-20", size: 20.0, price: 96.0, is_available: true, availability: "Instant")

    cola = Product.create!(
      article_number: "S100",
      category: softdrinks,
      name: "Cola",
      brand: "Zapfe",
      kind: "Softdrinks",
      subcategory: "Cola",
      description: "Test",
      is_alcoholic: false
    )
    cola_20l = cola.product_variants.create!(sku: "S100-20", size: 20.0, price: 70.0, is_available: true, availability: "Instant")

    post bulk_update_prices_admin_products_url, params: {
      category_id: beer.id,
      bulk_sizes: [ "20", "30", "50" ],
      bulk_prices: [ "80", "99", "" ]
    }

    assert_redirected_to admin_products_url
    assert_equal 80.0, pils_20l.reload.price.to_f
    assert_equal 80.0, weizen_20l.reload.price.to_f
    assert_equal 99.0, pils.product_variants.find_by!(sku: "B100-30").price.to_f
    assert_equal 70.0, cola_20l.reload.price.to_f
  end
end
