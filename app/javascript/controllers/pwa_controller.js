import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["install", "iosHint"]

  async connect() {
    if (!("serviceWorker" in navigator)) return

    try {
      this.registration = await navigator.serviceWorker.register("/service-worker.js", { scope: "/admin/" })
      this.watchForUpdates()
    } catch (_error) {
      this.showStatus("App-Funktionen konnten nicht aktiviert werden. Die Online-Nutzung funktioniert weiter.")
    }
    window.addEventListener("beforeinstallprompt", this.captureInstallPrompt)
    window.addEventListener("appinstalled", this.hideInstall)
    navigator.serviceWorker.addEventListener("controllerchange", this.reloadAfterUpdate)

    if (this.hasIosHintTarget && this.isIos() && !window.navigator.standalone) this.iosHintTarget.hidden = false
  }

  disconnect() {
    window.removeEventListener("beforeinstallprompt", this.captureInstallPrompt)
    window.removeEventListener("appinstalled", this.hideInstall)
    navigator.serviceWorker?.removeEventListener("controllerchange", this.reloadAfterUpdate)
    this.updateButton?.remove()
    this.status?.remove()
  }

  captureInstallPrompt = (event) => {
    event.preventDefault()
    this.installPrompt = event
    if (this.hasInstallTarget) this.installTarget.hidden = false
  }

  hideInstall = () => {
    this.installPrompt = null
    if (this.hasInstallTarget) this.installTarget.hidden = true
  }

  async install() {
    if (!this.installPrompt) return

    await this.installPrompt.prompt()
    await this.installPrompt.userChoice
    this.hideInstall()
  }

  watchForUpdates() {
    if (this.registration.waiting) this.showUpdateAvailable()
    this.registration.addEventListener("updatefound", () => {
      const worker = this.registration.installing
      worker?.addEventListener("statechange", () => {
        if (worker.state === "installed" && navigator.serviceWorker.controller) this.showUpdateAvailable()
      })
    })
  }

  showUpdateAvailable() {
    if (this.updateButton) return
    this.updateButton = document.createElement("button")
    this.updateButton.type = "button"
    this.updateButton.className = "fixed bottom-4 right-4 z-[100] rounded-xl bg-slate-900 px-4 py-3 font-semibold text-white shadow-xl"
    this.updateButton.textContent = "Neue Version laden"
    this.updateButton.addEventListener("click", () => this.registration.waiting?.postMessage({ type: "SKIP_WAITING" }))
    document.body.appendChild(this.updateButton)
  }

  showStatus(message) {
    this.status = document.createElement("p")
    this.status.className = "fixed bottom-4 right-4 z-[100] max-w-sm rounded-xl bg-white px-4 py-3 text-sm text-slate-900 shadow-xl"
    this.status.setAttribute("role", "status")
    this.status.textContent = message
    document.body.appendChild(this.status)
  }

  reloadAfterUpdate = () => {
    if (this.reloading) return
    this.reloading = true
    window.location.reload()
  }

  isIos() {
    return /iPad|iPhone|iPod/.test(navigator.userAgent) || (navigator.platform === "MacIntel" && navigator.maxTouchPoints > 1)
  }
}
