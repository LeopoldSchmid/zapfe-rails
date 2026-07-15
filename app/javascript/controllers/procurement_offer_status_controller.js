import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select", "notice"]

  connect() {
    this.update()
  }

  update() {
    this.noticeTarget.hidden = this.selectTarget.selectedOptions[0]?.dataset.offerStatus === "accepted"
  }
}
