import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    document.documentElement.classList.add("js")
    this.beforeRenderHandler = this.beforeRender.bind(this)
    this.resetHandler = this.resetPageState.bind(this)
    document.addEventListener("turbo:before-render", this.beforeRenderHandler)
    document.addEventListener("turbo:render", this.resetHandler)
    document.addEventListener("turbo:before-cache", this.resetHandler)
    window.addEventListener("pageshow", this.resetHandler)
    this.resetPageState()
  }

  disconnect() {
    document.removeEventListener("turbo:before-render", this.beforeRenderHandler)
    document.removeEventListener("turbo:render", this.resetHandler)
    document.removeEventListener("turbo:before-cache", this.resetHandler)
    window.removeEventListener("pageshow", this.resetHandler)
  }

  beforeRender(event) {
    const current = document.getElementById("page-content")
    const next = event.detail.newBody?.querySelector("#page-content")
    if (!current || !next) return

    event.preventDefault()
    current.classList.add("page-leave-active")

    setTimeout(() => {
      event.detail.resume()
      requestAnimationFrame(() => {
        const entered = document.getElementById("page-content")
        if (!entered) return

        entered.classList.add("page-enter-active")
        setTimeout(() => entered.classList.remove("page-enter-active"), 260)
      })
      }, 140)
  }

  resetPageState() {
    const page = document.getElementById("page-content")
    if (!page) return

    page.classList.remove("page-leave-active", "page-enter-active")
  }
}
