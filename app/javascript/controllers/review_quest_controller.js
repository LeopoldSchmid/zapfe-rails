import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "card", "dialog", "dialogAction", "dialogDomain", "dialogEffort", "dialogId",
    "dialogImpact", "dialogMark", "dialogPriority", "dialogSeverity", "dialogTitle",
    "empty", "progress", "progressLabel", "query", "resultCount", "xp"
  ]

  static values = { total: Number }

  connect() {
    this.storageKey = "zapfe-architecture-review-understood-v1"
    this.severity = "all"
    this.domain = "all"
    this.reviewed = new Set(this.loadProgress())
    this.syncCards()
    this.applyFilters()
  }

  filterSeverity(event) {
    this.severity = event.currentTarget.dataset.severityFilter
    this.element.querySelectorAll("[data-severity-filter]").forEach((button) => {
      button.setAttribute("aria-pressed", button === event.currentTarget ? "true" : "false")
    })
    this.applyFilters()
  }

  filterDomain(event) {
    this.domain = event.currentTarget.value
    this.applyFilters()
  }

  search() {
    this.applyFilters()
  }

  applyFilters() {
    const query = this.queryTarget.value.trim().toLowerCase()
    let visible = 0

    this.cardTargets.forEach((card) => {
      const severityMatches = this.severity === "all" || card.dataset.severity === this.severity
      const domainMatches = this.domain === "all" || card.dataset.domain === this.domain
      const queryMatches = !query || card.dataset.searchText.includes(query)
      const matches = severityMatches && domainMatches && queryMatches
      card.hidden = !matches
      if (matches) visible += 1
    })

    this.resultCountTarget.textContent = `${visible} ${visible === 1 ? "Quest-Karte" : "Quest-Karten"} sichtbar`
    this.emptyTarget.hidden = visible !== 0
  }

  open(event) {
    this.currentCard = event.currentTarget.closest("[data-ids]") || event.currentTarget
    const data = this.currentCard.dataset

    this.dialogIdTarget.textContent = data.findingId
    this.dialogTitleTarget.textContent = data.title
    this.dialogDomainTarget.textContent = data.domain
    this.dialogSeverityTarget.textContent = this.severityLabel(data.severity)
    this.dialogSeverityTarget.dataset.severity = data.severity
    this.dialogImpactTarget.textContent = data.impact
    this.dialogActionTarget.textContent = data.nextAction
    this.dialogPriorityTarget.textContent = data.priority
    this.dialogEffortTarget.textContent = data.effort
    this.syncDialogMark()
    this.dialogTarget.showModal()
  }

  close() {
    this.dialogTarget.close()
  }

  closeOnBackdrop(event) {
    if (event.target === this.dialogTarget) this.close()
  }

  markCard(event) {
    this.toggleIds(this.idsFor(event.currentTarget.closest("[data-ids]")))
  }

  markCurrent() {
    this.toggleIds(this.idsFor(this.currentCard))
    this.syncDialogMark()
  }

  toggleIds(ids) {
    const allReviewed = ids.every((id) => this.reviewed.has(id))
    ids.forEach((id) => allReviewed ? this.reviewed.delete(id) : this.reviewed.add(id))
    this.saveProgress()
    this.syncCards()
  }

  syncCards() {
    this.cardTargets.forEach((card) => {
      const reviewed = this.idsFor(card).every((id) => this.reviewed.has(id))
      const button = card.querySelector(".review-card__check")
      card.classList.toggle("is-reviewed", reviewed)
      button.setAttribute("aria-pressed", reviewed ? "true" : "false")
      button.lastChild.textContent = reviewed ? " verstanden" : " verstanden"
    })

    const knownIds = new Set(this.cardTargets.flatMap((card) => this.idsFor(card)))
    const reviewedCount = [...this.reviewed].filter((id) => knownIds.has(id)).length
    this.progressTarget.value = reviewedCount
    this.progressLabelTarget.textContent = `${reviewedCount} / ${this.totalValue}`
    this.xpTarget.textContent = `${reviewedCount * 100} XP gesammelt`
  }

  syncDialogMark() {
    if (!this.currentCard) return
    const reviewed = this.idsFor(this.currentCard).every((id) => this.reviewed.has(id))
    this.dialogMarkTarget.setAttribute("aria-pressed", reviewed ? "true" : "false")
    this.dialogMarkTarget.textContent = reviewed ? "✓ Verstanden" : "✓ Als verstanden markieren"
  }

  idsFor(element) {
    try {
      return JSON.parse(element.dataset.ids)
    } catch (_error) {
      return []
    }
  }

  loadProgress() {
    try {
      return JSON.parse(window.localStorage.getItem(this.storageKey)) || []
    } catch (_error) {
      return []
    }
  }

  saveProgress() {
    try {
      window.localStorage.setItem(this.storageKey, JSON.stringify([...this.reviewed]))
    } catch (_error) {
      // The review still works when storage is unavailable.
    }
  }

  severityLabel(severity) {
    return { critical: "Boss", high: "Hoch", medium: "Mittel", low: "Niedrig" }[severity]
  }
}
