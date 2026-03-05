import { Controller } from "@hotwired/stimulus"
import { getCart, saveCart, upsertCartItem } from "controllers/shared/cart_store"
import { renderCalculatorCart } from "controllers/shared/cart_dom"
import { filterCardsByQuery, formatCurrency, formatDateDE, normalizeText, setElementVisibility, showToast } from "controllers/shared/ui_helpers"

export default class extends Controller {
  connect() {
    this.form = document.getElementById("calculator-form")
    if (!this.form) return

    this.cacheElements()
    this.setupDefaultDates()
    this.bindEvents()
    this.toggleDeliveryFields()
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
    this.startHour = document.getElementById("start-hour")
    this.startMinute = document.getElementById("start-minute")
    this.endHour = document.getElementById("end-hour")
    this.endMinute = document.getElementById("end-minute")

    this.glassesRental = document.getElementById("glasses-rental")
    this.bringOwnDrinks = document.getElementById("bring-own-drinks")
    this.deliveryEnabled = document.getElementById("delivery-enabled")
    this.deliveryFields = document.getElementById("delivery-fields")
    this.deliveryStreet = document.getElementById("delivery-street")
    this.deliveryPostcode = document.getElementById("delivery-postcode")
    this.deliveryCity = document.getElementById("delivery-city")

    this.searchInput = document.getElementById("calc-drinks-search")
    this.drinksMode = document.getElementById("calc-drinks-mode")
    this.tapHeadsMode = document.getElementById("calc-tap-heads-mode")
    this.drinkCards = Array.from(this.element.querySelectorAll(".calc-drink-card"))
    this.drinksTrack = document.getElementById("calc-drinks-track")
    this.emptyState = document.getElementById("calc-no-results")
    this.scrollLeftBtn = document.getElementById("calc-scroll-left")
    this.scrollRightBtn = document.getElementById("calc-scroll-right")
    this.cartItemsEl = document.getElementById("calc-cart-items")
    this.cartHintEl = document.getElementById("calc-cart-hint")
    this.pricingRentalLabel = document.getElementById("pricing-rental-label")
    this.pricingRentalValue = document.getElementById("pricing-rental-value")
    this.pricingDrinksRow = document.getElementById("pricing-drinks-row")
    this.pricingDrinksValue = document.getElementById("pricing-drinks-value")
    this.pricingGlassesRow = document.getElementById("pricing-glasses-row")
    this.pricingTotalDetail = document.getElementById("pricing-total-detail")
  }

  setupDefaultDates() {
    const today = new Date()
    const tomorrow = new Date(today)
    tomorrow.setDate(today.getDate() + 1)
    const toISO = (date) => date.toISOString().slice(0, 10)

    if (this.startDate && !this.startDate.value) this.startDate.value = toISO(today)
    if (this.endDate && !this.endDate.value) this.endDate.value = toISO(tomorrow)
    if (this.startHour && !this.startHour.value) this.startHour.value = "18"
    if (this.startMinute && !this.startMinute.value) this.startMinute.value = "00"
  }

  bindEvents() {
    this.drinkCards.forEach((card) => {
      Array.from(card.querySelectorAll(".calc-variant")).forEach((button) => {
        button.addEventListener("click", () => this.applyVariantStyles(card, button))
      })

      card.querySelector(".calc-add-drink")?.addEventListener("click", () => this.addSelectedDrink(card))
    })

    this.searchInput?.addEventListener("input", () => this.applyDrinkSearch())

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

    this.form.addEventListener("change", () => this.calculate())
    this.form.addEventListener("input", () => this.calculate())

    this.deliveryEnabled?.addEventListener("change", () => {
      this.toggleDeliveryFields()
      this.calculate()
    })

    this.bringOwnDrinks?.addEventListener("change", () => {
      this.toggleDrinkMode()
      this.renderCart()
      this.calculate()
    })

    this.bringOwnDrinks?.addEventListener("input", () => this.toggleDrinkMode())
  }

  dayCount() {
    if (!this.startDate?.value || !this.endDate?.value) return 1

    const from = new Date(this.startDate.value)
    const to = new Date(this.endDate.value)
    const diff = Math.ceil((to - from) / (1000 * 60 * 60 * 24))

    return Math.max(1, diff)
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
    renderCalculatorCart({
      container: this.cartItemsEl,
      hint: this.cartHintEl,
      cart: getCart(),
      ownDrinksSelected: !!this.bringOwnDrinks?.checked
    })
  }

  buildPricingSnapshot({ rentalInput, rentalBase, days, rentalTotal, drinksTotal, ownDrinksSelected, total, cart, activeCart }) {
    return {
      rentalOption: rentalInput?.value,
      rentalBase,
      days,
      rentalTotal,
      drinksTotal,
      bringOwnDrinks: ownDrinksSelected,
      glassesRental: !!this.glassesRental?.checked,
      delivery: !!this.deliveryEnabled?.checked,
      deliveryAddress: {
        street: this.deliveryStreet?.value || "",
        postcode: this.deliveryPostcode?.value || "",
        city: this.deliveryCity?.value || ""
      },
      timing: {
        startsOn: this.startDate?.value || "",
        endsOn: this.endDate?.value || "",
        startTime: `${this.startHour?.value || ""}:${this.startMinute?.value || ""}`.replace(/:$/, ""),
        endTime: `${this.endHour?.value || ""}:${this.endMinute?.value || ""}`.replace(/:$/, "")
      },
      cart,
      activeCart,
      total
    }
  }

  calculate() {
    const rentalInput = this.form.querySelector('input[name="rental_option"]:checked')
    const rentalBase = Number(rentalInput?.dataset.base || 0)
    const rentalLabel = rentalInput?.value === "self" ? "Zapf & Pay" : "Zapf"
    const days = this.dayCount()
    const rentalTotal = rentalBase * days

    const cart = getCart()
    const ownDrinksSelected = !!this.bringOwnDrinks?.checked
    const activeCart = ownDrinksSelected ? [] : cart
    const drinksTotal = activeCart.reduce((sum, item) => sum + item.price * item.qty, 0)
    const glassesTotal = 0
    const total = rentalTotal + drinksTotal + glassesTotal

    if (this.pricingRentalLabel) this.pricingRentalLabel.textContent = `Grundmiete (${rentalLabel})`
    if (this.pricingRentalValue) this.pricingRentalValue.textContent = formatCurrency(rentalTotal)

    if (this.pricingDrinksRow) {
      const showDrinksRow = ownDrinksSelected || drinksTotal > 0
      setElementVisibility(this.pricingDrinksRow, showDrinksRow)
      if (this.pricingDrinksValue) {
        this.pricingDrinksValue.textContent = ownDrinksSelected ? "pausiert" : formatCurrency(drinksTotal)
      }
    }

    if (this.pricingGlassesRow) {
      const visible = !!this.glassesRental?.checked
      setElementVisibility(this.pricingGlassesRow, visible)
      this.pricingGlassesRow.classList.toggle("flex", visible)
    }

    if (this.pricingTotalDetail) this.pricingTotalDetail.textContent = formatCurrency(total)
    if (this.rentalSummaryEl) this.rentalSummaryEl.textContent = `Grundmiete (${rentalLabel}) für ${days} Tag(e): ${formatCurrency(rentalTotal)}`
    if (this.totalPriceEl) this.totalPriceEl.textContent = formatCurrency(total)
    if (this.totalPriceInput) this.totalPriceInput.value = total.toFixed(2)
    if (this.eventDateHidden) this.eventDateHidden.value = this.startDate?.value || ""
    if (this.rentalModeInput) this.rentalModeInput.value = rentalInput?.value || ""
    if (this.rentalDaysInput) this.rentalDaysInput.value = String(days)
    if (this.startTimeInput) this.startTimeInput.value = `${this.startHour?.value || ""}:${this.startMinute?.value || "00"}`
    if (this.endTimeInput) this.endTimeInput.value = `${this.endHour?.value || ""}:${this.endMinute?.value || "00"}`
    if (this.bringOwnDrinksInput) this.bringOwnDrinksInput.value = ownDrinksSelected ? "1" : "0"
    if (this.glassesRequestedInput) this.glassesRequestedInput.value = this.glassesRental?.checked ? "1" : "0"

    const options = []
    options.push(`Option: ${rentalLabel} (${formatCurrency(rentalBase)} pro Tag)`)
    options.push(`Mietdauer: ${days} Tag(e)`)

    if (this.startDate?.value || this.endDate?.value) {
      options.push(`Datum: ${formatDateDE(this.startDate?.value)} bis ${formatDateDE(this.endDate?.value)}`)
    }

    if (this.startHour?.value || this.endHour?.value) {
      options.push(`Uhrzeit: ${this.startHour?.value || "HH"}:${this.startMinute?.value || "00"} bis ${this.endHour?.value || "HH"}:${this.endMinute?.value || "00"}`)
    }

    options.push(`Eigene Getränke: ${ownDrinksSelected ? "Ja (Getränkewarenkorb pausiert)" : "Nein"}`)

    if (this.glassesRental?.checked) options.push("Zusatzoption: Gläser gewünscht")

    if (this.deliveryEnabled?.checked) {
      options.push("Lieferung: Ja")
      const address = [this.deliveryStreet?.value, this.deliveryPostcode?.value, this.deliveryCity?.value].filter(Boolean).join(", ")
      if (address) options.push(`Lieferadresse: ${address}`)
    }

    if (ownDrinksSelected) {
      options.push("Zapfköpfe verfügbar: Flat Head für klassische Bierfässer, Korbfitting für Softdrinks und Limonadenfässer")
    } else {
      activeCart.forEach((item) => {
        options.push(`Getränk: ${item.brand} ${item.name} ${item.size}L x ${item.qty} = ${formatCurrency(item.price * item.qty)}`)
      })
    }

    if (this.selectedOptionsInput) this.selectedOptionsInput.value = options.join("\n")

    if (this.pricingSnapshotInput) {
      this.pricingSnapshotInput.value = JSON.stringify(
        this.buildPricingSnapshot({ rentalInput, rentalBase, days, rentalTotal, drinksTotal, ownDrinksSelected, total, cart, activeCart })
      )
    }
  }

  refreshScrollButtons() {
    if (!this.drinksTrack || !this.scrollLeftBtn || !this.scrollRightBtn) return

    const canLeft = this.drinksTrack.scrollLeft > 4
    const canRight = this.drinksTrack.scrollLeft < this.drinksTrack.scrollWidth - this.drinksTrack.clientWidth - 4
    this.scrollLeftBtn.classList.toggle("hidden", !canLeft)
    this.scrollRightBtn.classList.toggle("hidden", !canRight)
  }

  applyDrinkSearch() {
    const query = normalizeText(this.searchInput?.value)

    filterCardsByQuery({
      query,
      cards: this.drinkCards,
      getText: (card) => card.dataset.text,
      emptyState: this.emptyState
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

  toggleDeliveryFields() {
    setElementVisibility(this.deliveryFields, !!this.deliveryEnabled?.checked)
  }

  toggleDrinkMode() {
    const ownDrinksSelected = !!this.bringOwnDrinks?.checked
    setElementVisibility(this.drinksMode, !ownDrinksSelected)
    setElementVisibility(this.tapHeadsMode, ownDrinksSelected)
  }
}
