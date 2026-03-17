import { Controller } from "@hotwired/stimulus"
import { clearCart, getCart, saveCart, upsertCartItem } from "controllers/shared/cart_store"
import { renderDrinksCart } from "controllers/shared/cart_dom"
import { filterCardsByQuery, formatCurrency, normalizeText, setElementVisibility, showToast } from "controllers/shared/ui_helpers"

export default class extends Controller {
  connect() {
    this.cacheElements()
    this.bindEvents()
    this.renderCart()
    this.applyFilters()
    this.handleViewport()
  }

  cacheElements() {
    this.searchInput = document.getElementById("drinks-search")
    this.filtersPanel = document.getElementById("drinks-filters-panel")
    this.toggleFiltersButton = document.getElementById("toggle-drinks-filters")
    this.resetFiltersButton = document.getElementById("reset-drinks-filters")
    this.cards = Array.from(this.element.querySelectorAll(".drink-card"))
    this.sections = Array.from(this.element.querySelectorAll("[data-drink-section]"))
    this.countEl = document.getElementById("drinks-count")
    this.emptyState = document.getElementById("drinks-no-results")

    this.featuredFilter = document.getElementById("filter-featured")
    this.availableFilter = document.getElementById("filter-available")
    this.alcoholicRadios = Array.from(document.querySelectorAll('input[name="filter-alcoholic"]'))
    this.categoryFilters = Array.from(document.querySelectorAll(".filter-category"))
    this.subcategoryFilters = Array.from(document.querySelectorAll(".filter-subcategory"))
    this.brandFilters = Array.from(document.querySelectorAll(".filter-brand"))

    this.openCartButton = document.getElementById("open-cart")
    this.closeCartButton = document.getElementById("close-cart")
    this.cartPanel = document.getElementById("cart-panel-mobile")
    this.overlay = document.getElementById("cart-overlay")
    this.cartCounts = [document.getElementById("cart-count"), document.getElementById("cart-count-desktop")].filter(Boolean)
    this.desktopCartItems = document.getElementById("cart-items")
    this.mobileCartItems = document.getElementById("cart-items-mobile")
    this.desktopSubtotal = document.getElementById("cart-subtotal")
    this.mobileSubtotal = document.getElementById("cart-subtotal-mobile")
    this.desktopDeposit = document.getElementById("cart-deposit")
    this.mobileDeposit = document.getElementById("cart-deposit-mobile")
    this.desktopTotal = document.getElementById("cart-total")
    this.mobileTotal = document.getElementById("cart-total-mobile")
    this.clearCartButtons = [document.getElementById("clear-cart"), document.getElementById("clear-cart-mobile")].filter(Boolean)
    this.confirmOverlay = document.getElementById("drinks-confirm-overlay")
    this.confirmSheet = document.getElementById("drinks-confirm-sheet")
    this.confirmCancelButton = document.getElementById("drinks-confirm-cancel")
    this.confirmClearButton = document.getElementById("drinks-confirm-clear")
  }

  bindEvents() {
    this.cards.forEach((card) => {
      Array.from(card.querySelectorAll(".drink-variant")).forEach((button) => {
        button.addEventListener("click", () => this.applyVariantStyles(card, button))
      })

      card.querySelector(".add-to-cart")?.addEventListener("click", () => this.addSelectedDrink(card))
    })

    this.desktopCartItems?.addEventListener("click", (event) => this.updateCartQuantity(event))
    this.mobileCartItems?.addEventListener("click", (event) => this.updateCartQuantity(event))

    this.toggleFiltersButton?.addEventListener("click", () => {
      setElementVisibility(this.filtersPanel, this.filtersPanel?.classList.contains("hidden"))
    })

    this.resetFiltersButton?.addEventListener("click", () => this.resetFilters())

    this.searchInput?.addEventListener("input", () => this.applyFilters())
    ;[...this.categoryFilters, ...this.subcategoryFilters, ...this.brandFilters, ...this.alcoholicRadios].forEach((input) => {
      input.addEventListener("change", () => this.applyFilters())
    })
    this.featuredFilter?.addEventListener("change", () => this.applyFilters())
    this.availableFilter?.addEventListener("change", () => this.applyFilters())

    this.openCartButton?.addEventListener("click", () => this.openPanel())
    this.closeCartButton?.addEventListener("click", () => this.closePanel())
    this.overlay?.addEventListener("click", () => this.closePanel())
    this.clearCartButtons.forEach((button) => {
      button.addEventListener("click", () => this.openClearCartSheet())
    })
    this.confirmOverlay?.addEventListener("click", () => this.closeClearCartSheet())
    this.confirmCancelButton?.addEventListener("click", () => this.closeClearCartSheet())
    this.confirmClearButton?.addEventListener("click", () => this.handleClearCart())

    this.resizeHandler = () => this.handleViewport()
    window.addEventListener("resize", this.resizeHandler)
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
    const featuredOnly = !!this.featuredFilter?.checked
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
        const matchesFeatured = !featuredOnly || card.dataset.featured === "1"
        const matchesAvailable = !availableOnly || card.dataset.hasAvailable === "1"

        let matchesAlcoholic = true
        if (alcoholic === "alcoholic") matchesAlcoholic = card.dataset.alcoholic === "1"
        if (alcoholic === "non_alcoholic") matchesAlcoholic = card.dataset.alcoholic === "0"

        return matchesCategory && matchesSubcategory && matchesBrand && matchesFeatured && matchesAvailable && matchesAlcoholic
      },
      afterFilter: (count) => {
        if (this.countEl) this.countEl.textContent = String(count)
        this.updateSectionVisibility()
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
    const cart = getCart()

    renderDrinksCart({
      container: this.desktopCartItems,
      countElement: this.cartCounts[0],
      subtotalElement: this.desktopSubtotal,
      depositElement: this.desktopDeposit,
      totalElement: this.desktopTotal,
      cart
    })

    renderDrinksCart({
      container: this.mobileCartItems,
      countElement: this.cartCounts[0],
      subtotalElement: this.mobileSubtotal,
      depositElement: this.mobileDeposit,
      totalElement: this.mobileTotal,
      cart
    })

    const itemsCount = cart.reduce((sum, item) => sum + item.qty, 0)
    this.cartCounts.forEach((element) => {
      element.textContent = String(itemsCount)
    })

    this.clearCartButtons.forEach((button) => {
      setElementVisibility(button, cart.length > 0)
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

    if (this.featuredFilter) this.featuredFilter.checked = false
    if (this.availableFilter) this.availableFilter.checked = true
    if (this.searchInput) this.searchInput.value = ""

    this.applyFilters()
  }

  updateSectionVisibility() {
    this.sections.forEach((section) => {
      const visibleCards = Array.from(section.querySelectorAll(".drink-card")).filter((card) => !card.hidden)
      setElementVisibility(section, visibleCards.length > 0)
    })
  }

  openClearCartSheet() {
    if (!getCart().length) return

    setElementVisibility(this.confirmOverlay, true)
    setElementVisibility(this.confirmSheet, true)
    document.body.classList.add("overflow-hidden")
  }

  closeClearCartSheet() {
    setElementVisibility(this.confirmOverlay, false)
    setElementVisibility(this.confirmSheet, false)
    if (this.cartPanel?.classList.contains("hidden")) {
      document.body.classList.remove("overflow-hidden")
    }
  }

  handleClearCart() {
    if (!getCart().length) return

    clearCart()
    this.closeClearCartSheet()
    this.renderCart()
    showToast("Warenkorb geleert")
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

  handleViewport() {
    if (window.innerWidth >= 1024) {
      setElementVisibility(this.overlay, false)
      document.body.classList.remove("overflow-hidden")
    }
  }

  disconnect() {
    if (this.resizeHandler) {
      window.removeEventListener("resize", this.resizeHandler)
    }
  }
}
