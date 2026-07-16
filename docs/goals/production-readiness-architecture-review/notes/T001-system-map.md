# T001 – System-, Datenfluss- und Trust-Boundary-Karte

## Prüfstand

- Branch: `architecture-review`
- Commit: `6941271fbc1d41af00eb3e71acfe145ca7796a9d`
- Stand: 2026-07-16, Europe/Berlin
- Arbeitsbaum vor dem Audit: sauber mit Ausnahme der neu angelegten GoalBuddy-Auditdateien
- Methode: read-only Inventar von Routen, Modellen, Schema, Controllern,
  Services, Jobs, Mailern, Views/JavaScript, Deployment, CI und Dokumentation

## Produkt- und Systemgrenze

Zapfe ist ein Rails-8.1-Monolith mit zwei deutlich verschiedenen Oberflächen:

1. Öffentliche Marketing- und Anfrageoberfläche (`PagesController`,
   `InquiriesController`) für Events, Getränke, Kalkulator, Kontakt sowie
   Impressum und Datenschutz.
2. Authentifizierte interne Auftragszentrale unter `/admin` für Anfragen,
   Kunden/Kontakte, Aufträge, Angebote, Rechnungen, Beschaffung, Ressourcen,
   Reservierungen, Aufgaben, Zeiterfassung, Dateien, Stammdaten und interne Hilfe.

Die Anwendung ist daher zugleich öffentliches Lead-System und internes
geschäftliches Kernsystem. Das Datenmodell verarbeitet personenbezogene
Kontaktdaten, Kommunikation, Geschäfts- und Preisdaten, Rechnungsdaten,
Mitarbeiterdaten, Dokumente sowie Push-Endpunkte.

## Komponenten

| Komponente | Aufgabe | Beleg |
|---|---|---|
| Rails/Hotwire-Monolith | HTML, Formulare, Admin-CRUD und Geschäftslogik | `Gemfile:4-48`, `config/routes.rb:1-109` |
| Öffentliche Anfrage | Annahme, Spam-/Rate-Limit-Prüfung, Speicherung, zwei E-Mails | `app/controllers/inquiries_controller.rb:1-101` |
| Admin-Authentifizierung | Session-basiertes Login mit `has_secure_password` | `app/controllers/application_controller.rb:13-27`, `app/models/admin_user.rb:1-19` |
| Auftragsdomäne | Inquiry → Order → Offer/Invoice sowie Aktivitäten, Aufgaben und Dokumente | `app/models/inquiry.rb`, `app/models/order.rb`, `app/models/offer.rb`, `app/models/invoice.rb` |
| Dateiablage | Active Storage auf lokalem Datenträger | `config/environments/production.rb:19`, `config/storage.yml:5-7` |
| Persistenz | SQLite-Primärdatenbank plus separate Solid-Cache/Queue/Cable-Datenbanken | `config/database.yml:25-40` |
| Hintergrundjobs | Solid Queue für Mail- und Push-Jobs; tägliche Fälligkeitsprüfung | `config/environments/production.rb:50-53`, `config/recurring.yml:12-18` |
| Dokumenterzeugung | Prawn-PDFs für Angebote/Rechnungen und Versand per Mail | `app/services/offers/pdf_renderer.rb`, `app/services/invoices/pdf_renderer.rb`, `app/services/customer_document_delivery.rb` |
| PWA/Push | Admin-PWA, bewusst kein Cache für authentifiziertes HTML, Web Push | `app/views/pwa/service_worker.js.erb:1-49`, `app/javascript/controllers/push_controller.js:1-82` |
| Analytics | optionales Umami-Script im öffentlichen Layout | `app/views/layouts/application.html.erb:38`, `app/helpers/application_helper.rb:272-290`, `config/deploy.yml:27-35` |
| Deployment | Docker/Kamal auf Hetzner-IP, TLS über Proxy, persistentes Storage-Volume | `Dockerfile:1-77`, `config/deploy.yml:1-54` |
| Monitoring | Rails-Healthcheck und token-geschützter Inquiry/Mailer-Synthetic-Check | `config/routes.rb:17,108`, `app/controllers/monitoring_controller.rb:1-38`, `documentation/monitoring.md` |

## Zentrale Datenflüsse

### Öffentliche Anfrage

`Browser → Rails-Formular → Spam/Rate Limit → Inquiry/SQLite → Solid Queue → Resend SMTP → Kunde + Admin-Postfach`

Verarbeitet werden Name, E-Mail, Telefon, Veranstaltungs- und Lieferdaten,
Nachricht, Auswahl- und Preis-Snapshots sowie ein Privacy-Boolean
(`db/schema.rb:205-247`, `app/controllers/inquiries_controller.rb:74-100`).

### Interne Auftragsbearbeitung

`Admin-Browser → Session/CSRF → Admin-Controller → SQLite/Active Storage → Aktivitäten, PDF-Erzeugung, Mailversand`

Die Domäne umfasst Kunden und Kontakte, Verantwortliche, interne Notizen,
Anhänge, Angebote, Einkaufskonditionen, Marge, Rechnungen, Reservierungen,
Aufgaben und Zeiteinträge. Finalisierte Angebote/Rechnungen werden durch
Snapshots und Änderungsvalidierungen geschützt (`app/models/offer.rb:74-86`,
`app/models/invoice.rb:37-49`).

### Push

`Admin-Browser → Browser-Push-Subscription → PushSubscription/SQLite → Solid Queue → Web-Push-Endpunkt des Browseranbieters → Sperrbildschirm/Endgerät`

Push-Endpunkte und Schlüsselmaterial liegen je Admin in der Datenbank;
Benachrichtigungstext und Zielpfad verlassen den Server über den Push-Dienst
(`app/models/push_subscription.rb:1-5`,
`app/services/push_notifications/send_notification.rb:1-24`,
`app/views/pwa/service_worker.js.erb:25-49`).

### Analytics

`Öffentlicher Browser → analytics.duzend.net/Umami`

Die Einbindung ist per Environment aktivierbar. Die tatsächliche
Serverkonfiguration, gespeicherten Felder und Aufbewahrung des separaten
Analytics-Systems liegen außerhalb dieses Repositories.

### Betrieb und Sicherung

`Kamal/Container → Rails + Solid Queue im Puma-Prozess → benanntes Docker-Volume /rails/storage`

Das Volume enthält mindestens Primärdatenbank, Cache/Queue/Cable-Datenbanken und
Uploads. Im Repository wurde kein belegter automatisierter Backup-/Restore-Pfad
gefunden. Das wird in T004 vertieft.

## Trust Boundaries

1. Unauthentifizierter Internetbrowser ↔ öffentliche Rails-Endpunkte
2. Authentifizierter Adminbrowser/PWA ↔ Admin-Session und sämtliche Geschäftsdaten
3. Rails-Prozess ↔ SQLite- und Active-Storage-Dateien im persistenten Volume
4. Rails/Solid Queue ↔ Resend SMTP
5. Rails ↔ externe Browser-Push-Infrastruktur
6. Öffentlicher Browser ↔ separates Umami-System
7. Deployment-Workstation/GitHub/Container Registry ↔ Hetzner-Host und Secrets
8. Uptime Kuma ↔ öffentliche Health-/Monitoring-Endpunkte
9. Lokale Legacy-Importquellen/Supabase ↔ Import-Rake-Tasks (nicht Teil des normalen Runtime-Pfads)

## Datenklassen

- Kontaktdaten: Namen, E-Mail, Telefon, Anschriften, Rollen
- Veranstaltungsdaten: Datum, Ort, Gästezahl, Zeiten, Wünsche und Freitext
- Kommunikation: Anfrage- und Hilfetexte, Notizen, Signaturen, Mailinhalte
- Dokumente: Bilder, PDFs, Angebote, Rechnungen, Bestell- und Übergabeunterlagen
- Geschäfts-/Finanzdaten: Preise, Rabatte, Kosten, Margen, Rechnungsnummern, Zahlungsstatus
- Mitarbeiterdaten: Konten, Zuständigkeiten, Aktivitäten, Zeiteinträge, Push-Präferenzen
- Geräte-/Browserdaten: Push-Endpunkt, `p256dh`, `auth`, gegebenenfalls Analytics-Daten
- Betriebsdaten: Request-ID, Logs, IP/User-Agent bei geblockten Spam-Anfragen, Monitoring

## Bereits erkennbare positive Schutzmaßnahmen

- Rails-Standardstack, CSRF-Metadaten und zentrale Admin-Authentifizierung.
- `force_ssl`/`assume_ssl`, HSTS über Rails und nicht-root Docker-Runtime.
- Parameternamen für zentrale personenbezogene Felder werden aus Logs gefiltert.
- CSP ist aktiviert; authentifiziertes HTML wird vom Service Worker ausdrücklich nicht gecacht.
- Dateityp- und Größenvalidierungen sind für zentrale Anhänge vorhanden.
- Finalisierte Angebots-/Rechnungsdaten besitzen Snapshots und Änderungsbarrieren.
- GitHub CI enthält Brakeman, Bundler Audit, Importmap Audit, RuboCop sowie Rails- und Systemtests.
- Dependabot ist für Bundler und GitHub Actions aktiv.

## Verifikations- und Audit-Gates

- `bin/brakeman --no-pager`
- `bin/bundler-audit`
- `bin/importmap audit`
- `bin/rubocop`
- `bin/rails test`
- `bin/rails test:system`
- `npm run test:e2e` beziehungsweise gezielte Playwright-Specs
- `bin/rails zeitwerk:check`
- `bin/rails db:prepare` beziehungsweise Schema-/Migrationsreproduktion in einer isolierten Testdatenbank
- manuelle Header-, Auth-, Datei-, PWA-, Accessibility- und Rechtsseitenprüfung

## Frühe Risikohypothesen für die Folgetasks

1. Das eingecheckte `db/schema.rb` enthält `configuration_sessions`, `scenes`,
   `solutions` und `solution_variants`, während im aktuellen Branch weder
   zugehörige Migrationen noch Modelle/Controller auffindbar sind. Ein frisches
   `db:migrate` kann daher eine andere Struktur als `db:schema:load` erzeugen.
2. Die interne App besitzt nur die grobe Rolle „aktiver Admin“. Eine feinere
   Autorisierung für Kontenverwaltung, Finanzdaten, Downloads oder Einstellungen
   ist im Routen-/Controllerinventar nicht sichtbar.
3. Das gesamte produktive Kernsystem einschließlich Uploads und Queue liegt auf
   einem einzelnen lokalen Docker-Volume; Backup, Restore und Offsite-Kopie sind
   im Repository noch nicht belegt.
4. Archivierung ist implementiert, eine tatsächliche Lösch-/Anonymisierungslogik
   wird in der Roadmap selbst noch als offen bezeichnet.
5. Push-Inhalte können auf Endgeräten und über externe Push-Infrastruktur sichtbar
   werden; Payload-Minimierung und organisatorische Regeln müssen geprüft werden.
6. Umami ist produktiv aktiviert, aber Rechtsgrundlage, Konfiguration,
   Aufbewahrung und Beschreibung auf der Datenschutzseite müssen abgeglichen werden.
7. Der Monitoring-Token wird als Query-Parameter verwendet und kann dadurch in
   Proxy-/Monitoring-Logs oder History gelangen.

## Scope-Grenzen

Nicht aus dem Repository belegbar sind derzeit insbesondere reale
Produktions-Header und Proxy-Konfiguration, Hetzner-/Docker-Volume-Backups,
Server-Patching und Firewall, Uptime-Kuma-Zustand, Umami-Datenhaltung,
Resend-Verträge/Regionen, AV-Verträge, tatsächliche Nutzerprozesse,
Verzeichnis der Verarbeitungstätigkeiten, TOMs, Incident-Prozess und die
Richtigkeit der Betreiberangaben. Diese Punkte werden als offene Betreiberfragen
behandelt und nicht stillschweigend als erfüllt angenommen.

