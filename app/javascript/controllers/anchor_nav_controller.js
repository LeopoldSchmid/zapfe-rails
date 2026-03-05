import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["backButton"]

  connect() {
    this.previousPosition = null
  }

  disconnect() {
    document.documentElement.classList.remove("solutions-snap")
    document.body.classList.remove("solutions-snap")
  }

  back() {
    if (this.previousPosition == null) {
      this.hideBackButton()
      return
    }

    window.scrollTo({ top: this.previousPosition, behavior: "smooth" })
    this.previousPosition = null
    this.hideBackButton()
  }

  jump(event) {
    this.handleAnchorClick(event)
  }

  handleAnchorClick(event) {
    const hash = event.currentTarget.getAttribute("href")
    if (!hash || hash === "#") return

    const target = this.element.querySelector(hash)
    if (!target) return

    event.preventDefault()

    const currentPosition = window.scrollY
    const navOffset = 76
    const targetPosition = Math.max(0, target.getBoundingClientRect().top + window.scrollY - navOffset)

    if (Math.abs(targetPosition - currentPosition) < 8) return

    this.previousPosition = currentPosition
    this.showBackButton()

    window.scrollTo({ top: targetPosition, behavior: "smooth" })
  }

  showBackButton() {
    if (!this.hasBackButtonTarget) return
    this.backButtonTarget.style.display = "inline-flex"
  }

  hideBackButton() {
    if (!this.hasBackButtonTarget) return
    this.backButtonTarget.style.display = "none"
  }
}
