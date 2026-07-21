import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "toggle"]

  connect() {
    this.keydown = this.handleKeydown.bind(this)
    this.close(false)
  }

  toggle() {
    this.panelTarget.classList.contains("hidden") ? this.open() : this.close()
  }

  open() {
    this.panelTarget.classList.remove("hidden")
    document.body.classList.add("overflow-hidden")
    this.toggleTargets.forEach((button) => button.setAttribute("aria-expanded", "true"))
    document.addEventListener("keydown", this.keydown)
    this.focusableElements()[0]?.focus()
  }

  close(restoreFocus = true) {
    this.panelTarget.classList.add("hidden")
    document.body.classList.remove("overflow-hidden")
    this.toggleTargets.forEach((button) => button.setAttribute("aria-expanded", "false"))
    document.removeEventListener("keydown", this.keydown)
    if (restoreFocus) this.toggleTargets[0]?.focus()
  }

  disconnect() {
    document.removeEventListener("keydown", this.keydown)
    document.body.classList.remove("overflow-hidden")
  }

  handleKeydown(event) {
    if (event.key === "Escape") return this.close()
    if (event.key !== "Tab") return

    const elements = this.focusableElements()
    const first = elements[0]
    const last = elements[elements.length - 1]
    if (event.shiftKey && document.activeElement === first) {
      event.preventDefault()
      last?.focus()
    } else if (!event.shiftKey && document.activeElement === last) {
      event.preventDefault()
      first?.focus()
    }
  }

  focusableElements() {
    return Array.from(this.panelTarget.querySelectorAll("a[href], button:not([disabled]), input:not([disabled]), select:not([disabled]), textarea:not([disabled]), [tabindex]:not([tabindex='-1'])"))
  }
}
