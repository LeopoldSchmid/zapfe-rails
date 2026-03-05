export const formatCurrency = (value) => new Intl.NumberFormat("de-DE", {
  style: "currency",
  currency: "EUR"
}).format(value)

export const normalizeText = (value) => (value || "")
  .toString()
  .toLowerCase()
  .normalize("NFD")
  .replace(/[\u0300-\u036f]/g, "")
  .trim()

export const formatDateDE = (isoDate) => {
  if (!isoDate) return "-"

  const date = new Date(`${isoDate}T00:00:00`)
  if (Number.isNaN(date.getTime())) return isoDate

  return new Intl.DateTimeFormat("de-DE").format(date)
}

export const setElementVisibility = (element, visible) => {
  if (!element) return

  element.hidden = !visible
  element.classList.toggle("hidden", !visible)
}

export const filterCardsByQuery = ({ query, cards, getText, emptyState, afterFilter, matchesBase = () => true }) => {
  let visibleCount = 0

  cards.forEach((card) => {
    const visible = matchesBase(card) && (!query || normalizeText(getText(card)).includes(query))
    setElementVisibility(card, visible)
    if (visible) visibleCount += 1
  })

  setElementVisibility(emptyState, visibleCount === 0)
  afterFilter?.(visibleCount)
  return visibleCount
}

export const showToast = (message) => {
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
