import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["gross", "tax", "net"]

  connect() {
    this.calculate()
  }

  calculate() {
    const gross = this.number(this.grossTarget.value)
    const tax = this.number(this.taxTarget.value)
    this.netTarget.textContent = gross === null || tax === null ? "–" : this.currency(gross / (1 + tax / 100))
  }

  number(value) {
    const parsed = Number(String(value).replace(",", "."))
    return Number.isFinite(parsed) ? parsed : null
  }

  currency(value) {
    return new Intl.NumberFormat("de-DE", { style: "currency", currency: "EUR" }).format(value)
  }
}
