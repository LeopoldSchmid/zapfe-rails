import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["query", "select", "card", "packageUnit", "packageQuantity", "packageContentUnit"]

  filter() {
    const query = this.queryTarget.value.trim().toLowerCase()
    this.selectTargets.forEach((select) => {
      Array.from(select.options).forEach((option) => {
        option.hidden = option.value && query && !option.text.toLowerCase().includes(query)
      })
    })
  }

  filterCards() {
    const query = this.queryTarget.value.trim().toLowerCase()
    this.cardTargets.forEach((card) => { card.hidden = query && !card.dataset.searchText.includes(query) })
  }

  applyPackageDefaults() {
    const option = this.selectTarget.selectedOptions[0]
    if (!option?.value) return

    if (this.hasPackageUnitTarget) this.packageUnitTarget.value = option.dataset.salesUnit || "Stk"
    if (this.hasPackageQuantityTarget) this.packageQuantityTarget.value = "1"
    if (this.hasPackageContentUnitTarget) this.packageContentUnitTarget.value = "Stk"
  }
}
