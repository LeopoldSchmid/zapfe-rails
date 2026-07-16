module ArchitectureReview
  class Catalog
    REPORT_PATH = Rails.root.join("docs/architecture-review-2026-07-16.md")
    ID_PATTERN = /(?:SEC|PRIV|LEG|OPS|ARCH|QUAL|PERF|A11Y|PWA)-\d{3}/

    DOMAIN_NAMES = {
      "SEC" => "Security",
      "PRIV" => "Datenschutz",
      "LEG" => "Deutschland & Recht",
      "OPS" => "Betrieb",
      "ARCH" => "Architektur",
      "QUAL" => "Qualität",
      "PERF" => "Performance",
      "A11Y" => "Barrierefreiheit",
      "PWA" => "PWA"
    }.freeze

    TITLES = {
      "SEC-001" => "Verwundbare Runtime-Abhängigkeiten",
      "SEC-002" => "Admin ohne Rollen und Grenzen",
      "SEC-003" => "Zu schwache Passwörter, keine MFA",
      "SEC-004" => "Alte Sessions bleiben gültig",
      "SEC-005" => "Passwort-Reset ohne Cooldown",
      "SEC-006" => "Uploads ohne zentrale Schutzpolicy",
      "SEC-007" => "Monitoring-Token in der URL",
      "SEC-008" => "CSP lässt zu viel Spielraum",
      "SEC-009" => "Personendaten landen im Spam-Log",
      "SEC-010" => "Security-Aktionen ohne Auditspur",
      "SEC-011" => "Host- und Browser-Policies fehlen",
      "SEC-012" => "Service Worker kontrolliert den ganzen Origin",
      "PRIV-001" => "Datenschutzerklärung bildet die App nicht ab",
      "PRIV-002" => "Löschen, Rechte und Breach-Prozesse fehlen",
      "PRIV-003" => "Kontakt-PII bleibt unbegrenzt im Browser",
      "PRIV-004" => "Kenntnisnahme wird als Zustimmung bezeichnet",
      "PRIV-005" => "Auftragsverarbeiter und Transfers ungeklärt",
      "PRIV-008" => "Umami ohne belegte Privacy-Konfiguration",
      "PRIV-009" => "Personendaten in Push-Nachrichten",
      "PRIV-010" => "Formulare sammeln mehr als belegt nötig",
      "LEG-001" => "Impressum teilweise veraltet und ungeprüft",
      "LEG-002" => "VSBG-Erklärung ist offen",
      "LEG-003" => "BFSG-Anwendbarkeit nicht geklärt",
      "LEG-004" => "Mischsteuersätze im PDF falsch dargestellt",
      "LEG-005" => "Rechnungsnummern und Korrekturpfad sind fragil",
      "LEG-006" => "E-Rechnungsfähigkeit fehlt",
      "LEG-007" => "Fernabsatz- und Verbraucherpflichten offen",
      "LEG-008" => "Preisangaben müssen eingeordnet werden",
      "OPS-001" => "Kein bewiesenes Backup und Restore",
      "OPS-002" => "Destruktives Produktionsskript",
      "OPS-003" => "Zu früh als versendet markiert",
      "OPS-004" => "Jobs ohne verlässlichen Fehlerpfad",
      "OPS-005" => "Monitoring und Incident Response reichen nicht",
      "OPS-007" => "Migrationen laufen beim Web-Start",
      "OPS-008" => "Ein Host ist ein gemeinsamer Ausfallpunkt",
      "OPS-010" => "Container-Lieferkette nicht abgesichert",
      "OPS-011" => "Deployment mit zu vielen Rechten",
      "OPS-012" => "Keine messbaren Betriebsziele",
      "ARCH-001" => "Schema lässt sich nicht reproduzieren",
      "ARCH-002" => "Fehler können Teilaufträge hinterlassen",
      "ARCH-003" => "Statuslogik ist über die App verteilt",
      "ARCH-004" => "Einige Komponenten tragen zu viel Verantwortung",
      "QUAL-001" => "Release-Gates sind rot",
      "QUAL-002" => "Kritische Fehlerpfade sind ungetestet",
      "QUAL-003" => "Frontend und Accessibility kaum automatisiert",
      "QUAL-004" => "Toter Code und alte Dokumentation",
      "PERF-001" => "Listen und Kalender skalieren schlecht",
      "PERF-002" => "Große Bildquellen blähen Builds auf",
      "A11Y-001" => "WCAG-/BFSG-Nachweis fehlt",
      "A11Y-002" => "Mobile Menüs sind nicht tastaturfest",
      "A11Y-003" => "Skip-Link und aktueller Navigationsstatus fehlen",
      "A11Y-004" => "Autoplay-Videos lassen sich nicht pausieren",
      "A11Y-005" => "Fehlerfeedback ist nicht screenreaderfest",
      "PWA-002" => "PWA-Updates und Fehler haben keine UX"
    }.freeze

    def findings
      @findings ||= File.readlines(REPORT_PATH, chomp: true).filter_map { |line| parse_row(line) }
    end

    def finding_count
      findings.flat_map { |finding| finding[:ids] }.uniq.size
    end

    def domains
      findings.map { |finding| finding[:domain] }.uniq.sort
    end

    private

    def parse_row(line)
      return unless line.start_with?("| **")

      cells = line.split("|").map(&:strip)
      ids = cells.fetch(1, "").scan(ID_PATTERN)
      return if ids.empty?

      priority = plain_text(cells.fetch(2, ""))
      primary_id = ids.first

      {
        id: ids.join(" / "),
        ids: ids,
        title: TITLES.fetch(primary_id),
        domain: DOMAIN_NAMES.fetch(primary_id.split("-").first),
        severity: severity_for(priority),
        priority: priority,
        impact: plain_text(cells.fetch(3, "")),
        action: plain_text(cells.fetch(4, "")),
        effort: plain_text(cells.fetch(5, ""))
      }
    end

    def severity_for(priority)
      normalized = priority.downcase
      return "critical" if normalized.match?(/\bkritisch\b/)
      return "high" if normalized.include?("hoch")
      return "medium" if normalized.include?("mittel")

      "low"
    end

    def plain_text(value)
      value
        .gsub(/\[([^\]]+)\]\([^)]+\)/, '\\1')
        .delete("`*")
        .strip
    end
  end
end
