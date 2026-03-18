import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["source"]

  connect() {
    this.loaded = false

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
  }

  load() {
    if (this.loaded) return

    this.sourceTargets.forEach((source) => {
      if (source.dataset.src) source.src = source.dataset.src
    })

    this.element.load()
    this.element.play?.().catch(() => {})
    this.loaded = true
  }
}
