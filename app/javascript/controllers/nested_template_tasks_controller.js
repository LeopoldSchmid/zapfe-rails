import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "template"]

  add() {
    const id = `${Date.now()}_${Math.floor(Math.random() * 1000)}`
    this.containerTarget.insertAdjacentHTML("beforeend", this.templateTarget.innerHTML.replaceAll("NEW_RECORD", id))
  }

  remove(event) {
    event.target.closest("[data-template-task]")?.remove()
  }
}
