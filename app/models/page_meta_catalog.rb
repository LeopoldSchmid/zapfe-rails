class PageMetaCatalog
  PAGE_META = {
    "pages#home" => {
      title: "Mobile Zapfanlagen zur Selbstbedienung | Zapfe!",
      description: "Zapfe! verbindet mobile Event-Setups und Self-Service-Lösungen für laufenden Ausschank. Wähle den passenden Einstieg für dein Vorhaben."
    },
    "pages#calculator" => {
      title: "Preisrechner für Selbstbedienungs-Zapfanlagen | Zapfe!",
      description: "Berechne online deine unverbindliche Anfrage für mobile Zapfanlage, Fassgetränke und Event-Setup für dein Event."
    },
    "pages#drinks" => {
      title: "Fassgetränke für dein Event | Zapfe!",
      description: "Übersicht verfügbarer Fassgetränke, Fassgrößen und Preise für dein Event mit Zapfe!."
    },
    "pages#events" => {
      title: "Zapfanlage für Events mit Selbstbedienung | Zapfe!",
      description: "Mobile Zapfe!-Setups für Hochzeiten, Firmenfeiern und Veranstaltungen mit minimaler Betreuung und klarer Anfrageführung."
    },
    "pages#solutions" => {
      title: "Selbstbedienungs-Zapfanlagen für den dauerhaften Betrieb | Zapfe!",
      description: "Zapfe! Lösungen für laufenden Ausschank: standardisierte Self-Service-Systeme für Standorte, Kioske und Verkaufsflächen."
    },
    "pages#cta_preview" => {
      title: "CTA Vorschau fuer die Startseite | Zapfe!",
      description: "Vergleich verschiedener CTA-Varianten fuer den Einstiegsbereich der Zapfe!-Startseite."
    },
    "pages#contact" => {
      title: "Kontakt für Eventanfragen und Ausschanklösungen | Zapfe!",
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
    title: "Mobile Zapfanlagen zur Selbstbedienung | Zapfe!",
    description: "Mobile Zapfanlagen, Fassgetränke und Eventservice für Veranstaltungen jeder Größe."
  }.freeze

  def self.fetch(key)
    PAGE_META.fetch(key, DEFAULT_META)
  end
end
