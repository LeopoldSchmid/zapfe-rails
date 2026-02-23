import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel"]

  connect() {
    this.close()
  }

  toggle() {
    this.panelTarget.classList.toggle("hidden")
    document.body.classList.toggle("overflow-hidden")
  }

  close() {
    this.panelTarget.classList.add("hidden")
    document.body.classList.remove("overflow-hidden")
  }
}
