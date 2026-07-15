import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  previous() {
    this.changeBy(-1)
  }

  next() {
    this.changeBy(1)
  }

  changeBy(days) {
    const input = this.inputTarget
    const current = input.valueAsDate || new Date()
    current.setUTCDate(current.getUTCDate() + days)
    input.valueAsDate = current
    input.dispatchEvent(new Event("change", { bubbles: true }))
  }
}
