import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["query", "item", "visibleCount", "emptyState"]

  connect() {
    this.update()
  }

  update() {
    const query = this.queryTarget.value.trim().toLowerCase()
    let visibleCount = 0

    this.itemTargets.forEach((item) => {
      const matches = !query || item.dataset.searchText.includes(query)
      item.classList.toggle("search-hidden", !matches)
      this.syncItemVisibility(item)

      if (!item.hidden) visibleCount += 1
    })

    if (this.hasVisibleCountTarget) {
      this.visibleCountTarget.textContent = visibleCount.toString()
    }

    if (this.hasEmptyStateTarget) {
      this.emptyStateTarget.hidden = visibleCount > 0
    }
  }

  syncItemVisibility(item) {
    item.hidden = item.classList.contains("search-hidden") || item.classList.contains("category-hidden")
  }
}
