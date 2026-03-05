class PageMetaCatalog
  PAGE_META = {
    "pages#home" => {
      title: "Zapfe! Ausschanksysteme für Veranstaltungen und Betrieb",
      description: "Zapfe! kombiniert Eventvermietung und Selbstbedienungslösungen für den laufenden Ausschank."
    },
    "pages#calculator" => {
      title: "Preisrechner für mobile Zapfanlage | Zapfe!",
      description: "Berechne online deine unverbindliche Anfrage für mobile Zapfanlage, Fassgetränke und Event-Setup für dein Event."
    },
    "pages#drinks" => {
      title: "Fassgetränke für dein Event | Zapfe!",
      description: "Übersicht verfügbarer Fassgetränke, Fassgrößen und Preise für dein Event mit Zapfe!."
    },
    "pages#events" => {
      title: "Beispielveranstaltungen mit Zapfe! | Zapfe!",
      description: "Einblicke in bisherige Veranstaltungen und Eventformate, für die Zapfe! mobile Ausschanksysteme bereitstellt."
    },
    "pages#solutions" => {
      title: "Selbstbedienungslösungen für Ausschank und Verkauf | Zapfe!",
      description: "Standardisierte Selbstbedienungslösungen für Ausschank-, Kiosk- und Verkaufsprozesse mit Zapfe!."
    },
    "pages#contact" => {
      title: "Kontakt für Eventanfragen | Zapfe!",
      description: "Kontaktiere Zapfe! für Eventanfragen, Rückfragen zur mobilen Zapfanlage oder individuelle Angebote."
    },
    "pages#impressum" => {
      title: "Impressum | Zapfe!",
      description: "Rechtliche Angaben und Anbieterinformationen von Zapfe!."
    },
    "pages#datenschutz" => {
      title: "Datenschutzerklärung | Zapfe!",
      description: "Informationen zur Verarbeitung personenbezogener Daten bei Zapfe!."
    }
  }.freeze

  DEFAULT_META = {
    title: "Zapfe! Mobile Selbstbedienungs-Zapfanlage",
    description: "Mobile Zapfanlagen, Fassgetränke und Eventservice für Veranstaltungen jeder Größe."
  }.freeze

  def self.fetch(key)
    PAGE_META.fetch(key, DEFAULT_META)
  end
end
