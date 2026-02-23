require "test_helper"

class Legacy::ImageKeyMatcherTest < ActiveSupport::TestCase
  test "extracts normalized key from legacy object name" do
    key = Legacy::ImageKeyMatcher.key_from_object_name("123_rothaus_badische_staatsbrauerei_rothaus_pils.jpg")
    assert_equal "rothaus_badische_staatsbrauerei_rothaus_pils", key
  end

  test "matches object name to product" do
    product = Product.new(brand: "Rothaus", name: "Pils")
    matcher = Legacy::ImageKeyMatcher.new([product])

    found = matcher.find_product("17_rothaus_pils.webp")
    assert_equal product, found
  end
end
