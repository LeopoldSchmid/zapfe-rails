import { Controller } from "@hotwired/stimulus"

const FIELD_ERROR_CLASSES = ["border-red-400", "bg-red-50", "text-red-900", "placeholder:text-red-300"]
const CHECKBOX_ERROR_CLASSES = ["ring-2", "ring-red-400", "ring-offset-2"]

export default class extends Controller {
  connect() {
    this.invalidHandler = this.handleInvalid.bind(this)
    this.inputHandler = this.handleInput.bind(this)

    this.element.setAttribute("lang", "de")
    this.element.addEventListener("invalid", this.invalidHandler, true)
    this.element.addEventListener("input", this.inputHandler, true)
    this.element.addEventListener("change", this.inputHandler, true)
  }

  disconnect() {
    this.element.removeEventListener("invalid", this.invalidHandler, true)
    this.element.removeEventListener("input", this.inputHandler, true)
    this.element.removeEventListener("change", this.inputHandler, true)
  }

  handleInvalid(event) {
    const field = event.target
    if (!(field instanceof HTMLElement)) return

    field.setCustomValidity("")
    field.setCustomValidity(this.validationMessageFor(field))
    this.markInvalid(field)
  }

  handleInput(event) {
    const field = event.target
    if (!(field instanceof HTMLElement)) return

    field.setCustomValidity?.("")
    this.clearInvalid(field)
  }

  validationMessageFor(field) {
    if (field instanceof HTMLInputElement && field.type === "checkbox") {
      return "Bitte bestätige die Datenschutzerklärung."
    }

    if (field instanceof HTMLInputElement && field.validity.typeMismatch && field.type === "email") {
      return "Bitte gib eine gültige E-Mail-Adresse ein."
    }

    if ("validity" in field && field.validity.valueMissing) {
      return `${this.labelFor(field)} ist ein Pflichtfeld.`
    }

    return "Bitte prüfe dieses Feld."
  }

  labelFor(field) {
    const label = this.element.querySelector(`label[for="${field.id}"]`)
    const text = label?.textContent?.replace(/\*/g, "").trim()
    return text || "Dieses Feld"
  }

  markInvalid(field) {
    if (field instanceof HTMLInputElement && field.type === "checkbox") {
      field.classList.add(...CHECKBOX_ERROR_CLASSES)
      return
    }

    field.classList.add(...FIELD_ERROR_CLASSES)
  }

  clearInvalid(field) {
    if (field instanceof HTMLInputElement && field.type === "checkbox") {
      field.classList.remove(...CHECKBOX_ERROR_CLASSES)
      return
    }

    field.classList.remove(...FIELD_ERROR_CLASSES)
  }
}
