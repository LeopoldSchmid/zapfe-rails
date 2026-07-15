require "test_helper"

class Catalog::CsvImportTest < ActiveSupport::TestCase
  test "creates products and variants and updates the same SKU on reimport" do
    csv = <<~CSV
      article_number,brand,name,kind,category,subcategory,alcohol_content,is_alcoholic,sku,size,price,is_available,availability
      IMP-100,Testbrau,Pils,Bier,Bier,Pils,5.0,true,IMP-100-30,30,120.00,true,Instant
    CSV

    result = Catalog::CsvImport.new(content: csv).call
    product = Product.find_by!(article_number: "IMP-100")
    assert_equal 1, result.products
    assert_equal 1, product.product_variants.count
    assert_equal 120.to_d, product.product_variants.sole.price

    Catalog::CsvImport.new(content: csv.sub("120.00", "125.00")).call
    assert_equal 1, Product.where(article_number: "IMP-100").count
    assert_equal 125.to_d, product.product_variants.reload.sole.price
  end

  test "does not write partial data when a row is invalid" do
    csv = "article_number,brand,name,kind,category,subcategory,alcohol_content,is_alcoholic,sku,size,price,is_available,availability\nIMP-200,Testbrau,Pils,Bier,Bier,Pils,5.0,true,IMP-200-30,30,100,true,Instant\nIMP-201,,,,,,,true,IMP-201-30,30,100,true,Instant\n"

    assert_raises(Catalog::CsvImport::ImportError) { Catalog::CsvImport.new(content: csv).call }
    assert_nil Product.find_by(article_number: "IMP-200")
  end
end
