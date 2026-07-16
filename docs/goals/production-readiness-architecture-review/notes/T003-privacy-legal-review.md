# T003 – DSGVO, Privacy und deutsche Betreiberpflichten

Stand: 2026-07-16. Diese technische Compliance-Einschätzung ist keine
Rechtsberatung. Aussagen zum tatsächlichen Betrieb sind als offen markiert, wenn
sie nicht aus dem Repository verifizierbar sind.

## Geprüfte Implementierung

- Datenschutzerklärung und Impressum:
  `app/views/pages/datenschutz.html.erb`, `app/views/pages/impressum.html.erb`
- Anfrage und Rechner: `app/views/inquiries/_inquiry_form.html.erb`,
  `app/controllers/inquiries_controller.rb`, `app/models/inquiry.rb`,
  `app/javascript/controllers/calculator_controller.js`,
  `app/javascript/lib/cart_store.js`
- Tracking und Betrieb: `app/views/layouts/application.html.erb`,
  `config/deploy.yml`, `config/environments/production.rb`
- Push: `app/models/push_subscription.rb`,
  `app/services/push_notifications/send_notification.rb`, zugehörige Controller
- Datenhaltung: Modelle, Schema, Active Storage und vorhandene Jobs
- Dokumente/Rechnungen: `app/services/invoices/finalize.rb`,
  `app/services/invoices/pdf_renderer.rb`, `app/models/invoice.rb`

## Maßgebliche aktuelle Primärquellen

- DSGVO, insbesondere Art. 5, 13, 25, 28, 30, 32 und 35:
  https://eur-lex.europa.eu/eli/reg/2016/679/oj/?locale=de
- TDDDG § 25: https://www.gesetze-im-internet.de/ttdsg/__25.html
- DDG § 5: https://www.gesetze-im-internet.de/ddg/__5.html
- VSBG § 36: https://www.gesetze-im-internet.de/vsbg/__36.html
- MStV § 18: https://www.gesetze-bayern.de/Content/Document/MStV-18
- BFSG §§ 2, 3: https://www.gesetze-im-internet.de/bfsg/__2.html und
  https://www.gesetze-im-internet.de/bfsg/__3.html
- UStG § 14: https://www.gesetze-im-internet.de/ustg_1980/__14.html
- AO § 147 und HGB § 257:
  https://www.gesetze-im-internet.de/ao_1977/__147.html und
  https://www.gesetze-im-internet.de/hgb/__257.html
- BMF FAQ zur E-Rechnung:
  https://www.bundesfinanzministerium.de/Content/DE/FAQ/e-rechnung.html
- EU-Verordnung 2024/3228 zur Abschaltung der OS-Plattform:
  https://eur-lex.europa.eu/eli/reg/2024/3228/oj/?locale=de

## Bestätigte Privacy-/DSGVO-Befunde

### PRIV-001 – Datenschutzerklärung bildet reale Verarbeitung nicht vollständig ab (hoch)

Die Seite nennt das Anfrageformular, lokalen Speicher und Umami, beschreibt aber
nicht oder nicht hinreichend konkret Hosting-/Request-Logs, Resend/SMTP,
interne CRM-, Angebots-, Auftrags-, Rechnungs- und Dokumentverarbeitung,
Active-Storage-Anlagen, Push, Admin-/Beschäftigtendaten, Empfängerkategorien,
Drittlandtransfers, konkrete Speicherfristen beziehungsweise Kriterien sowie die
Pflicht/Notwendigkeit der Bereitstellung. Art. 13 verlangt diese Informationen
bei Erhebung. Die Datenschutzerklärung ist damit gegenüber den implementierten
Datenflüssen materiell unvollständig.

Empfehlung: Verarbeitungstätigkeiten und Dienstleister zuerst inventarisieren,
dann eine versionierte, verständliche Art.-13-Information pro Zielgruppe
erstellen. Juristisch final prüfen lassen.

### PRIV-002 – Kein Lösch- und Aufbewahrungskonzept, Archiv ist keine Löschung (hoch)

Es gibt keine Retention-Matrix und keine automatisierte Löschung oder
Anonymisierung für Anfragen, Kunden, Kontakte, Aufträge, Angebote, Rechnungen,
Anhänge, Aktivitäten, Hilfegesuche, Push-Abos, Logs oder Backups. Fachliche
Archivierung ändert lediglich Status/Sichtbarkeit. Das kollidiert mit
Speicherbegrenzung und Rechenschaftspflicht (Art. 5 DSGVO). Gleichzeitig dürfen
steuer- und handelsrechtlich relevante Unterlagen nicht pauschal gelöscht
werden: Buchungsbelege sind nach AO § 147/HGB § 257 grundsätzlich acht Jahre,
Geschäftsbriefe grundsätzlich sechs Jahre aufzubewahren; Fristbeginn und
Sonderfälle sind fachlich zu bestimmen.

Empfehlung: Datenklassenbezogene Matrix mit Zweck, Rechtsgrundlage, Trigger,
Frist, Sperre, Löschung/Anonymisierung und Backup-Nachlauf; technisch idempotente
Purge-Jobs und Legal-Hold-Verfahren.

### PRIV-003 – Kontakt-PII verbleibt unbegrenzt im LocalStorage (hoch)

`calculator_controller.js` speichert beim Submit sämtliche benannten
Formularfelder in `zapfe_calculator_form_v1`, darunter Name, Telefon, E-Mail,
Veranstaltungsdaten, Nachricht, Checkbox und Zeitstempel. Es existieren weder
TTL noch `removeItem` noch ein sichtbarer Löschweg. Die aktuelle Erklärung
spricht nur allgemein von ausgewählten Rechnerangaben. Nach abgeschlossener
Übermittlung ist die dauerhafte Speicherung für den ausdrücklich verlangten
Dienst nicht offensichtlich unbedingt erforderlich. Damit sind
Datenminimierung/Speicherbegrenzung und die Ausnahme des § 25 Abs. 2 TDDDG nicht
belegt.

Empfehlung: Kontakt-PII nicht persistent speichern; spätestens nach Erfolg
löschen oder nur kurzlebigen Session-Speicher mit transparenter Kontrolle
nutzen. Notwendigkeit/Einwilligung getrennt für Warenkorb und Rechner bewerten.

### PRIV-004 – Datenschutzhinweis wird fälschlich als Einwilligung behandelt (mittel-hoch)

Die Pflichtcheckbox erklärt Zustimmung zur Datenschutzerklärung und das Modell
validiert/speichert `privacy_accepted`, während die Seite Art. 6 Abs. 1 lit. b
DSGVO als Rechtsgrundlage nennt. Eine Information wird nicht durch Zustimmung
zur Rechtsgrundlage; diese Kopplung erzeugt irreführende Einwilligungsoptik. Der
gespeicherte Boolean enthält zudem keine Notice-Version und ist unbegrenzt.

Empfehlung: Bei Vertragsanbahnung neutrale Kenntnisnahme statt Einwilligung;
echte optionale Einwilligungen separat, spezifisch, widerrufbar und versioniert.

### PRIV-005 – Auftragsverarbeiter und Drittlandtransfers sind nicht operationalisiert (hoch)

Das Repository belegt Hetzner, Resend, IONOS/Gmail-Kontext, Web-Push-Anbieter,
Umami sowie Monitoring/Telegram, aber weder Verzeichnis, AVV-Status,
Subprozessorprüfung, Transfer Impact Assessment noch Löschfristen. Besonders
relevant: Resends aktuelles DPA nennt Plus Five Five, Inc. als US-Anbieter,
US-Hauptverarbeitung, SCC und Subprozessoren; auch bei Versandregion Irland
bleiben Accountdaten, Metadaten, Logs und API-Datensätze laut Resend in den USA.
Die aktuelle Datenschutzerklärung nennt Resend/Transfer nicht.

Quellen: https://resend.com/legal/dpa,
https://resend.com/docs/dashboard/domains/regions,
https://docs.hetzner.com/general/company-and-policy/data-protection-at-hetzner/

Empfehlung: AVV/DPA und tatsächliche Konfiguration aller Anbieter belegen,
Transfers/Rechtsgrundlagen/TIA dokumentieren, Tracking im Mailversand
deaktivieren oder gesondert bewerten, Notice aktualisieren.

### PRIV-006 – Betroffenenrechte sind textlich genannt, operativ aber nicht belegt (hoch)

Kein Export-, Berichtigungs-, Sperr-, Lösch- oder Identitätsprüfungsworkflow ist
vorhanden. Verknüpfte Snapshots, PDFs, Anhänge, Activities und Backups machen
rein manuelle Ad-hoc-Löschung fehleranfällig.

Empfehlung: SOP mit Identitätsprüfung, Frist/Ownership, Such- und Exportumfang,
Ausnahmen, Sperrung, Löschprotokoll und Backup-Behandlung; wiederholbarer
Integrationstest mit synthetischer Person.

### PRIV-007 – Datenschutz-Governance ist nicht nachweisbar (hoch, organisatorisch offen)

Im Repository fehlen Nachweise für Verzeichnis der Verarbeitungstätigkeiten
(Art. 30), TOM-Dokument, Incident-/72-Stunden-Breach-Prozess, DPIA-Screening,
Datenklassifikation, AVV-Register und regelmäßige Kontrollen. Ob diese außerhalb
des Repositories existieren, ist offen. Art. 32 verlangt unter anderem
Wiederherstellbarkeit und regelmäßige Wirksamkeitsprüfung; die Security- und
Backup-Befunde erhöhen hier das Risiko.

### PRIV-008 – Umami-Compliance ist ohne reale Konfiguration nicht belegt (mittel-hoch)

Der öffentliche Layout-Code lädt Umami in Produktion ohne Consent-Layer. Umami
bewirbt zwar Cookie-Freiheit und anonymisierte Daten, aber „cookie-free“ beweist
weder die konkrete Self-hosted-Konfiguration noch automatisch die Ausnahme des
§ 25 Abs. 2 TDDDG oder Art.-6-Rechtsgrundlage, Löschfrist und Zugriffskreis.
Cookie-/Terminalzugriff und anschließende Verarbeitung sind getrennt zu prüfen.

Empfehlung: Live-Netzwerkverkehr und Umami-Version/Konfiguration, IP-/UA-
Verarbeitung, Salt/Identifiers, Events, Retention und Zugriff prüfen; nur danach
berechtigtes Interesse/Notwendigkeit oder Consent festlegen.

### PRIV-009 – Push-Nachrichten legen Kundendaten auf Fremdgeräten offen (mittel)

Push ist opt-in und pro Gerät deaktivierbar (positiv), Payloads enthalten aber
Kundennamen und Aufgabentitel. Diese können auf Sperrbildschirmen erscheinen und
laufen über Browser-Push-Infrastruktur. Offboarding und systematische Bereinigung
außer abgelaufenen Endpoints sind nicht belegt.

Empfehlung: generischer Payload, Details erst nach authentifiziertem Öffnen;
Device-Inventar, Widerruf/Offboarding und Beschäftigteninformation.

### PRIV-010 – Datenminimierung und Formularwahrheit nachschärfen (mittel)

Telefon ist zwingend, obwohl E-Mail vorhanden ist; Erforderlichkeit ist nicht
dokumentiert. Das optionale Feld `company` wird angezeigt, vom Controller aber
nicht erlaubt und nicht gespeichert, kann gleichwohl in Request-Logs landen.
Freitext, Snapshots und Anhänge können unnötige Daten aufnehmen. Der rohe
Spam-Logger schreibt E-Mail, IP und User-Agent explizit in Logs (siehe SEC-009).

Empfehlung: jedes Pflichtfeld begründen, `company` korrekt verarbeiten oder
entfernen, Freitext-Hinweise und Log-Minimierung/Retention einführen.

## Deutschland-spezifische Legal-Befunde

### LEG-001 – Impressumsverweis ist veraltet; Tatsachen extern verifizieren (mittel)

Die wesentlichen Angaben aus § 5 DDG sind vorhanden, aber Register, Vertretung,
USt-ID und Betreiberanschrift konnten nicht extern verifiziert werden. Die
Überschrift verweist noch auf § 55 Abs. 2 RStV. Dieser Verweis ist veraltet; nur
bei journalistisch-redaktionellem Angebot ist heute zusätzlich § 18 Abs. 2 MStV
einschlägig. Bei rein kommerziellen Produktseiten kann die zusätzliche
Redaktionsverantwortlichen-Angabe entbehrlich sein.

### LEG-002 – VSBG-Hinweis fehlt, Ausnahme hängt von Mitarbeiterzahl ab (bedingt, mittel)

§ 36 VSBG verlangt auf der Website eine leicht zugängliche Erklärung zur
Teilnahmebereitschaft/-pflicht an Verbraucherschlichtung. Die allgemeine Pflicht
gilt nach Abs. 3 nicht für Unternehmer mit höchstens zehn Beschäftigten am
31. Dezember des Vorjahres. Mitarbeiterzahl und Teilnahmeentscheidung sind
nicht im Repository feststellbar. Die alte EU-OS-Plattform ist seit 20.07.2025
abgeschaltet; ein früher üblicher OS-Link soll nicht neu ergänzt werden.

### LEG-003 – BFSG-Anwendbarkeit muss anhand Betreibergröße und Abschlussprozess entschieden werden (bedingt, hoch)

Ein elektronisch auf individuelle Anfrage zur Anbahnung/Schließung eines
Verbrauchervertrags erbrachter Dienst kann als Dienstleistung im elektronischen
Geschäftsverkehr unter das BFSG fallen. Kleinstunternehmen mit weniger als zehn
Beschäftigten und höchstens 2 Mio. EUR Umsatz oder Bilanzsumme sind bei
Dienstleistungen ausgenommen. Diese Fakten und der tatsächliche bindende
Vertragszeitpunkt fehlen. Unabhängig von der Ausnahme bestehen deutliche
Accessibility-Qualitätsgründe; eine fachliche WCAG-Prüfung folgt in T005.

### LEG-004 – Rechnungen sind bei mehreren Steuersätzen nicht gesetzeskonform aufgeschlüsselt (hoch)

UStG § 14 Abs. 4 Nr. 7/8 verlangt Entgelt nach Steuersätzen/Steuerbefreiungen
aufgeschlüsselt sowie den jeweiligen Steuersatz und Steuerbetrag. Das PDF zeigt
bei genau einem Satz dessen Prozentwert, bei mehreren Sätzen nur eine aggregierte
„Mehrwertsteuer“; die Zeilentabelle enthält überhaupt keinen Steuersatz. Damit
fehlt bei gemischten Sätzen die erforderliche Aufschlüsselung. Außerdem sollte
die Handelsregister-/Vertretungsdarstellung mit Steuerberatung geklärt werden.

### LEG-005 – Rechnungsnummernvergabe ist fachlich riskant (hoch)

`count + 1` unter Locks auf `SystemSetting.current` und Rechnung reduziert
Parallelität im einzelnen Prozess, ist aber kein belastbarer, lückenrobuster
Beleg einer GoBD-konformen Sequenz: gelöschte/legacy Datensätze oder mehrere
Deployments können zu Kollisionen führen; die Unique-Constraint lässt dann die
Finalisierung scheitern. Es fehlt ein unveränderbares Storno-/Korrekturdokument;
der Status `cancelled` allein ersetzt keine dokumentierte Berichtigung.

### LEG-006 – Strukturierte E-Rechnung fehlt; Übergangsfrist ist zeitkritisch (hoch, bedingt)

Die Anwendung erzeugt ausschließlich PDF. Seit 01.01.2025 müssen inländische
Unternehmer E-Rechnungen empfangen können; dafür genügt laut BMF grundsätzlich
ein E-Mail-Postfach. Für inländische B2B-Ausgangsumsätze dürfen bis 31.12.2026
noch sonstige Rechnungen verwendet werden, bei Vorjahresumsatz bis 800.000 EUR
bis 31.12.2027. Danach ist grundsätzlich eine strukturierte E-Rechnung nötig.
Kundenmix und Umsatz sind offen. XRechnung/ZUGFeRD-Export, Import/Validierung,
unveränderbare Archivierung und Prozesskontrollen gehören auf die Roadmap.

### LEG-007 – Fernabsatz-/Verbraucherinformationen hängen vom realen Vertragsschluss ab (bedingt, mittel-hoch)

Der Webflow wirkt als unverbindliche Anfrage mit anschließendem individuellem
Angebot; im Repository gibt es keine AGB, Widerrufsbelehrung oder vollständige
Fernabsatzinformationen. Wenn Verbraucher später per E-Mail/Telefon bindend
abschließen, können dennoch Fernabsatzpflichten entstehen. Für termingebundene
Freizeitdienstleistungen enthält § 312g Abs. 2 Nr. 9 BGB eine Ausnahme vom
Widerrufsrecht; ob Zapfanlagenmiete/Getränkelieferung/Eventservice darunter
fallen, ist vertrags- und leistungsabhängig und anwaltlich zu prüfen.

### LEG-008 – Preisangaben sind plausibel nur bei individuellen Angeboten ausgenommen (bedingt, niedrig-mittel)

Die PAngV verlangt gegenüber Verbrauchern grundsätzlich Gesamtpreise. § 12
Abs. 4 Nr. 1 nimmt Leistungen aus, die üblicherweise anhand individueller
schriftlicher Angebote/Voranschläge erbracht werden. Das passt zur aktuellen
Anfrage-/Angebotsarchitektur, muss aber gegen reale Werbung und öffentlich
angezeigte Rechnerpreise geprüft werden: Sobald konkrete Preise beworben werden,
müssen sie klar, wahr und grundsätzlich brutto sein.

## Drittanbieter-/Transfer-Matrix (Repository-Sicht)

| Dienst | Daten/Zweck | Standort/Transfer | Status / offene Prüfung |
|---|---|---|---|
| Hetzner | App, DB, Dateien, Logs, Umami | Deutschland/EU angenommen | AVV, Region, Subprozessoren und Backup-Orte belegen |
| Resend | Empfänger, Mailinhalt, Anhänge/Metadaten | US-Hauptverarbeitung; SCC/DPF laut DPA | DPA/TIA, Tracking, Region, Retention, Notice dringend |
| IONOS/Gmail | Versand-/Empfangskette | unbekannt | Rollen, Verträge, Routing, Retention dokumentieren |
| Browser Push | Endpoint, Geräte-/Benachrichtigungsdaten | anbieterspezifisch, ggf. Drittland | Anbieterketten und Payload-Minimierung prüfen |
| Umami self-hosted | Nutzungs-/Geräte-/Netzdaten | behauptet Hetzner | Version, Konfiguration, Identifier, Retention, §25 prüfen |
| Uptime Kuma/Telegram | Betriebsdaten/Alerts | unbekannt | Token/PII, AVV/Transfer und Retention prüfen |

## Positive Feststellungen

- Datenschutz und Impressum sind von jeder öffentlichen Seite verlinkt.
- Anfrageverarbeitung nennt eine plausible vorvertragliche Rechtsgrundlage.
- Push benötigt Browsererlaubnis und kann pro Gerät deaktiviert werden.
- Umami ist optional, self-hosted vorgesehen und deutlich datensparsamer als
  viele Werbetracker; die konkrete Konfiguration bleibt zu beweisen.
- Finalisierte Angebote/Rechnungen verwenden Snapshots und sperren wesentliche
  Änderungen, was Nachvollziehbarkeit unterstützt.

## Betreiber-/Anwaltsfragen

1. Exakter Firmenname, Rechtsformzusatz, Register, Vertretung, USt-ID und
   Anschrift aktuell?
2. Beschäftigte am 31.12.2025, Umsatz/Bilanzsumme und B2C/B2B-Anteile?
3. Wann und über welchen Kanal kommt ein bindender Verbrauchervertrag zustande?
4. Welche AVV/DPA/TIA, Löschfristen, Subprozessorlisten und Regionen sind real
   vereinbart?
5. Existieren VVT, TOM, Löschkonzept, Incident-/Breach-SOP und Rechte-SOP
   außerhalb des Repositories?
6. Welche Umami-, Resend-, Push-, Log- und Backup-Konfiguration läuft wirklich?
7. Welche Belege unterliegen welcher steuerlichen Aufbewahrung und wie werden
   Storno/Korrektur sowie E-Rechnung organisatorisch behandelt?
8. Ist das Angebot journalistisch-redaktionell, wird an Schlichtung teilgenommen,
   und greift die BFSG-Kleinstunternehmerausnahme?

## Receipt Summary

Der Review bestätigt zehn Privacy-/DSGVO- und acht Deutschland-spezifische
Legal-Befunde. Dringend sind eine vollständige Art.-13-Information, Lösch- und
Rechteprozesse, LocalStorage-Minimierung, Drittanbieter-/Transfer-Governance,
Rechnungssteueraufschlüsselung und die E-Rechnungs-Roadmap. Betreiberabhängige
VSBG-, BFSG-, Fernabsatz- und Medienpflichten sind bewusst als bedingt markiert.
