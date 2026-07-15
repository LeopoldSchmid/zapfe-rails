import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["enable", "disable", "test", "status"]
  static values = { vapidPublicKey: String }

  async connect() {
    if (!("serviceWorker" in navigator) || !("PushManager" in window) || !this.vapidPublicKeyValue) return

    this.registration = await navigator.serviceWorker.ready
    this.subscription = await this.registration.pushManager.getSubscription()
    this.render()
  }

  async enable() {
    const permission = await Notification.requestPermission()
    if (permission !== "granted") return this.setStatus("Benachrichtigungen wurden nicht erlaubt.")

    this.subscription = await this.registration.pushManager.subscribe({
      userVisibleOnly: true,
      applicationServerKey: this.urlBase64ToUint8Array(this.vapidPublicKeyValue)
    })
    await this.save()
    this.render()
    this.setStatus("Benachrichtigungen sind aktiv.")
  }

  async disable() {
    if (!this.subscription) return

    await this.request("DELETE", `/admin/push_subscription?endpoint=${encodeURIComponent(this.subscription.endpoint)}`)
    await this.subscription.unsubscribe()
    this.subscription = null
    this.render()
    this.setStatus("Benachrichtigungen sind deaktiviert.")
  }

  async test() {
    if (!this.subscription) return

    await this.request("POST", "/admin/push_subscription/test", { endpoint: this.subscription.endpoint })
    this.setStatus("Testbenachrichtigung wird gesendet.")
  }

  async save() {
    const keys = this.subscription.toJSON().keys
    await this.request("POST", "/admin/push_subscription", {
      endpoint: this.subscription.endpoint,
      p256dh: keys.p256dh,
      auth: keys.auth
    })
  }

  async request(method, url, pushSubscription = null) {
    const response = await fetch(url, {
      method,
      headers: {
        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']")?.content,
        "Content-Type": "application/json",
        "Accept": "application/json"
      },
      body: pushSubscription ? JSON.stringify({ push_subscription: pushSubscription }) : null
    })
    if (!response.ok) throw new Error("Push subscription request failed")
  }

  render() {
    const active = Boolean(this.subscription)
    this.enableTarget.hidden = active
    this.disableTarget.hidden = !active
    this.testTarget.hidden = !active
  }

  setStatus(message) {
    this.statusTarget.textContent = message
  }

  urlBase64ToUint8Array(value) {
    const base64 = `${value}${"=".repeat((4 - value.length % 4) % 4)}`.replace(/-/g, "+").replace(/_/g, "/")
    return Uint8Array.from(atob(base64), (character) => character.charCodeAt(0))
  }
}
