import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["source"]

  connect() {
    this.loaded = false
    this.reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches
    this.addPlaybackControl()

    if (!("IntersectionObserver" in window)) {
      this.load()
      return
    }

    this.observer = new IntersectionObserver(
      (entries) => {
        if (!entries.some((entry) => entry.isIntersecting)) return

        this.load()
        this.observer.disconnect()
      },
      { rootMargin: "240px 0px" }
    )

    this.observer.observe(this.element)
  }

  disconnect() {
    this.observer?.disconnect()
    this.control?.remove()
  }

  load() {
    if (this.loaded) return

    this.sourceTargets.forEach((source) => {
      if (source.dataset.src) source.src = source.dataset.src
    })

    this.element.load()
    if (!this.reducedMotion) this.element.play?.().catch(() => {})
    this.loaded = true
  }

  addPlaybackControl() {
    this.control = document.createElement("button")
    this.control.type = "button"
    this.control.className = "mt-3 rounded-lg bg-white px-3 py-2 text-sm font-semibold text-slate-900"
    this.control.textContent = this.reducedMotion ? "Video abspielen" : "Video pausieren"
    this.control.addEventListener("click", () => this.togglePlayback())
    this.element.insertAdjacentElement("afterend", this.control)
  }

  togglePlayback() {
    if (this.element.paused) {
      this.element.play().catch(() => {})
      this.control.textContent = "Video pausieren"
    } else {
      this.element.pause()
      this.control.textContent = "Video abspielen"
    }
  }
}
