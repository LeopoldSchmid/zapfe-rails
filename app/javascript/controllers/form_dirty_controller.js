import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.prepare = this.prepare.bind(this)
    document.addEventListener("turbo:load", this.prepare)
    this.prepare()
  }

  disconnect() {
    document.removeEventListener("turbo:load", this.prepare)
  }

  prepare() {
    requestAnimationFrame(() => this.element.querySelectorAll("form").forEach((form) => this.register(form)))
  }

  register(form) {
    if (form.dataset.dirtyReady || this.isDestructive(form) || !this.isUpdateForm(form) || !this.hasEditableFields(form)) return

    form.dataset.dirtyReady = "true"
    form.dataset.dirtySnapshot = this.snapshot(form)
    const refresh = () => this.refresh(form)
    form.addEventListener("input", refresh)
    form.addEventListener("change", refresh)
    form.addEventListener("zapfe:dirty", refresh)
    this.refresh(form)
  }

  refresh(form) {
    const dirty = this.snapshot(form) !== form.dataset.dirtySnapshot
    form.querySelectorAll('button[type="submit"], input[type="submit"]').forEach((button) => {
      button.disabled = !dirty
      button.classList.toggle("admin-action-disabled", !dirty)
    })
  }

  snapshot(form) {
    return Array.from(new FormData(form).entries())
      .filter(([name]) => !["authenticity_token", "_method", "commit"].includes(name))
      .map(([name, value]) => `${name}:${value instanceof File ? `${value.name}:${value.size}` : value}`)
      .sort()
      .join("|")
  }

  isDestructive(form) {
    return form.querySelector('input[name="_method"][value="delete"]')
  }

  isUpdateForm(form) {
    return form.querySelector('input[name="_method"][value="patch"], input[name="_method"][value="put"]')
  }

  hasEditableFields(form) {
    return form.querySelector('input:not([type="hidden"]):not([type="submit"]):not([type="button"]), select, textarea')
  }
}
