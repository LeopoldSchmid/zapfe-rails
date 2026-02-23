import "@hotwired/turbo-rails"
import "controllers"

const CART_KEY = "zapfe_cart_v1"

const formatCurrency = (value) => new Intl.NumberFormat("de-DE", {
  style: "currency",
  currency: "EUR"
}).format(value)

const formatDateDE = (isoDate) => {
  if (!isoDate) return "-"
  const date = new Date(`${isoDate}T00:00:00`)
  if (Number.isNaN(date.getTime())) return isoDate
  return new Intl.DateTimeFormat("de-DE").format(date)
}

const showToast = (message) => {
  const toast = document.createElement("div")
  toast.className = "fixed right-4 top-20 z-[90] rounded-md bg-[var(--color-zapfe-navy)] px-4 py-2 text-sm font-medium text-white shadow-lg"
  toast.textContent = message
  toast.style.opacity = "0"
  toast.style.transform = "translateY(-4px)"
  document.body.appendChild(toast)
  requestAnimationFrame(() => {
    toast.style.transition = "opacity 220ms ease, transform 220ms ease"
    toast.style.opacity = "1"
    toast.style.transform = "translateY(0)"
  })

  setTimeout(() => {
    toast.style.opacity = "0"
    toast.style.transform = "translateY(-4px)"
    setTimeout(() => toast.remove(), 240)
  }, 1200)
}

const getCart = () => {
  try {
    return JSON.parse(window.localStorage.getItem(CART_KEY) || "[]")
  } catch (_error) {
    return []
  }
}

const saveCart = (cart) => {
  window.localStorage.setItem(CART_KEY, JSON.stringify(cart))
}

const upsertCartItem = (item) => {
  const cart = getCart()
  const existing = cart.find((entry) => entry.variantId === item.variantId)
  if (existing) {
    existing.qty += item.qty || 1
  } else {
    cart.push({ ...item, qty: item.qty || 1 })
  }
  saveCart(cart)
  return cart
}

const bindTransitions = () => {
  if (window.__zapfeTransitionsBound) return
  window.__zapfeTransitionsBound = true

  document.addEventListener("turbo:before-render", (event) => {
    const current = document.getElementById("page-content")
    const next = event.detail.newBody?.querySelector("#page-content")
    if (!current || !next) return

    event.preventDefault()
    current.classList.add("page-leave-active")

    setTimeout(() => {
      event.detail.resume()
      requestAnimationFrame(() => {
        const entered = document.getElementById("page-content")
        if (!entered) return
        entered.classList.add("page-enter-active")
        setTimeout(() => entered.classList.remove("page-enter-active"), 260)
      })
    }, 140)
  })
}

const initCalculatorPage = () => {
  const root = document.querySelector('[data-page="calculator"]')
  if (!root || root.dataset.bound === "1") return
  root.dataset.bound = "1"

  const form = document.getElementById("calculator-form")
  if (!form) return

  const selectedOptionsInput = document.getElementById("selected-options")
  const totalPriceInput = document.getElementById("total-price-input")
  const pricingSnapshotInput = document.getElementById("pricing-snapshot")
  const eventDateHidden = document.getElementById("event-date-hidden")
  const totalPriceEl = document.getElementById("total-price")
  const rentalSummaryEl = document.getElementById("rental-summary")

  const startDate = document.getElementById("rental-start-date")
  const endDate = document.getElementById("rental-end-date")
  const startHour = document.getElementById("start-hour")
  const startMinute = document.getElementById("start-minute")
  const endHour = document.getElementById("end-hour")
  const endMinute = document.getElementById("end-minute")

  const glassesRental = document.getElementById("glasses-rental")
  const deliveryEnabled = document.getElementById("delivery-enabled")
  const deliveryFields = document.getElementById("delivery-fields")
  const deliveryStreet = document.getElementById("delivery-street")
  const deliveryPostcode = document.getElementById("delivery-postcode")
  const deliveryCity = document.getElementById("delivery-city")

  const searchInput = document.getElementById("calc-drinks-search")
  const drinkCards = Array.from(document.querySelectorAll(".calc-drink-card"))
  const drinksTrack = document.getElementById("calc-drinks-track")
  const scrollLeftBtn = document.getElementById("calc-scroll-left")
  const scrollRightBtn = document.getElementById("calc-scroll-right")
  const cartItemsEl = document.getElementById("calc-cart-items")

  const today = new Date()
  const tomorrow = new Date(today)
  tomorrow.setDate(today.getDate() + 1)
  const toISO = (date) => date.toISOString().slice(0, 10)

  if (startDate && !startDate.value) startDate.value = toISO(today)
  if (endDate && !endDate.value) endDate.value = toISO(tomorrow)
  if (startHour && !startHour.value) startHour.value = "18"
  if (startMinute && !startMinute.value) startMinute.value = "00"

  const dayCount = () => {
    if (!startDate?.value || !endDate?.value) return 1
    const from = new Date(startDate.value)
    const to = new Date(endDate.value)
    const diff = Math.ceil((to - from) / (1000 * 60 * 60 * 24))
    return Math.max(1, diff)
  }

  const getSelectedVariant = (card) => card.querySelector('.calc-variant[data-selected="1"]') || card.querySelector(".calc-variant")

  const applyVariantStyles = (card, selectedButton) => {
    card.querySelectorAll(".calc-variant").forEach((btn) => {
      btn.dataset.selected = "0"
      btn.classList.remove("border-[var(--color-zapfe-amber)]", "bg-[var(--color-zapfe-amber)]/20")
      btn.classList.add("border-slate-300")
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

  const renderCalcCart = () => {
    const cart = getCart()

    if (!cartItemsEl) return

    if (!cart.length) {
      cartItemsEl.innerHTML = '<p class="text-sm text-slate-500">Noch keine Getränke ausgewählt. Du kannst Getränke hier oder auf der Seite /drinks hinzufügen.</p>'
      return
    }

    cartItemsEl.innerHTML = cart.map((item, index) => `
      <div class="rounded-md border border-slate-200 p-3">
        <div class="flex items-start justify-between gap-3">
          <div>
            <p class="font-semibold text-[var(--color-zapfe-navy)]">${item.brand} ${item.name}</p>
            <p class="text-xs text-slate-500">${item.size}L</p>
          </div>
          <button type="button" data-remove="${index}" class="rounded border border-slate-300 px-2 py-1 text-xs">Entfernen</button>
        </div>
        <div class="mt-2 flex items-center justify-between">
          <div class="flex items-center gap-2">
            <button type="button" data-dec="${index}" class="rounded border border-slate-300 px-2">-</button>
            <span>${item.qty}</span>
            <button type="button" data-inc="${index}" class="rounded border border-slate-300 px-2">+</button>
          </div>
          <strong>${formatCurrency(item.price * item.qty)}</strong>
        </div>
      </div>
    `).join("")
  }

  const calculate = () => {
    const rentalInput = form.querySelector('input[name="rental_option"]:checked')
    const rentalBase = Number(rentalInput?.dataset.base || 0)
    const rentalLabel = rentalInput?.value === "self" ? "Zapf & Pay" : "Zapf"
    const days = dayCount()
    const rentalTotal = rentalBase * days

    const cart = getCart()
    const drinksTotal = cart.reduce((sum, item) => sum + item.price * item.qty, 0)
    const glassesTotal = glassesRental?.checked ? 70 : 0

    const total = rentalTotal + drinksTotal + glassesTotal

    if (rentalSummaryEl) rentalSummaryEl.textContent = `Grundmiete (${rentalLabel}) für ${days} Tag(e): ${formatCurrency(rentalTotal)}`

    if (totalPriceEl) totalPriceEl.textContent = formatCurrency(total)
    if (totalPriceInput) totalPriceInput.value = total.toFixed(2)

    if (eventDateHidden) eventDateHidden.value = startDate?.value || ""

    const options = []
    options.push(`Option: ${rentalLabel} (${formatCurrency(rentalBase)} pro Tag)`)
    options.push(`Mietdauer: ${days} Tag(e)`)

    if (startDate?.value || endDate?.value) {
      options.push(`Datum: ${formatDateDE(startDate?.value)} bis ${formatDateDE(endDate?.value)}`)
    }

    if (startHour?.value || endHour?.value) {
      options.push(`Uhrzeit: ${startHour?.value || "HH"}:${startMinute?.value || "00"} bis ${endHour?.value || "HH"}:${endMinute?.value || "00"}`)
    }

    if (glassesRental?.checked) options.push("Zusatzoption: Gläser mieten (70€)")

    if (deliveryEnabled?.checked) {
      options.push("Lieferung: Ja")
      const address = [deliveryStreet?.value, deliveryPostcode?.value, deliveryCity?.value].filter(Boolean).join(", ")
      if (address) options.push(`Lieferadresse: ${address}`)
    } else {
      options.push("Lieferung: Nein")
    }

    cart.forEach((item) => {
      options.push(`Getränk: ${item.brand} ${item.name} ${item.size}L x ${item.qty} = ${formatCurrency(item.price * item.qty)}`)
    })

    if (selectedOptionsInput) selectedOptionsInput.value = options.join("\n")

    if (pricingSnapshotInput) {
      pricingSnapshotInput.value = JSON.stringify({
        rentalOption: rentalInput?.value,
        rentalBase,
        days,
        rentalTotal,
        drinksTotal,
        glassesRental: !!glassesRental?.checked,
        delivery: !!deliveryEnabled?.checked,
        deliveryAddress: {
          street: deliveryStreet?.value || "",
          postcode: deliveryPostcode?.value || "",
          city: deliveryCity?.value || ""
        },
        cart,
        total
      })
    }
  }

  const refreshScrollButtons = () => {
    if (!drinksTrack || !scrollLeftBtn || !scrollRightBtn) return
    const canLeft = drinksTrack.scrollLeft > 4
    const canRight = drinksTrack.scrollLeft < drinksTrack.scrollWidth - drinksTrack.clientWidth - 4
    scrollLeftBtn.classList.toggle("hidden", !canLeft)
    scrollRightBtn.classList.toggle("hidden", !canRight)
  }

  drinkCards.forEach((card) => {
    const variants = Array.from(card.querySelectorAll(".calc-variant"))
    const addButton = card.querySelector(".calc-add-drink")

    variants.forEach((button) => {
      button.addEventListener("click", () => {
        applyVariantStyles(card, button)
      })
    })

    addButton?.addEventListener("click", () => {
      const selected = getSelectedVariant(card)
      if (!selected || selected.dataset.available !== "1") return

      upsertCartItem({
        variantId: selected.dataset.variantId,
        name: selected.dataset.productName,
        brand: selected.dataset.productBrand,
        size: Number(selected.dataset.size || 0),
        price: Number(selected.dataset.price || 0),
        qty: 1
      })

      showToast("Produkt zum Warenkorb hinzugefügt")
      renderCalcCart()
      calculate()
    })
  })

  searchInput?.addEventListener("input", () => {
    const query = searchInput.value.toLowerCase().trim()
    drinkCards.forEach((card) => {
      const label = card.dataset.label?.toLowerCase() || ""
      card.style.display = label.includes(query) ? "block" : "none"
    })
    refreshScrollButtons()
  })

  scrollLeftBtn?.addEventListener("click", () => {
    if (!drinksTrack) return
    drinksTrack.scrollBy({ left: -Math.max(200, drinksTrack.clientWidth * 0.7), behavior: "smooth" })
  })

  scrollRightBtn?.addEventListener("click", () => {
    if (!drinksTrack) return
    drinksTrack.scrollBy({ left: Math.max(200, drinksTrack.clientWidth * 0.7), behavior: "smooth" })
  })

  drinksTrack?.addEventListener("scroll", refreshScrollButtons)
  window.addEventListener("resize", refreshScrollButtons)

  cartItemsEl?.addEventListener("click", (event) => {
    const button = event.target.closest("button")
    if (!button) return

    const cart = getCart()
    const idx = Number(button.dataset.inc || button.dataset.dec || button.dataset.remove)
    if (Number.isNaN(idx) || !cart[idx]) return

    if (button.dataset.inc) cart[idx].qty += 1
    if (button.dataset.dec) {
      cart[idx].qty -= 1
      if (cart[idx].qty <= 0) cart.splice(idx, 1)
    }
    if (button.dataset.remove) cart.splice(idx, 1)

    saveCart(cart)
    renderCalcCart()
    calculate()
  })

  const toggleDeliveryFields = () => {
    if (!deliveryFields || !deliveryEnabled) return
    deliveryFields.classList.toggle("hidden", !deliveryEnabled.checked)
  }

  form.addEventListener("change", calculate)
  form.addEventListener("input", calculate)

  deliveryEnabled?.addEventListener("change", () => {
    toggleDeliveryFields()
    calculate()
  })

  toggleDeliveryFields()
  renderCalcCart()
  calculate()
  refreshScrollButtons()
}

const initDrinksPage = () => {
  const root = document.querySelector('[data-page="drinks"]')
  if (!root || root.dataset.bound === "1") return
  root.dataset.bound = "1"

  const searchInput = document.getElementById("drinks-search")
  const filtersPanel = document.getElementById("drinks-filters-panel")
  const toggleFiltersButton = document.getElementById("toggle-drinks-filters")
  const resetFiltersButton = document.getElementById("reset-drinks-filters")
  const cards = Array.from(document.querySelectorAll(".drink-card"))
  const countEl = document.getElementById("drinks-count")

  const availableFilter = document.getElementById("filter-available")
  const alcoholicRadios = Array.from(document.querySelectorAll('input[name="filter-alcoholic"]'))
  const categoryFilters = Array.from(document.querySelectorAll(".filter-category"))
  const subcategoryFilters = Array.from(document.querySelectorAll(".filter-subcategory"))
  const brandFilters = Array.from(document.querySelectorAll(".filter-brand"))

  const openCart = document.getElementById("open-cart")
  const closeCart = document.getElementById("close-cart")
  const cartPanel = document.getElementById("cart-panel")
  const overlay = document.getElementById("cart-overlay")
  const cartCount = document.getElementById("cart-count")
  const cartItems = document.getElementById("cart-items")
  const cartSubtotal = document.getElementById("cart-subtotal")
  const cartDeposit = document.getElementById("cart-deposit")
  const cartTotal = document.getElementById("cart-total")

  const getSelectedValues = (inputs) => inputs.filter((i) => i.checked).map((i) => i.value)

  const applyVariantStyles = (card, selectedButton) => {
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

  const selectedVariant = (card) => card.querySelector('.drink-variant[data-selected="1"]') || card.querySelector(".drink-variant")

  const applyFilters = () => {
    const query = searchInput?.value.toLowerCase().trim() || ""
    const categories = getSelectedValues(categoryFilters)
    const subcategories = getSelectedValues(subcategoryFilters)
    const brands = getSelectedValues(brandFilters)
    const availableOnly = !!availableFilter?.checked
    const alcoholic = alcoholicRadios.find((input) => input.checked)?.value || "all"

    let visibleCount = 0

    cards.forEach((card) => {
      const matchesSearch = !query || (card.dataset.text || "").includes(query)
      const matchesCategory = categories.length === 0 || categories.includes(card.dataset.category)
      const matchesSubcategory = subcategories.length === 0 || subcategories.includes(card.dataset.subcategory)
      const matchesBrand = brands.length === 0 || brands.includes(card.dataset.brand)
      const matchesAvailable = !availableOnly || card.dataset.hasAvailable === "1"

      let matchesAlcoholic = true
      if (alcoholic === "alcoholic") matchesAlcoholic = card.dataset.alcoholic === "1"
      if (alcoholic === "non_alcoholic") matchesAlcoholic = card.dataset.alcoholic === "0"

      const visible = matchesSearch && matchesCategory && matchesSubcategory && matchesBrand && matchesAvailable && matchesAlcoholic
      card.classList.toggle("hidden", !visible)
      if (visible) visibleCount += 1
    })

    if (countEl) countEl.textContent = String(visibleCount)
  }

  const openPanel = () => {
    cartPanel?.classList.remove("hidden")
    overlay?.classList.remove("hidden")
    document.body.classList.add("overflow-hidden")
  }

  const closePanel = () => {
    cartPanel?.classList.add("hidden")
    overlay?.classList.add("hidden")
    document.body.classList.remove("overflow-hidden")
  }

  const renderCart = () => {
    const cart = getCart()
    const itemsCount = cart.reduce((sum, item) => sum + item.qty, 0)
    if (cartCount) cartCount.textContent = String(itemsCount)

    if (!cartItems) return
    if (!cart.length) {
      cartItems.innerHTML = '<p class="text-sm text-slate-500">Noch keine Getränke ausgewählt.</p>'
      if (cartSubtotal) cartSubtotal.textContent = formatCurrency(0)
      if (cartDeposit) cartDeposit.textContent = formatCurrency(0)
      if (cartTotal) cartTotal.textContent = formatCurrency(0)
      return
    }

    cartItems.innerHTML = cart.map((item, idx) => `
      <div class="mb-4 border-b border-slate-100 pb-3">
        <p class="text-lg font-semibold text-[var(--color-zapfe-navy)]">${item.brand} ${item.name}</p>
        <p class="text-sm text-slate-500">${item.size}L</p>
        <div class="mt-2 flex items-center justify-between">
          <div class="flex items-center gap-2">
            <button data-dec="${idx}" class="rounded border border-slate-300 px-2">-</button>
            <span>${item.qty}</span>
            <button data-inc="${idx}" class="rounded border border-slate-300 px-2">+</button>
          </div>
          <div class="text-right">
            <strong>${formatCurrency(item.price * item.qty)}</strong>
            <div><button data-remove="${idx}" class="text-xs text-slate-500 underline">Entfernen</button></div>
          </div>
        </div>
      </div>
    `).join("")

    const subtotal = cart.reduce((sum, item) => sum + item.price * item.qty, 0)
    const deposit = cart.reduce((sum, item) => sum + item.qty * 30, 0)
    const total = subtotal + deposit

    if (cartSubtotal) cartSubtotal.textContent = formatCurrency(subtotal)
    if (cartDeposit) cartDeposit.textContent = formatCurrency(deposit)
    if (cartTotal) cartTotal.textContent = formatCurrency(total)
  }

  cards.forEach((card) => {
    const variants = Array.from(card.querySelectorAll(".drink-variant"))
    const addButton = card.querySelector(".add-to-cart")

    variants.forEach((button) => {
      button.addEventListener("click", () => {
        applyVariantStyles(card, button)
      })
    })

    addButton?.addEventListener("click", () => {
      const variant = selectedVariant(card)
      if (!variant || variant.dataset.available !== "1") return

      upsertCartItem({
        variantId: variant.dataset.variantId,
        name: variant.dataset.productName,
        brand: variant.dataset.productBrand,
        size: Number(variant.dataset.size || 0),
        price: Number(variant.dataset.price || 0),
        qty: 1
      })

      showToast("Produkt zum Warenkorb hinzugefügt")
      renderCart()
    })
  })

  cartItems?.addEventListener("click", (event) => {
    const button = event.target.closest("button")
    if (!button) return

    const cart = getCart()
    const idx = Number(button.dataset.inc || button.dataset.dec || button.dataset.remove)
    if (Number.isNaN(idx) || !cart[idx]) return

    if (button.dataset.inc) cart[idx].qty += 1
    if (button.dataset.dec) {
      cart[idx].qty -= 1
      if (cart[idx].qty <= 0) cart.splice(idx, 1)
    }
    if (button.dataset.remove) cart.splice(idx, 1)

    saveCart(cart)
    renderCart()
  })

  toggleFiltersButton?.addEventListener("click", () => {
    filtersPanel?.classList.toggle("hidden")
  })

  resetFiltersButton?.addEventListener("click", () => {
    ;[...categoryFilters, ...subcategoryFilters, ...brandFilters].forEach((input) => {
      input.checked = false
    })

    alcoholicRadios.forEach((radio) => {
      radio.checked = radio.value === "all"
    })

    if (availableFilter) availableFilter.checked = true
    if (searchInput) searchInput.value = ""
    applyFilters()
  })

  searchInput?.addEventListener("input", applyFilters)
  ;[...categoryFilters, ...subcategoryFilters, ...brandFilters, ...alcoholicRadios].forEach((input) => {
    input.addEventListener("change", applyFilters)
  })
  availableFilter?.addEventListener("change", applyFilters)

  openCart?.addEventListener("click", openPanel)
  closeCart?.addEventListener("click", closePanel)
  overlay?.addEventListener("click", closePanel)

  renderCart()
  applyFilters()
}

const initializePage = () => {
  bindTransitions()
  initCalculatorPage()
  initDrinksPage()
}

document.addEventListener("turbo:load", initializePage)
