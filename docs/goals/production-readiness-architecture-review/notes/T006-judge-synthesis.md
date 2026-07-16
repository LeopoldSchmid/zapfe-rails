# T006 – Evidenz-, Prioritäts- und Deduplizierungsentscheid

## Urteil

Der geprüfte Stand ist **nicht produktionsfreigabefähig**. Das ist kein Urteil
über die grundsätzliche Codequalität: Der Standard-Rails-Aufbau, viele fachliche
Services, 178 grüne Tests und mehrere vorhandene Schutzmaßnahmen sind solide.
Die Freigabe scheitert aber an drei kritischen Blockern und einer Gruppe hoher
Security-, Privacy-, Legal-, Recovery- und Gate-Risiken.

## Kritische Blocker

1. **SEC-001:** aktuelle bekannte Runtime-Schwachstellen im öffentlich
   erreichbaren Rails/Rack/Active-Storage/Trix/Puma-Pfad.
2. **OPS-001:** kein belegtes konsistentes Offsite-Backup und kein erfolgreicher
   Restore für das einzige Produktionsvolume.
3. **OPS-002:** destruktives Staging→Produktion-Skript löscht vor Prüfung/Kopie
   und enthält einen wahrscheinlich defekten Kopierbefehl.

## Hohe Release-Blocker

- Admin-RBAC, Passwort/MFA und Session-Widerruf (SEC-002–004).
- Unvollständige Art.-13-Information, Lösch-/Rechte-/Governance-Konzept,
  LocalStorage-PII sowie Drittanbieter-/Transferprüfung (PRIV-001–008).
- Fehlerhafte Steueraufschlüsselung bei gemischten Sätzen und zeitkritische
  E-Rechnung (LEG-004/006).
- Mailstatus vor Zustellerfolg, fehlende Job-Fehlerstrategie, zu schwaches
  Monitoring/Incident Readiness (OPS-003–006).
- Schema-Drift, partielle Template-Erstellung und rote Release-Gates
  (ARCH-001/002, QUAL-001/002).
- Accessibility/BFSG-Nachweis ist bei tatsächlicher BFSG-Anwendbarkeit ein hoher
  Betreiberblocker (LEG-003/A11Y-001), andernfalls ein mittleres Qualitätsrisiko.

## Deduplizierung

- `SEC-012`, `PWA-001` und der T001-Service-Worker-Hinweis werden als ein
  Finding **SEC-012/PWA-001** geführt.
- PII-Spam-Logging bleibt **SEC-009**; PRIV-010 verweist darauf.
- Push-Payload/Offboarding bleibt **PRIV-009**; Security-Note ist Übergabe, kein
  zweites Finding.
- Schema-Drift bleibt **ARCH-001**; OPS-007 verweist nur auf das Deploy-Risiko.
- Nummernvergabe/Atomizität wird unter **LEG-005/ARCH-005** gemeinsam geführt.
- Mailzustand bleibt **OPS-003**; QUAL-002 beschreibt ausschließlich die
  fehlenden Tests.
- RuboCop/System/Playwright/Security-Gates werden unter **QUAL-001** als rote
  Release-Baseline zusammengefasst; SEC-001 bleibt wegen des materiellen Risikos
  separat.

## Kalibrierung und zurückgewiesene Übertreibungen

- SQLite ist nicht pauschal ein Architekturfehler. Für einen kleinen Single-node
  Betrieb ist es vertretbar, sobald Recovery, Kapazitätsgrenzen, Monitoring und
  Wartung bewiesen sind.
- Brakemans `permit!` ist im aktuellen Pfad keine bestätigte
  Mass-Assignment-Lücke, weil die Hashwerte nicht an ein Model übergeben werden.
- Cookie-freies self-hosted Umami ist nicht automatisch rechtswidrig; die
  konkrete §25-TDDDG-/DSGVO-Einordnung ist mangels Live-Konfiguration offen.
- VSBG, BFSG, MStV und Fernabsatz sind ausdrücklich bedingt; Betreibergröße,
  redaktioneller Charakter und tatsächlicher Vertragsschluss entscheiden.
- Es wird keine DSGVO-, BFSG-, GoBD- oder sonstige Rechtskonformität garantiert.
  Der Bericht markiert anwaltlich/steuerlich zu validierende Punkte.
- Browser-Systemfehler beweisen nicht jeweils einen Produktdefekt; sie beweisen
  jedoch sicher, dass das Release-Gate und die Testspezifikation veraltet/rot
  sind.

## Freigegebene Berichtsstruktur

1. Executive Summary und Release-Entscheid
2. Scope/Methode/Beleggrenzen
3. System-, Datenfluss- und Trust-Boundary-Übersicht
4. positive Feststellungen
5. priorisierte Master-Finding-Tabelle mit Wahrscheinlichkeit, Auswirkung,
   Evidenz, Maßnahme, Verifikation und Aufwand
6. vertiefte Security-, DSGVO/Privacy-, Legal-, Betrieb- und Quality-Abschnitte
7. aktuelle Test-/Scannerresultate
8. offizielle Quellen und offene Betreiber-/Anwaltsfragen
9. Wellenplan: sofort, vor Produktion, zeitnah, später

## Vollständigkeitscheck vor Dokumenterstellung

Alle zwölf Charter-Prüffelder besitzen belegte Ergebnisse oder explizite
Grenzen. T007 darf den Bericht erstellen. T999 muss anschließend insbesondere
prüfen, dass jede Master-Finding-ID beschrieben/priorisiert ist, rechtliche
Bedingungen nicht als Tatsachen erscheinen, Produktdateien unverändert sind und
die kritischen Blocker im Executive Summary nicht relativiert werden.
