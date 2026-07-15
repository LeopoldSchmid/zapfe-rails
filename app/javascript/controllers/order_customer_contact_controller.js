import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["customer", "contact", "name", "email", "phone"]

  connect() {
    this.loadContacts()
  }

  async loadContacts() {
    const customerId = this.customerTarget.value
    const customerOption = this.customerTarget.selectedOptions[0]
    if (customerId && customerOption?.textContent) this.nameTarget.value = customerOption.textContent.trim()
    this.contactTarget.replaceChildren(new Option(customerId ? "Ansprechpartner werden geladen …" : "Ohne Ansprechpartner", ""))
    this.contactTarget.disabled = !customerId
    if (!customerId) return

    const response = await fetch(`/admin/customers/${customerId}/contact_options`, { headers: { Accept: "application/json" } })
    if (!response.ok) return

    const contacts = await response.json()
    this.contactTarget.replaceChildren(new Option("Ohne Ansprechpartner", ""))
    const selectedId = this.contactTarget.dataset.selectedId
    contacts.forEach((contact) => {
      const selected = selectedId ? String(contact.id) === selectedId : contact.primary
      const option = new Option(`${contact.name}${contact.primary ? " · Standard" : ""}`, contact.id, selected, selected)
      option.dataset.email = contact.email || ""
      option.dataset.phone = contact.phone || ""
      this.contactTarget.add(option)
    })
    this.contactTarget.disabled = false
    this.applyContact()
  }

  applyContact() {
    const option = this.contactTarget.selectedOptions[0]
    if (!option?.value) return

    if (option.dataset.email) this.emailTarget.value = option.dataset.email
    if (option.dataset.phone) this.phoneTarget.value = option.dataset.phone
  }
}
