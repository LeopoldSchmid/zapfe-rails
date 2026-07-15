import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { delay: { type: Number, default: 4500 } }

  connect() {
    this.dismiss = this.dismiss.bind(this)
    this.pause = this.pause.bind(this)
    this.resume = this.resume.bind(this)
    this.remaining = this.delayValue
    this.element.addEventListener("mouseenter", this.pause)
    this.element.addEventListener("focusin", this.pause)
    this.element.addEventListener("mouseleave", this.resume)
    this.element.addEventListener("focusout", this.resume)
    this.resume()
  }

  disconnect() {
    clearTimeout(this.timeout)
  }

  close() {
    this.dismiss()
  }

  pause() {
    clearTimeout(this.timeout)
    if (this.startedAt) this.remaining -= Date.now() - this.startedAt
    this.startedAt = null
  }

  resume() {
    if (this.remaining <= 0) return this.dismiss()
    clearTimeout(this.timeout)
    this.startedAt = Date.now()
    this.timeout = setTimeout(this.dismiss, this.remaining)
  }

  dismiss() {
    clearTimeout(this.timeout)
    this.element.classList.add("admin-flash-leaving")
    setTimeout(() => this.element.remove(), 180)
  }
}
