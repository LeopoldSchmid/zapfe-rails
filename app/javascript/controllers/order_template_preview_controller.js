import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  change(event) {
    const url = new URL(window.location)

    if (event.target.value) {
      url.searchParams.set("order_template_id", event.target.value)
    } else {
      url.searchParams.delete("order_template_id")
    }

    window.location.assign(url)
  }
}
