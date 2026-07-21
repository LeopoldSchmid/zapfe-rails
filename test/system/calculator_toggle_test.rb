require "application_system_test_case"

class CalculatorToggleTest < ApplicationSystemTestCase
  test "hides drink cards and explains supported fittings when own drinks are enabled" do
    visit calculator_path

    assert_equal false, page.evaluate_script("document.getElementById('calc-drinks-mode').classList.contains('hidden')")
    assert_equal true, page.evaluate_script("document.getElementById('calc-own-drinks-note').classList.contains('hidden')")

    page.execute_script("document.getElementById('bring-own-drinks').click()")

    assert_equal true, page.evaluate_script("document.getElementById('calc-drinks-mode').classList.contains('hidden')")
    assert_equal false, page.evaluate_script("document.getElementById('calc-own-drinks-note').classList.contains('hidden')")
    assert_text "Flachfitting"
    assert_text "Korbfitting"
  end

  test "shows pricing and can expand the breakdown" do
    visit calculator_path

    assert_text "PREISINDIKATION"
    assert_text "250,00 €"
    page.execute_script("document.querySelector('#pricing-breakdown summary').click()") unless page.has_selector?("#pricing-breakdown[open]", wait: 1)
    assert_selector "#pricing-breakdown[open]"
    assert_text "Miete (Zapf)"
    assert_text "Gesamt"
  end
end
