# Produktionsreife- und Architekturreview

## Objective

Die gesamte Webanwendung von A bis Z auf Architektur, Sicherheit, Datenschutz,
deutsche rechtliche Pflichtpunkte und betriebliche Produktionsreife prüfen und
die belegten Ergebnisse in einem priorisierten Dokument festhalten. In diesem
Ziel werden keine Produktkorrekturen umgesetzt.

## Original Request

Die in den letzten Tagen stark weiterentwickelte Webapp vollständig prüfen,
insbesondere Security, DSGVO und Legalität in Deutschland, und ein Dokument mit
allen Befunden anlegen, das anschließend gemeinsam besprochen und schrittweise
umgesetzt werden kann.

## Intake Summary

- Input shape: `audit`
- Audience: Betreiber und Entwicklungsteam der Webapp
- Authority: `requested`
- Proof type: `source_backed_answer`
- Completion proof: Ein im Repository abgelegtes, evidenzbasiertes Review-Dokument deckt alle vereinbarten Prüffelder ab, priorisiert jeden Befund und benennt Grenzen sowie offene Betreiberfragen.
- Goal oracle: Ein finaler Judge/PM-Abgleich bestätigt anhand von Datei-, Test- und Quellenbelegen, dass jedes Prüffeld behandelt wurde und jeder Befund nachvollziehbar, priorisiert und handlungsfähig beschrieben ist.
- Likely misfire: Eine generische Checkliste ohne konkrete Repository-Belege, ein vorschnelles Compliance-Versprechen oder unbeauftragte Produktänderungen.
- Blind spots considered: Produktionsumgebung und organisatorische Prozesse sind möglicherweise nicht vollständig im Repository sichtbar; rechtliche Pflichten hängen unter anderem von Betreiber, Zielgruppe, Datenflüssen, Dienstleistern und tatsächlichem Deployment ab; ein technischer Review ersetzt keine anwaltliche Rechtsberatung.
- Existing plan facts: Zuerst ausschließlich prüfen und dokumentieren; Befunde danach gemeinsam besprechen; Korrekturen erst in Folgeschritten umsetzen.

## Goal Oracle

The oracle for this goal is:

`Ein final geprüfter Auditbericht enthält System- und Trust-Boundary-Übersicht, konkrete Befunde mit Belegen und Prioritäten, Security- und Datenschutzbewertung, Deutschland-spezifische Legal-Checks, Produktionsbetriebsrisiken, Testnachweise, positive Feststellungen, Einschränkungen und eine umsetzbare Folgereihenfolge.`

Der PM vergleicht alle Task-Receipts fortlaufend mit diesem Oracle. Reine
Bestandsaufnahme oder eine Checkliste ohne konkrete Nachweise genügt nicht. Das
Ziel ist erst abgeschlossen, wenn der finale Audit `full_outcome_complete: true`
festhält.

## Goal Kind

`audit`

## Current Tranche

Ein vollständiger read-only Review des aktuellen Branches `architecture-review`
mit statischen und sicheren dynamischen Prüfungen sowie aktueller Recherche in
offiziellen Primärquellen. Einziger inhaltlicher Schreibumfang ist das finale
Ergebnisdokument unter `docs/architecture-review-2026-07-16.md`.

## Non-Negotiable Constraints

- Keine Änderungen an Produktcode, Konfiguration, Schema, Abhängigkeiten oder Tests.
- Keine destruktiven Prüfungen und keine Zugriffe auf reale personenbezogene Produktionsdaten.
- Lokale, nicht destruktive Tests und Scanner dürfen ausgeführt werden.
- Bestehende uncommittete Änderungen werden respektiert und nicht überschrieben.
- Jeder konkrete Befund braucht Repository-, Test- oder Quellenbelege; Unsicherheit wird ausdrücklich markiert.
- Rechtliche Aussagen werden vorrangig mit aktuellen offiziellen deutschen oder EU-Primärquellen belegt.
- Technische Compliance-Einschätzung wird klar von verbindlicher Rechtsberatung getrennt.
- Kein Live-Board; `state.yaml` ist die einzige Board-Wahrheit.
- Korrekturen werden erst nach gemeinsamer Besprechung und gesonderter Freigabe umgesetzt.

## Stop Rule

Stop only when a final audit proves the full original outcome is complete.

Für dieses Audit bedeutet das: Nicht nach einer Teilprüfung stoppen. Alle
Prüffelder müssen entweder belegt bewertet oder mit konkreter Begründung als
nicht aus dem Repository prüfbar markiert sein. Unbekannte Betreiber- oder
Produktionsdetails werden als gezielte offene Fragen im Ergebnis dokumentiert.

## Review Fields

1. Produktzweck, Systemgrenzen, Komponenten, Datenmodell und Datenflüsse
2. Architektur, Kopplung, Verantwortlichkeiten, Wartbarkeit und Fehlerverhalten
3. Authentifizierung, Autorisierung, Sessions, Mandantentrennung und Admin-Pfade
4. Eingabevalidierung, Injection, XSS, CSRF, SSRF, Uploads, Secrets und Kryptografie
5. Abhängigkeiten, Supply Chain, Security Header und Rails-Härtung
6. Datenschutz by design/default, Rechtsgrundlagen, Datenminimierung und Zweckbindung
7. Löschung, Aufbewahrung, Betroffenenrechte, Export, Backups und Protokollierung
8. Auftragsverarbeitung, Drittanbieter, internationale Transfers, Cookies/Tracking sowie PWA/Push
9. Impressum, Datenschutzerklärung, Einwilligung und weitere Deutschland-spezifische Pflichtpunkte
10. Deployment, Konfiguration, Datenbank, Migrationen, Jobs, E-Mail, Verfügbarkeit und Recovery
11. Logging, Monitoring, Alarmierung, Incident Response und Datenschutzverletzungen
12. Performance, Skalierung, Accessibility, Browser/PWA-Verhalten und Teststrategie

## Result Document Contract

`docs/architecture-review-2026-07-16.md` enthält mindestens:

- Executive Summary und Gesamturteil ohne falsche Compliance-Garantie
- Scope, Methode, geprüfter Commit/Branch, Annahmen und Grenzen
- Systemübersicht, Datenklassen, Datenflüsse und Trust Boundaries
- positive Feststellungen und bereits solide Schutzmaßnahmen
- Findings mit stabiler ID, Kategorie, Schweregrad, Wahrscheinlichkeit,
  Auswirkung, konkretem Nachweis, Empfehlung, Verifikation und Aufwand
- separate Security-, DSGVO/Privacy-, Legal-, Operations- und Quality-Abschnitte
- offizielle Rechts- und Sicherheitsquellen nahe der zugehörigen Aussage
- offene Betreiberfragen und Punkte, die extern oder anwaltlich zu validieren sind
- priorisierte Umsetzungsreihenfolge: sofort, vor Produktion, zeitnah, später

## Canonical Board

Machine truth lives at:

`docs/goals/production-readiness-architecture-review/state.yaml`

## Run Command

```text
/goal Follow docs/goals/production-readiness-architecture-review/goal.md.
```

