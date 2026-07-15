import { Controller } from "@hotwired/stimulus"

const icons = {
  save: ["M5 3h11l3 3v15H5z", "M8 3v6h8", "M8 18h8v-5H8z"],
  trash: ["M4 7h16", "M10 11v6", "M14 11v6", "M6 7l1 13h10l1-13", "M9 7V4h6v3"],
  copy: ["M9 9h10v10H9z", "M5 15H4V5h10v1"],
  plus: ["M12 5v14", "M5 12h14"],
  send: ["m22 2-7 20-4-9-9-4Z", "m22 2-11 11", "m22 2-15 4-4 9"],
  check: ["m5 12 4 4L19 6"]
}

export default class extends Controller {
  connect() {
    this.decorate = this.decorate.bind(this)
    document.addEventListener("turbo:load", this.decorate)
    this.decorate()
  }

  disconnect() {
    document.removeEventListener("turbo:load", this.decorate)
  }

  decorate() {
    this.element.querySelectorAll('input[type="submit"]:not([data-action-icon-ready])').forEach((input) => this.replaceSubmit(input))
    this.element.querySelectorAll("button:not([data-action-icon-ready]), a:not([data-action-icon-ready])").forEach((element) => this.addIcon(element))
  }

  replaceSubmit(input) {
    const button = document.createElement("button")
    Array.from(input.attributes).forEach((attribute) => {
      if (!["type", "value"].includes(attribute.name)) button.setAttribute(attribute.name, attribute.value)
    })
    button.type = "submit"
    button.textContent = input.value
    input.replaceWith(button)
    this.addIcon(button)
  }

  addIcon(element) {
    if (element.dataset.actionIconReady) return

    const type = this.iconType(element.textContent.trim().toLowerCase())
    if (!type) return

    element.dataset.actionIconReady = "true"
    element.classList.add("admin-action-with-icon")
    const icon = element.querySelector(".admin-icon") || this.svg(type)
    element.prepend(icon)

    if (["save", "trash"].includes(type)) this.makeIconOnly(element, icon)
  }

  iconType(label) {
    if (/lösch|entfern/.test(label)) return "trash"
    if (/kopier/.test(label)) return "copy"
    if (/versend|senden/.test(label)) return "send"
    if (/speicher|aktualisier/.test(label)) return "save"
    if (/bestätig|reservier|finalisier|bezahlt/.test(label)) return "check"
    if (/erstell|hinzufüg|anleg|einplan|planen|import/.test(label)) return "plus"
    return null
  }

  makeIconOnly(element, icon) {
    const label = element.textContent.trim()
    element.replaceChildren(icon)
    element.setAttribute("aria-label", label)
    element.setAttribute("title", label)
    element.classList.add("admin-icon-only")
  }

  svg(type) {
    const namespace = "http://www.w3.org/2000/svg"
    const svg = document.createElementNS(namespace, "svg")
    svg.setAttribute("class", "admin-icon")
    svg.setAttribute("viewBox", "0 0 24 24")
    svg.setAttribute("fill", "none")
    svg.setAttribute("stroke", "currentColor")
    svg.setAttribute("stroke-width", "2")
    svg.setAttribute("stroke-linecap", "round")
    svg.setAttribute("stroke-linejoin", "round")
    svg.setAttribute("aria-hidden", "true")
    icons[type].forEach((pathData) => {
      const path = document.createElementNS(namespace, "path")
      path.setAttribute("d", pathData)
      svg.append(path)
    })
    return svg
  }
}
