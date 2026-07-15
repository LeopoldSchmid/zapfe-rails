import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["source", "button"]

  async copy() {
    const html = this.sourceTarget.innerHTML
    const text = this.sourceTarget.innerText

    try {
      await navigator.clipboard.write([
        new ClipboardItem({
          "text/html": new Blob([html], { type: "text/html" }),
          "text/plain": new Blob([text], { type: "text/plain" })
        })
      ])
    } catch {
      const selection = window.getSelection()
      const range = document.createRange()
      range.selectNodeContents(this.sourceTarget)
      selection.removeAllRanges()
      selection.addRange(range)
      document.execCommand("copy")
      selection.removeAllRanges()
    }

    this.buttonTarget.textContent = "Kopiert"
    window.setTimeout(() => { this.buttonTarget.textContent = "Bestelltext kopieren" }, 1800)
  }
}
