import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.classList.add("reveal-init")
    this.observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            entry.target.classList.remove("reveal-init")
            entry.target.classList.add("reveal-visible")
            this.observer.unobserve(entry.target)
          }
        })
      },
      { threshold: 0.12 }
    )

    this.observer.observe(this.element)
  }

  disconnect() {
    if (this.observer) this.observer.disconnect()
  }
}
