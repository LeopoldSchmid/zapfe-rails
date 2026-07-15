import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.form = document.querySelector('form[action$="/line_items"]')
    this.productSelect = this.form?.querySelector('select[name="offer_line_item[product_variant_id]"]')
    if (!this.form || !this.productSelect || this.form.dataset.positionSearchReady) return

    this.form.dataset.positionSearchReady = "true"
    this.supplierSelect = this.form.querySelector('select[name="offer_line_item[supplier_offering_id]"]')
    this.resourceSelect = this.form.querySelector('select[name="offer_line_item[resource_id]"]')
    this.supplierWrapper = this.form.querySelector("[data-position-supplier]")
    this.sourceWrapper = this.form.querySelector("[data-position-source]")
    this.sourceLabel = this.form.querySelector("[data-position-source-label]")
    this.clearSupplierOfferings()
    this.productSelect.addEventListener("change", () => this.selectProduct())
    this.bindLineItemDeletes()
    this.insertSearchField()
    this.loadResources()
  }

  insertSearchField() {
    const wrapper = document.createElement("div")
    wrapper.className = "md:col-span-2"
    wrapper.innerHTML = '<label class="block text-sm font-medium" for="offer-position-search">Suchen und auswählen</label><input id="offer-position-search" type="search" placeholder="Getränk, Zapfanlage, Kegerator …" autocomplete="off" class="admin-field"><div class="mt-2 hidden overflow-hidden rounded-xl border border-slate-200 bg-white shadow-sm" data-position-search-results></div>'
    this.form.querySelector("[data-position-search-anchor]").before(wrapper)
    this.searchInput = wrapper.querySelector("input")
    this.results = wrapper.querySelector("[data-position-search-results]")
    this.searchInput.addEventListener("input", (event) => this.filter(event.target.value))
  }

  async loadResources() {
    const endpoint = new URL(this.form.action).pathname.replace(/\/line_items$/, "/position_options")
    const response = await fetch(endpoint, { headers: { Accept: "application/json" } })
    if (!response.ok) return

    const resources = await response.json()
    if (!this.resourceSelect) return
    this.resourceSelect.replaceChildren(new Option("", ""))
    resources.forEach((resource) => {
      const option = new Option(resource.label, resource.id)
      option.dataset.price = resource.price || ""
      option.dataset.unit = resource.unit || "Tag"
      this.resourceSelect.add(option)
    })
    this.resourceSelect.addEventListener("change", () => this.selectResource())
    this.filter(this.searchInput.value)
  }

  filter(value) {
    const query = value.trim().toLowerCase()
    ;[this.productSelect, this.resourceSelect].filter(Boolean).forEach((select) => {
      Array.from(select.options).forEach((option) => {
        option.hidden = Boolean(query) && !option.text.toLowerCase().includes(query)
      })
    })
    this.renderResults(query)
  }

  renderResults(query) {
    if (!this.results) return

    this.results.replaceChildren()
    if (!query) {
      this.results.classList.add("hidden")
      return
    }

    const matches = [
      ...Array.from(this.productSelect.options).filter((option) => option.value && option.text.toLowerCase().includes(query)).map((option) => ({ type: "Getränk", option, select: this.productSelect })),
      ...Array.from(this.resourceSelect?.options || []).filter((option) => option.value && option.text.toLowerCase().includes(query)).map((option) => ({ type: "Mietposition", option, select: this.resourceSelect }))
    ].slice(0, 12)

    if (matches.length === 0) {
      const empty = document.createElement("p")
      empty.className = "px-3 py-2 text-sm text-slate-500"
      empty.textContent = "Keine passende Position gefunden."
      this.results.append(empty)
    } else {
      matches.forEach(({ type, option, select }) => {
        const button = document.createElement("button")
        button.type = "button"
        button.className = "flex w-full items-center justify-between gap-3 border-b border-slate-100 px-3 py-2 text-left text-sm last:border-b-0 hover:bg-slate-50"
        const label = document.createElement("span")
        label.textContent = option.text
        const kind = document.createElement("span")
        kind.className = "shrink-0 text-xs text-slate-500"
        kind.textContent = type
        button.append(label, kind)
        button.addEventListener("click", () => {
          select.value = option.value
          select === this.productSelect ? this.selectProduct() : this.selectResource()
          this.searchInput.value = option.text
          this.renderResults("")
        })
        this.results.append(button)
      })
    }
    this.results.classList.remove("hidden")
  }

  selectResource() {
    const option = this.resourceSelect.selectedOptions[0]
    if (!option?.value) return

    this.productSelect.value = ""
    const price = this.form.querySelector('input[name="offer_line_item[net_unit_price]"]')
    const unit = this.form.querySelector('input[name="offer_line_item[unit]"]')
    const description = this.form.querySelector('input[name="offer_line_item[description]"]')
    if (price) price.value = option.dataset.price
    if (unit) unit.value = option.dataset.unit
    if (description) description.value = option.text
    this.clearSupplierOfferings()
    if (this.supplierWrapper) this.supplierWrapper.hidden = true
    if (this.sourceWrapper) this.sourceWrapper.hidden = false
    if (this.sourceLabel) this.sourceLabel.textContent = `Eigene Ressource · ${option.text}`
    this.form.dispatchEvent(new Event("zapfe:dirty"))
  }

  async selectProduct() {
    const option = this.productSelect.selectedOptions[0]
    if (!option?.value) return

    if (this.resourceSelect) this.resourceSelect.value = ""
    const description = this.form.querySelector('input[name="offer_line_item[description]"]')
    const unit = this.form.querySelector('input[name="offer_line_item[unit]"]')
    if (description) description.value = option.text
    if (unit && option.dataset.salesUnit) unit.value = option.dataset.salesUnit
    if (this.sourceWrapper) this.sourceWrapper.hidden = true
    if (this.supplierWrapper) this.supplierWrapper.hidden = false
    await this.loadSupplierOfferings(option.value)
    this.form.dispatchEvent(new Event("zapfe:dirty"))
  }

  clearSupplierOfferings() {
    if (!this.supplierSelect) return

    this.supplierSelect.replaceChildren(new Option("Zuerst Getränk auswählen", ""))
    this.supplierSelect.disabled = true
    if (this.supplierWrapper) this.supplierWrapper.hidden = true
  }

  async loadSupplierOfferings(productVariantId) {
    if (!this.supplierSelect) return

    this.supplierSelect.replaceChildren(new Option("Bezugsquellen werden geladen …", ""))
    this.supplierSelect.disabled = true
    const endpoint = new URL(this.form.action).pathname.replace(/\/line_items$/, `/supplier_options?product_variant_id=${productVariantId}`)
    const response = await fetch(endpoint, { headers: { Accept: "application/json" } })
    if (!response.ok) return this.clearSupplierOfferings()

    const { offerings, net_unit_price } = await response.json()
    this.supplierSelect.replaceChildren(new Option("Keine Bezugsquelle", ""))
    offerings.forEach((offering) => this.supplierSelect.add(new Option(offering.label, offering.id, offering.preferred, offering.preferred)))
    this.supplierSelect.disabled = offerings.length === 0
    if (this.supplierWrapper) this.supplierWrapper.hidden = false
    const price = this.form.querySelector('input[name="offer_line_item[net_unit_price]"]')
    if (price && (!price.value || Number(price.value) === 0)) price.value = net_unit_price
  }

  bindLineItemDeletes() {
    document.querySelectorAll('form[action*="/line_items/"]').forEach((form) => {
      const removeButton = Array.from(form.querySelectorAll("button")).find((button) => button.textContent.trim() === "Entfernen")
      if (!removeButton || removeButton.dataset.deleteBound) return

      removeButton.dataset.deleteBound = "true"
      removeButton.addEventListener("click", async (event) => {
        event.preventDefault()
        if (!window.confirm("Position wirklich entfernen?")) return

        const response = await fetch(form.action, {
          method: "DELETE",
          headers: {
            "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')?.content,
            Accept: "text/html"
          }
        })
        if (response.redirected) window.location.assign(response.url)
      })
    })
  }
}
