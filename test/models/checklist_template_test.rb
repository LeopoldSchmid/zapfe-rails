require "test_helper"

class ChecklistTemplateTest < ActiveSupport::TestCase
  test "accepts organisation and custom checklist sections" do
    organisation = ChecklistTemplate.create!(name: "Vorbereitung", section: "Organisation")
    custom = ChecklistTemplate.create!(name: "Kundendienst", section: "Kundenkommunikation")

    assert_equal "organisation", organisation.section
    assert_equal "Organisation", organisation.section_label
    assert_equal "kundenkommunikation", custom.section
    assert_equal "Kundenkommunikation", custom.section_label
  end
end
