require "test_helper"

module FeaturedProducts
  class SyncTest < ActiveSupport::TestCase
    test "syncs featured products from config and resets others" do
      product = products(:one)
      other = products(:two)

      config_path = Rails.root.join("tmp/featured_products_test.yml")
      File.write(config_path, <<~YAML)
        default:
          - article_number: "#{other.article_number}"
            featured_position: 1
            featured_note: "Test-Favorit"
      YAML

      product.update!(featured: true, featured_position: 5, featured_note: "Alt")

      result = FeaturedProducts::Sync.new(config_path: config_path).call

      assert_equal [ other.article_number ], result.updated_article_numbers
      assert_empty result.missing_article_numbers

      assert_not product.reload.featured?
      assert_nil product.featured_position
      assert_nil product.featured_note

      assert other.reload.featured?
      assert_equal 1, other.featured_position
      assert_equal "Test-Favorit", other.featured_note
    ensure
      File.delete(config_path) if config_path && File.exist?(config_path)
    end

    test "reports missing article numbers" do
      config_path = Rails.root.join("tmp/featured_products_missing_test.yml")
      File.write(config_path, <<~YAML)
        default:
          - article_number: "99999999"
            featured_position: 1
      YAML

      result = FeaturedProducts::Sync.new(config_path: config_path).call

      assert_empty result.updated_article_numbers
      assert_equal [ "99999999" ], result.missing_article_numbers
    ensure
      File.delete(config_path) if config_path && File.exist?(config_path)
    end
  end
end
