import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["query", "item", "empty"]

  filter() {
    const query = this.queryTarget.value.trim().toLowerCase()
    let matches = 0

    this.itemTargets.forEach((item) => {
      const visible = !query || item.dataset.searchText.includes(query)
      item.hidden = !visible
      if (visible) matches += 1
    })

    if (this.hasEmptyTarget) this.emptyTarget.hidden = matches > 0
  }
}
