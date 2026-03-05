import { formatCurrency } from "controllers/shared/ui_helpers"

const clearNode = (node) => {
  if (node) node.replaceChildren()
}

const buildButton = ({ text, dataset = {}, className = "", type = "button" }) => {
  const button = document.createElement("button")
  button.type = type
  button.className = className
  button.textContent = text

  Object.entries(dataset).forEach(([key, value]) => {
    button.dataset[key] = String(value)
  })

  return button
}

const buildQuantityControls = (index, qty) => {
  const wrapper = document.createElement("div")
  wrapper.className = "flex items-center gap-2"

  wrapper.append(
    buildButton({
      text: "-",
      dataset: { dec: index },
      className: "rounded border border-slate-300 px-2"
    })
  )

  const qtyLabel = document.createElement("span")
  qtyLabel.textContent = String(qty)
  wrapper.append(qtyLabel)

  wrapper.append(
    buildButton({
      text: "+",
      dataset: { inc: index },
      className: "rounded border border-slate-300 px-2"
    })
  )

  return wrapper
}

export const renderCalculatorCart = ({ container, hint, cart, ownDrinksSelected }) => {
  if (!container) return

  const activeHint = ownDrinksSelected
    ? "Der Getränkewarenkorb bleibt gespeichert, wird aktuell aber nicht in die Preisschätzung eingerechnet."
    : "Bereits gewählte Getränke bleiben hier gespeichert und werden in der Anfrage mitgeführt."

  if (hint) hint.textContent = activeHint

  clearNode(container)

  if (!cart.length) {
    const empty = document.createElement("p")
    empty.className = "text-sm text-slate-500"
    empty.textContent = "Noch keine Getränke ausgewählt. Du kannst Getränke hier oder auf der Seite /drinks hinzufügen."
    container.append(empty)
    return
  }

  const fragment = document.createDocumentFragment()

  cart.forEach((item, index) => {
    const card = document.createElement("div")
    card.className = "rounded-md border border-slate-200 p-3"

    const header = document.createElement("div")
    header.className = "flex items-start justify-between gap-3"

    const titleWrap = document.createElement("div")
    const title = document.createElement("p")
    title.className = "font-semibold text-[var(--color-zapfe-navy)]"
    title.textContent = item.label || `${item.brand} ${item.name}`
    const size = document.createElement("p")
    size.className = "text-xs text-slate-500"
    size.textContent = `${item.size}L`
    titleWrap.append(title, size)

    const remove = buildButton({
      text: "Entfernen",
      dataset: { remove: index },
      className: "rounded border border-slate-300 px-2 py-1 text-xs"
    })

    header.append(titleWrap, remove)

    const footer = document.createElement("div")
    footer.className = "mt-2 flex items-center justify-between"
    footer.append(buildQuantityControls(index, item.qty))

    const totalWrap = document.createElement("div")
    totalWrap.className = "text-right"

    const total = document.createElement("strong")
    total.className = ownDrinksSelected ? "text-slate-400" : ""
    total.textContent = formatCurrency(item.price * item.qty)
    totalWrap.append(total)

    if (ownDrinksSelected) {
      const paused = document.createElement("div")
      paused.className = "text-xs font-semibold text-slate-400"
      paused.textContent = "pausiert"
      totalWrap.append(paused)
    }

    footer.append(totalWrap)
    card.append(header, footer)
    fragment.append(card)
  })

  container.append(fragment)
}

export const renderDrinksCart = ({ container, countElement, subtotalElement, depositElement, totalElement, cart }) => {
  if (countElement) {
    const itemsCount = cart.reduce((sum, item) => sum + item.qty, 0)
    countElement.textContent = String(itemsCount)
  }

  if (!container) return

  clearNode(container)

  if (!cart.length) {
    const empty = document.createElement("p")
    empty.className = "text-sm text-slate-500"
    empty.textContent = "Noch keine Getränke ausgewählt."
    container.append(empty)

    if (subtotalElement) subtotalElement.textContent = formatCurrency(0)
    if (depositElement) depositElement.textContent = formatCurrency(0)
    if (totalElement) totalElement.textContent = formatCurrency(0)
    return
  }

  const fragment = document.createDocumentFragment()

  cart.forEach((item, index) => {
    const block = document.createElement("div")
    block.className = "mb-4 border-b border-slate-100 pb-3"

    const title = document.createElement("p")
    title.className = "text-lg font-semibold text-[var(--color-zapfe-navy)]"
    title.textContent = item.label || `${item.brand} ${item.name}`

    const size = document.createElement("p")
    size.className = "text-sm text-slate-500"
    size.textContent = `${item.size}L`

    const row = document.createElement("div")
    row.className = "mt-2 flex items-center justify-between"
    row.append(buildQuantityControls(index, item.qty))

    const priceWrap = document.createElement("div")
    priceWrap.className = "text-right"

    const total = document.createElement("strong")
    total.textContent = formatCurrency(item.price * item.qty)

    const removeWrap = document.createElement("div")
    removeWrap.append(
      buildButton({
        text: "Entfernen",
        dataset: { remove: index },
        className: "text-xs text-slate-500 underline"
      })
    )

    priceWrap.append(total, removeWrap)
    row.append(priceWrap)
    block.append(title, size, row)
    fragment.append(block)
  })

  container.append(fragment)

  const subtotal = cart.reduce((sum, item) => sum + item.price * item.qty, 0)
  const deposit = cart.reduce((sum, item) => sum + item.qty * 30, 0)
  const total = subtotal + deposit

  if (subtotalElement) subtotalElement.textContent = formatCurrency(subtotal)
  if (depositElement) depositElement.textContent = formatCurrency(deposit)
  if (totalElement) totalElement.textContent = formatCurrency(total)
}
