require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  test "requires name and kind" do
    category = Category.new
    assert_not category.valid?
  end
end
