require "application_system_test_case"

class CalculatorToggleTest < ApplicationSystemTestCase
  test "switches from drink cards to tap heads when own drinks are enabled" do
    visit calculator_path

    assert_equal false, page.evaluate_script("document.getElementById('calc-drinks-mode').classList.contains('hidden')")
    assert_equal true, page.evaluate_script("document.getElementById('calc-tap-heads-mode').classList.contains('hidden')")

    page.execute_script("document.getElementById('bring-own-drinks').click()")

    assert_equal true, page.evaluate_script("document.getElementById('calc-drinks-mode').classList.contains('hidden')")
    assert_equal false, page.evaluate_script("document.getElementById('calc-tap-heads-mode').classList.contains('hidden')")
    assert_text "Flat Head"
    assert_text "Korbfitting"
  end

  test "shows compact sticky pricing and can expand the breakdown" do
    visit calculator_path

    assert_text "GESCHÄTZTER PREIS"
    assert_text "250,00 €"
    assert_equal false, page.evaluate_script("document.getElementById('pricing-breakdown').open")

    page.execute_script("document.querySelector('#pricing-breakdown summary').click()")

    assert_equal true, page.evaluate_script("document.getElementById('pricing-breakdown').open")
    assert_text "Grundmiete (Zapf)"
    assert_text "Gesamt"
  end
end
