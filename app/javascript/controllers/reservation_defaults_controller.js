import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const eventDate = document.querySelector('input[name="order[event_date]"]')?.value
    if (!eventDate) return

    this.setIfBlank('input[name="reservation[starts_at]"]', `${eventDate}T09:00`)
    this.setIfBlank('input[name="reservation[ends_at]"]', `${eventDate}T18:00`)
  }

  setIfBlank(selector, value) {
    const field = document.querySelector(selector)
    if (field && !field.value) field.value = value
  }
}
