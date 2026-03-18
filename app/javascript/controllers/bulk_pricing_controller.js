import { Controller } from "@hotwired/stimulus"

const formatCurrency = (value) => new Intl.NumberFormat("de-DE", {
  style: "currency",
  currency: "EUR"
}).format(value)

export default class extends Controller {
  static targets = ["categorySelect", "sizeSelect", "priceInput", "perLiterOutput", "productRow", "emptyState", "slotCard"]

  connect() {
    this.update()
  }

  update() {
    this.filterRows()
    this.filterSizeOptions()

    this.perLiterOutputTargets.forEach((output, index) => {
      const size = Number(this.sizeSelectTargets[index]?.value || 0)
      const price = Number(this.priceInputTargets[index]?.value || 0)

      if (!size || !price) {
        output.textContent = "-"
        return
      }

      output.textContent = `${formatCurrency(price / size)} /L`
    })
  }

  filterRows() {
    if (!this.hasCategorySelectTarget || !this.hasProductRowTarget) return

    const selectedCategoryId = this.categorySelectTarget.value
    let visibleRows = 0

    this.productRowTargets.forEach((row) => {
      const matches = !selectedCategoryId || row.dataset.categoryId === selectedCategoryId
      row.classList.toggle("hidden", !matches)
      if (matches) visibleRows += 1
    })

    if (this.hasEmptyStateTarget) {
      this.emptyStateTarget.classList.toggle("hidden", visibleRows > 0)
    }
  }

  filterSizeOptions() {
    if (!this.hasCategorySelectTarget) return

    const selectedCategoryId = this.categorySelectTarget.value
    const availableSizes = new Set()

    if (selectedCategoryId) {
      this.productRowTargets.forEach((row) => {
        if (row.dataset.categoryId !== selectedCategoryId) return

        row.dataset.variantSizes
          ?.split(",")
          .map((value) => value.trim())
          .filter(Boolean)
          .forEach((value) => availableSizes.add(value))
      })
    }

    this.sizeSelectTargets.forEach((select, index) => {
      const options = Array.from(select.options)

      options.forEach((option) => {
        const enabled = !selectedCategoryId || availableSizes.has(option.value)
        option.disabled = !enabled
        option.hidden = !enabled
      })

      const slotCard = this.slotCardTargets[index]
      const priceInput = this.priceInputTargets[index]
      const hasSelectableOption = options.some((option) => !option.disabled)

      if (!selectedCategoryId) {
        slotCard?.classList.remove("hidden")
      } else if (hasSelectableOption) {
        slotCard?.classList.remove("hidden")
      } else {
        select.value = ""
        if (priceInput) priceInput.value = ""
        slotCard?.classList.add("hidden")
      }

      if (selectedCategoryId && hasSelectableOption && !availableSizes.has(select.value)) {
        const fallback = options.find((option) => !option.disabled)
        if (fallback) select.value = fallback.value
      }
    })
  }
}
