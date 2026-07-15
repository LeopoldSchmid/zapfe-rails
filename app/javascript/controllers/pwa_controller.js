import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["install", "iosHint"]

  connect() {
    if (!("serviceWorker" in navigator)) return

    navigator.serviceWorker.register("/service-worker.js")
    window.addEventListener("beforeinstallprompt", this.captureInstallPrompt)
    window.addEventListener("appinstalled", this.hideInstall)

    if (this.hasIosHintTarget && this.isIos() && !window.navigator.standalone) this.iosHintTarget.hidden = false
  }

  disconnect() {
    window.removeEventListener("beforeinstallprompt", this.captureInstallPrompt)
    window.removeEventListener("appinstalled", this.hideInstall)
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

  isIos() {
    return /iPad|iPhone|iPod/.test(navigator.userAgent) || (navigator.platform === "MacIntel" && navigator.maxTouchPoints > 1)
  }
}
