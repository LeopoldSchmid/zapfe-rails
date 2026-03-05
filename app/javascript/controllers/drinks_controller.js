import { Controller } from "@hotwired/stimulus"
import { getCart, saveCart, upsertCartItem } from "controllers/shared/cart_store"
import { renderDrinksCart } from "controllers/shared/cart_dom"
import { filterCardsByQuery, formatCurrency, normalizeText, setElementVisibility, showToast } from "controllers/shared/ui_helpers"

export default class extends Controller {
  connect() {
    this.cacheElements()
    this.bindEvents()
    this.renderCart()
    this.applyFilters()
  }

  cacheElements() {
    this.searchInput = document.getElementById("drinks-search")
    this.filtersPanel = document.getElementById("drinks-filters-panel")
    this.toggleFiltersButton = document.getElementById("toggle-drinks-filters")
    this.resetFiltersButton = document.getElementById("reset-drinks-filters")
    this.cards = Array.from(this.element.querySelectorAll(".drink-card"))
    this.countEl = document.getElementById("drinks-count")
    this.emptyState = document.getElementById("drinks-no-results")

    this.availableFilter = document.getElementById("filter-available")
    this.alcoholicRadios = Array.from(document.querySelectorAll('input[name="filter-alcoholic"]'))
    this.categoryFilters = Array.from(document.querySelectorAll(".filter-category"))
    this.subcategoryFilters = Array.from(document.querySelectorAll(".filter-subcategory"))
    this.brandFilters = Array.from(document.querySelectorAll(".filter-brand"))

    this.openCartButton = document.getElementById("open-cart")
    this.closeCartButton = document.getElementById("close-cart")
    this.cartPanel = document.getElementById("cart-panel")
    this.overlay = document.getElementById("cart-overlay")
    this.cartCount = document.getElementById("cart-count")
    this.cartItems = document.getElementById("cart-items")
    this.cartSubtotal = document.getElementById("cart-subtotal")
    this.cartDeposit = document.getElementById("cart-deposit")
    this.cartTotal = document.getElementById("cart-total")
  }

  bindEvents() {
    this.cards.forEach((card) => {
      Array.from(card.querySelectorAll(".drink-variant")).forEach((button) => {
        button.addEventListener("click", () => this.applyVariantStyles(card, button))
      })

      card.querySelector(".add-to-cart")?.addEventListener("click", () => this.addSelectedDrink(card))
    })

    this.cartItems?.addEventListener("click", (event) => this.updateCartQuantity(event))

    this.toggleFiltersButton?.addEventListener("click", () => {
      setElementVisibility(this.filtersPanel, this.filtersPanel?.classList.contains("hidden"))
    })

    this.resetFiltersButton?.addEventListener("click", () => this.resetFilters())

    this.searchInput?.addEventListener("input", () => this.applyFilters())
    ;[...this.categoryFilters, ...this.subcategoryFilters, ...this.brandFilters, ...this.alcoholicRadios].forEach((input) => {
      input.addEventListener("change", () => this.applyFilters())
    })
    this.availableFilter?.addEventListener("change", () => this.applyFilters())

    this.openCartButton?.addEventListener("click", () => this.openPanel())
    this.closeCartButton?.addEventListener("click", () => this.closePanel())
    this.overlay?.addEventListener("click", () => this.closePanel())
  }

  getSelectedValues(inputs) {
    return inputs.filter((input) => input.checked).map((input) => input.value)
  }

  applyVariantStyles(card, selectedButton) {
    card.querySelectorAll(".drink-variant").forEach((button) => {
      button.dataset.selected = "0"
      button.classList.remove("border-[var(--color-zapfe-amber)]", "bg-[var(--color-zapfe-amber)]/20")
      button.classList.add("border-slate-300")
    })

    selectedButton.dataset.selected = "1"
    selectedButton.classList.remove("border-slate-300")
    selectedButton.classList.add("border-[var(--color-zapfe-amber)]", "bg-[var(--color-zapfe-amber)]/20")

    const price = Number(selectedButton.dataset.price || 0)
    const size = Number(selectedButton.dataset.size || 1)
    const priceEl = card.querySelector(".drink-price")
    const perEl = card.querySelector(".drink-price-per")

    if (priceEl) priceEl.textContent = formatCurrency(price)
    if (perEl) perEl.textContent = `${formatCurrency(price / size)} /L`
  }

  selectedVariant(card) {
    return card.querySelector('.drink-variant[data-selected="1"]') || card.querySelector(".drink-variant")
  }

  applyFilters() {
    const query = normalizeText(this.searchInput?.value)
    const categories = this.getSelectedValues(this.categoryFilters)
    const subcategories = this.getSelectedValues(this.subcategoryFilters)
    const brands = this.getSelectedValues(this.brandFilters)
    const availableOnly = !!this.availableFilter?.checked
    const alcoholic = this.alcoholicRadios.find((input) => input.checked)?.value || "all"

    filterCardsByQuery({
      query,
      cards: this.cards,
      getText: (card) => card.dataset.text,
      emptyState: this.emptyState,
      matchesBase: (card) => {
        const matchesCategory = categories.length === 0 || categories.includes(card.dataset.category)
        const matchesSubcategory = subcategories.length === 0 || subcategories.includes(card.dataset.subcategory)
        const matchesBrand = brands.length === 0 || brands.includes(card.dataset.brand)
        const matchesAvailable = !availableOnly || card.dataset.hasAvailable === "1"

        let matchesAlcoholic = true
        if (alcoholic === "alcoholic") matchesAlcoholic = card.dataset.alcoholic === "1"
        if (alcoholic === "non_alcoholic") matchesAlcoholic = card.dataset.alcoholic === "0"

        return matchesCategory && matchesSubcategory && matchesBrand && matchesAvailable && matchesAlcoholic
      },
      afterFilter: (count) => {
        if (this.countEl) this.countEl.textContent = String(count)
      }
    })
  }

  addSelectedDrink(card) {
    const variant = this.selectedVariant(card)
    if (!variant || variant.dataset.available !== "1") return

    upsertCartItem({
      variantId: variant.dataset.variantId,
      name: variant.dataset.productName,
      brand: variant.dataset.productBrand,
      label: variant.dataset.productLabel,
      size: Number(variant.dataset.size || 0),
      price: Number(variant.dataset.price || 0),
      qty: 1
    })

    showToast("Produkt zum Warenkorb hinzugefügt")
    this.renderCart()
  }

  renderCart() {
    renderDrinksCart({
      container: this.cartItems,
      countElement: this.cartCount,
      subtotalElement: this.cartSubtotal,
      depositElement: this.cartDeposit,
      totalElement: this.cartTotal,
      cart: getCart()
    })
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
  }

  resetFilters() {
    [...this.categoryFilters, ...this.subcategoryFilters, ...this.brandFilters].forEach((input) => {
      input.checked = false
    })

    this.alcoholicRadios.forEach((radio) => {
      radio.checked = radio.value === "all"
    })

    if (this.availableFilter) this.availableFilter.checked = true
    if (this.searchInput) this.searchInput.value = ""

    this.applyFilters()
  }

  openPanel() {
    setElementVisibility(this.cartPanel, true)
    setElementVisibility(this.overlay, true)
    document.body.classList.add("overflow-hidden")
  }

  closePanel() {
    setElementVisibility(this.cartPanel, false)
    setElementVisibility(this.overlay, false)
    document.body.classList.remove("overflow-hidden")
  }
}
