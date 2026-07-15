import { Controller } from "@hotwired/stimulus"

const storageKey = "zapfe:restore-scroll"

export default class extends Controller {
  connect() {
    this.save = this.save.bind(this)
    this.restore = this.restore.bind(this)
    document.addEventListener("turbo:submit-start", this.save)
    document.addEventListener("turbo:load", this.restore)
  }

  disconnect() {
    document.removeEventListener("turbo:submit-start", this.save)
    document.removeEventListener("turbo:load", this.restore)
  }

  save(event) {
    const form = event.target
    if (form.method?.toLowerCase() === "get") return

    sessionStorage.setItem(storageKey, JSON.stringify({
      path: window.location.pathname,
      y: window.scrollY
    }))
  }

  restore() {
    const saved = JSON.parse(sessionStorage.getItem(storageKey) || "null")
    if (!saved || saved.path !== window.location.pathname) return

    requestAnimationFrame(() => window.scrollTo(0, saved.y))
    sessionStorage.removeItem(storageKey)
  }
}
