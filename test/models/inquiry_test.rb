require "test_helper"

class InquiryTest < ActiveSupport::TestCase
  test "requires mandatory contact data" do
    inquiry = Inquiry.new
    assert_not inquiry.valid?
  end
end
