import { Controller } from "@hotwired/stimulus"
import { clearCart, getCart, saveCart, upsertCartItem } from "controllers/shared/cart_store"
import { renderCalculatorCart } from "controllers/shared/cart_dom"
import { filterCardsByQuery, formatCurrency, formatDateDE, normalizeText, setElementVisibility, showToast } from "controllers/shared/ui_helpers"

const STORAGE_KEY = "zapfe_calculator_form_v1"

export default class extends Controller {
  connect() {
    this.form = document.getElementById("calculator-form")
    if (!this.form) return

    this.cacheElements()
    this.restoreState()
    this.setupDefaultDates()
    this.syncRentalDates()
    this.bindEvents()
    this.toggleDrinkMode()
    this.renderCart()
    this.calculate()
    this.applyDrinkSearch()
    this.refreshScrollButtons()
  }

  disconnect() {
    if (this.drinksTrack && this.refreshScrollButtonsBound) {
      this.drinksTrack.removeEventListener("scroll", this.refreshScrollButtonsBound)
    }

    if (this.refreshScrollButtonsBound) {
      window.removeEventListener("resize", this.refreshScrollButtonsBound)
    }
  }

  cacheElements() {
    this.selectedOptionsInput = document.getElementById("selected-options")
    this.selectedProductInput = document.getElementById("selected-product-hidden")
    this.rentalModeInput = document.getElementById("rental-mode-hidden")
    this.rentalDaysInput = document.getElementById("rental-days-hidden")
    this.startTimeInput = document.getElementById("start-time-hidden")
    this.endTimeInput = document.getElementById("end-time-hidden")
    this.bringOwnDrinksInput = document.getElementById("bring-own-drinks-hidden")
    this.glassesRequestedInput = document.getElementById("glasses-requested-hidden")
    this.totalPriceInput = document.getElementById("total-price-input")
    this.pricingSnapshotInput = document.getElementById("pricing-snapshot")
    this.eventDateHidden = document.getElementById("event-date-hidden")
    this.totalPriceEl = document.getElementById("total-price")
    this.rentalSummaryEl = document.getElementById("rental-summary")

    this.startDate = document.getElementById("rental-start-date")
    this.endDate = document.getElementById("rental-end-date")
    this.bringOwnDrinks = document.getElementById("bring-own-drinks")
    this.productOptions = Array.from(this.element.querySelectorAll('input[name="product_option"]'))
    this.drinksMode = document.getElementById("calc-drinks-mode")
    this.ownDrinksNote = document.getElementById("calc-own-drinks-note")

    this.searchInput = document.getElementById("calc-drinks-search")
    this.featuredFilter = document.getElementById("calc-filter-featured")
    this.drinkCards = Array.from(this.element.querySelectorAll(".calc-drink-card"))
    this.drinksTrack = document.getElementById("calc-drinks-track")
    this.emptyState = document.getElementById("calc-no-results")
    this.scrollLeftBtn = document.getElementById("calc-scroll-left")
    this.scrollRightBtn = document.getElementById("calc-scroll-right")
    this.cartItemsEl = document.getElementById("calc-cart-items")
    this.cartHintEl = document.getElementById("calc-cart-hint")
    this.clearCartButton = document.getElementById("calc-clear-cart")
    this.pricingRentalLabel = document.getElementById("pricing-rental-label")
    this.pricingRentalValue = document.getElementById("pricing-rental-value")
    this.pricingDrinksRow = document.getElementById("pricing-drinks-row")
    this.pricingDrinksValue = document.getElementById("pricing-drinks-value")
    this.pricingTotalDetail = document.getElementById("pricing-total-detail")
    this.persistedFields = Array.from(this.form.querySelectorAll("input, select, textarea")).filter((field) => field.name)
  }

  setupDefaultDates() {
    const today = new Date()
    const tomorrow = new Date(today)
    tomorrow.setDate(today.getDate() + 1)
    const toISO = (date) => date.toISOString().slice(0, 10)

    if (this.startDate && !this.startDate.value) this.startDate.value = toISO(today)
    if (this.endDate && !this.endDate.value) this.endDate.value = toISO(tomorrow)
  }

  bindEvents() {
    this.form.addEventListener("submit", () => this.saveState())

    this.drinkCards.forEach((card) => {
      Array.from(card.querySelectorAll(".calc-variant")).forEach((button) => {
        button.addEventListener("click", () => this.applyVariantStyles(card, button))
      })

      card.querySelector(".calc-add-drink")?.addEventListener("click", () => this.addSelectedDrink(card))
    })

    this.searchInput?.addEventListener("input", () => this.applyDrinkSearch())
    this.featuredFilter?.addEventListener("change", () => this.applyDrinkSearch())

    this.scrollLeftBtn?.addEventListener("click", () => {
      if (!this.drinksTrack) return
      this.drinksTrack.scrollBy({ left: -Math.max(200, this.drinksTrack.clientWidth * 0.7), behavior: "smooth" })
    })

    this.scrollRightBtn?.addEventListener("click", () => {
      if (!this.drinksTrack) return
      this.drinksTrack.scrollBy({ left: Math.max(200, this.drinksTrack.clientWidth * 0.7), behavior: "smooth" })
    })

    this.refreshScrollButtonsBound = this.refreshScrollButtons.bind(this)
    this.drinksTrack?.addEventListener("scroll", this.refreshScrollButtonsBound)
    window.addEventListener("resize", this.refreshScrollButtonsBound)

    this.cartItemsEl?.addEventListener("click", (event) => this.updateCartQuantity(event))
    this.clearCartButton?.addEventListener("click", () => this.handleClearCart())

    this.startDate?.addEventListener("change", () => {
      this.syncRentalDates()
      this.calculate()
    })

    this.productOptions.forEach((input) => {
      input.addEventListener("change", () => this.calculate())
    })

    this.endDate?.addEventListener("change", () => this.calculate())

    this.form.addEventListener("change", () => this.calculate())
    this.form.addEventListener("input", () => this.calculate())

    this.bringOwnDrinks?.addEventListener("change", () => {
      this.toggleDrinkMode()
      this.renderCart()
      this.calculate()
    })
  }

  restoreState() {
    let savedState = null

    try {
      savedState = JSON.parse(window.localStorage.getItem(STORAGE_KEY) || "{}")
    } catch (_error) {
      savedState = {}
    }

    this.persistedFields?.forEach((field) => {
      const savedValue = savedState[field.name]
      if (savedValue === undefined) return

      if (field instanceof HTMLInputElement && (field.type === "radio")) {
        field.checked = field.value === savedValue
        return
      }

      if (field instanceof HTMLInputElement && field.type === "checkbox") {
        field.checked = !!savedValue
        return
      }

      field.value = savedValue
    })
  }

  saveState() {
    if (!this.persistedFields?.length) return

    const state = {}

    this.persistedFields.forEach((field) => {
      if (field instanceof HTMLInputElement && field.type === "radio") {
        if (field.checked) state[field.name] = field.value
        return
      }

      if (field instanceof HTMLInputElement && field.type === "checkbox") {
        state[field.name] = field.checked
        return
      }

      state[field.name] = field.value
    })

    window.localStorage.setItem(STORAGE_KEY, JSON.stringify(state))
  }

  dayCount() {
    if (!this.startDate?.value || !this.endDate?.value) return 1

    const startsOn = new Date(`${this.startDate.value}T00:00:00`)
    const endsOn = new Date(`${this.endDate.value}T00:00:00`)
    const diff = Math.ceil((endsOn - startsOn) / (1000 * 60 * 60 * 24))

    return Math.max(1, diff)
  }

  syncRentalDates() {
    if (!this.startDate?.value || !this.endDate) return

    const startsOn = new Date(`${this.startDate.value}T00:00:00`)
    if (Number.isNaN(startsOn.getTime())) return

    const currentEnd = this.endDate.value ? new Date(`${this.endDate.value}T00:00:00`) : null
    const needsDefaultEnd = !currentEnd || Number.isNaN(currentEnd.getTime()) || currentEnd <= startsOn

    if (needsDefaultEnd) {
      const endsOn = new Date(startsOn)
      endsOn.setDate(endsOn.getDate() + 1)
      this.endDate.value = endsOn.toISOString().slice(0, 10)
    }
  }

  getSelectedVariant(card) {
    return card.querySelector('.calc-variant[data-selected="1"]') || card.querySelector(".calc-variant")
  }

  applyVariantStyles(card, selectedButton) {
    card.querySelectorAll(".calc-variant").forEach((button) => {
      button.dataset.selected = "0"
      button.classList.remove("border-[var(--color-zapfe-amber)]", "bg-[var(--color-zapfe-amber)]/20")
      button.classList.add("border-slate-300")
    })

    selectedButton.dataset.selected = "1"
    selectedButton.classList.remove("border-slate-300")
    selectedButton.classList.add("border-[var(--color-zapfe-amber)]", "bg-[var(--color-zapfe-amber)]/20")

    const price = Number(selectedButton.dataset.price || 0)
    const size = Number(selectedButton.dataset.size || 1)
    const priceEl = card.querySelector(".calc-price")
    const perEl = card.querySelector(".calc-price-per")

    if (priceEl) priceEl.textContent = formatCurrency(price)
    if (perEl) perEl.textContent = `${formatCurrency(price / size)}/L`
  }

  addSelectedDrink(card) {
    const selected = this.getSelectedVariant(card)
    if (!selected || selected.dataset.available !== "1") return

    upsertCartItem({
      variantId: selected.dataset.variantId,
      name: selected.dataset.productName,
      brand: selected.dataset.productBrand,
      label: selected.dataset.productLabel,
      size: Number(selected.dataset.size || 0),
      price: Number(selected.dataset.price || 0),
      qty: 1
    })

    showToast("Produkt zum Warenkorb hinzugefügt")
    this.renderCart()
    this.calculate()
  }

  renderCart() {
    const cart = getCart()

    renderCalculatorCart({
      container: this.cartItemsEl,
      hint: this.cartHintEl,
      cart,
      ownDrinksSelected: !!this.bringOwnDrinks?.checked
    })

    setElementVisibility(this.clearCartButton, cart.length > 0)
  }

  buildPricingSnapshot({ rentalInput, rentalBase, days, rentalTotal, drinksTotal, ownDrinksSelected, total, cart, activeCart }) {
    return {
      rentalOption: rentalInput?.value,
      rentalBase,
      days,
      rentalTotal,
      drinksTotal,
      bringOwnDrinks: ownDrinksSelected,
      glassesRental: false,
      delivery: false,
      deliveryAddress: {},
      timing: {
        startsOn: this.startDate?.value || "",
        endsOn: this.endDate?.value || "",
        startTime: "",
        endTime: ""
      },
      cart,
      activeCart,
      total
    }
  }

  calculate() {
    this.syncRentalDates()

    const selectedProduct = this.productOptions.find((input) => input.checked)?.value || "Piaggio Ape"
    const rentalInput = this.form.querySelector('input[name="rental_option"]:checked')
    const rentalBase = Number(rentalInput?.dataset.base || 0)
    const rentalLabel = rentalInput?.value === "self" ? "Zapf & Pay" : "Zapf"
    const days = this.dayCount()
    const rentalTotal = rentalBase * days

    const cart = getCart()
    const ownDrinksSelected = !!this.bringOwnDrinks?.checked
    const activeCart = ownDrinksSelected ? [] : cart
    const drinksTotal = activeCart.reduce((sum, item) => sum + item.price * item.qty, 0)
    const total = rentalTotal + drinksTotal

    if (this.pricingRentalLabel) this.pricingRentalLabel.textContent = `Miete (${rentalLabel})`
    if (this.pricingRentalValue) this.pricingRentalValue.textContent = formatCurrency(rentalTotal)

    if (this.pricingDrinksRow) {
      const showDrinksRow = ownDrinksSelected || drinksTotal > 0
      setElementVisibility(this.pricingDrinksRow, showDrinksRow)
      if (this.pricingDrinksValue) this.pricingDrinksValue.textContent = ownDrinksSelected ? "nicht eingerechnet" : formatCurrency(drinksTotal)
    }

    if (this.rentalSummaryEl) {
      this.rentalSummaryEl.textContent = `${formatDateDE(this.startDate?.value)} bis ${formatDateDE(this.endDate?.value)} · ${formatCurrency(rentalTotal)} Miete`
    }

    if (this.totalPriceEl) this.totalPriceEl.textContent = formatCurrency(total)
    if (this.pricingTotalDetail) this.pricingTotalDetail.textContent = formatCurrency(total)
    if (this.totalPriceInput) this.totalPriceInput.value = total.toFixed(2)
    if (this.eventDateHidden) this.eventDateHidden.value = this.startDate?.value || ""
    if (this.selectedProductInput) this.selectedProductInput.value = selectedProduct
    if (this.rentalModeInput) this.rentalModeInput.value = rentalInput?.value || ""
    if (this.rentalDaysInput) this.rentalDaysInput.value = String(days)
    if (this.startTimeInput) this.startTimeInput.value = ""
    if (this.endTimeInput) this.endTimeInput.value = ""
    if (this.bringOwnDrinksInput) this.bringOwnDrinksInput.value = ownDrinksSelected ? "1" : "0"
    if (this.glassesRequestedInput) this.glassesRequestedInput.value = "0"

    const options = []
    options.push(`Produkt: ${selectedProduct}`)
    options.push(`Option: ${rentalLabel} (${formatCurrency(rentalBase)} pro Tag)`)
    options.push(`Datum: ${formatDateDE(this.startDate?.value)} bis ${formatDateDE(this.endDate?.value)}`)
    options.push(`Getränke: ${ownDrinksSelected ? "selbst organisiert" : "über Zapfe!"}`)

    activeCart.forEach((item) => {
      options.push(`Getränk: ${item.label || `${item.brand} ${item.name}`} ${item.size}L x ${item.qty} = ${formatCurrency(item.price * item.qty)}`)
    })

    if (this.selectedOptionsInput) this.selectedOptionsInput.value = options.join("\n")

    if (this.pricingSnapshotInput) {
      this.pricingSnapshotInput.value = JSON.stringify(
        this.buildPricingSnapshot({ rentalInput, rentalBase, days, rentalTotal, drinksTotal, ownDrinksSelected, total, cart, activeCart })
      )
    }

    this.saveState()
  }

  refreshScrollButtons() {
    if (!this.drinksTrack || !this.scrollLeftBtn || !this.scrollRightBtn) return

    if (this.drinksTrack.hidden || this.drinksTrack.closest("[hidden]")) {
      this.scrollLeftBtn.classList.add("hidden")
      this.scrollRightBtn.classList.add("hidden")
      return
    }

    const canLeft = this.drinksTrack.scrollLeft > 4
    const canRight = this.drinksTrack.scrollLeft < this.drinksTrack.scrollWidth - this.drinksTrack.clientWidth - 4
    this.scrollLeftBtn.classList.toggle("hidden", !canLeft)
    this.scrollRightBtn.classList.toggle("hidden", !canRight)
  }

  applyDrinkSearch() {
    const query = normalizeText(this.searchInput?.value)
    const featuredOnly = !!this.featuredFilter?.checked

    filterCardsByQuery({
      query,
      cards: this.drinkCards,
      getText: (card) => card.dataset.text,
      emptyState: this.emptyState,
      matchesBase: (card) => !featuredOnly || card.dataset.featured === "1"
    })

    this.refreshScrollButtons()
  }

  updateCartQuantity(event) {
    const button = event.target.closest("button")
    if (!button) return

    const cart = getCart()
    const index = Number(button.dataset.inc || button.dataset.dec || button.dataset.remove)
    if (Number.isNaN(index) || !cart[index]) return

    if (button.dataset.inc) cart[index].qty += 1
    if (button.dataset.dec) {
      cart[index].qty -= 1
      if (cart[index].qty <= 0) cart.splice(index, 1)
    }
    if (button.dataset.remove) cart.splice(index, 1)

    saveCart(cart)
    this.renderCart()
    this.calculate()
  }

  handleClearCart() {
    if (!getCart().length) return

    clearCart()
    this.renderCart()
    this.calculate()
    showToast("Warenkorb geleert")
  }

  toggleDrinkMode() {
    const ownDrinksSelected = !!this.bringOwnDrinks?.checked
    setElementVisibility(this.drinksMode, !ownDrinksSelected)
    setElementVisibility(this.ownDrinksNote, ownDrinksSelected)
    this.refreshScrollButtons()
  }
}
