require "test_helper"

class Admin::ProductsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = AdminUser.create!(email: "products@example.com", password: "password123", password_confirmation: "password123")
    post admin_login_url, params: { email: @admin.email, password: "password123" }
  end

  test "should get index" do
    get admin_products_url
    assert_response :success
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
end
