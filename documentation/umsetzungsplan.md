# Umsetzungsplan Zapfe Rails

Stand: 2026-02-23
Basis: Rails 8.1.2, SQLite3, Active Storage (Disk), Resend, Hotwire

## Phase 0 - Setup & Projektbasis
Ziel: lauffähige Basis mit definierten Konventionen.

1. Rails 8.1.2 Projektgrundlage erzeugen.
2. Projektstruktur für Public/Admin-Bereich festlegen.
3. Tailwind-Basis-Theme an bestehendes Zapfe-Design angleichen.
4. Dokumentation (Leitlinien + Plan) anlegen.

Ergebnis:
- startfähiges Rails-Projekt
- dokumentierte Architektur- und UI-Leitplanken

## Phase 1 - Domainmodell (V1)
Ziel: schlankes Modell nur für reale Anforderungen.

1. Models/Migrations anlegen:
   - `categories`
   - `products`
   - `product_variants`
   - `events` (inkl. `instagram_url`)
   - `admin_users`
   - optional `inquiries`
2. Beziehungen/Validierungen definieren.
3. Seeds für lokale Entwicklungsdaten aufbauen.

Ergebnis:
- konsistentes, kleines Datenmodell
- keine Legacy-Tabellen ohne Nutzen

## Phase 2 - Admin-Funktionen
Ziel: Inhalte ohne Deployment pflegbar machen.

1. Serverseitiges Admin-Login umsetzen (`AdminUser`).
2. CRUD für Kategorien, Produkte, Varianten.
3. Active-Storage-Bildupload für Produkte.
4. CRUD für Events inkl. optionaler Instagram-URL.

Ergebnis:
- Events und Produktdaten vollständig im Admin pflegbar

## Phase 3 - Öffentliche Seiten (UI-nah)
Ziel: bestehendes Erscheinungsbild weitgehend beibehalten.

1. Public-Seiten in Rails Views nachbauen:
   - Start
   - Drinks/Produkte
   - Events
   - Calculator
   - Contact
   - Impressum/Datenschutz
2. Komponenten/Partials wiederverwenden, um UI konsistent zu halten.
3. Kleine Stimulus-Controller für Interaktionen statt schwerer JS-Abhängigkeiten.

Ergebnis:
- öffentliches Frontend optisch und funktional nah am aktuellen Stand

## Phase 4 - Kalkulator 1:1 (ohne Geo)
Ziel: bestehenden Wizard zunächst stabil übernehmen.

1. Preislogik als Service extrahieren (z. B. `Pricing::Calculator`).
2. Bestehende Regeln aus aktuellem Projekt initial 1:1 abbilden.
3. Geocoding/Distanzlogik explizit entfernen.
4. Ergebnisdarstellung und Anfrage-Übergabe beibehalten.

Ergebnis:
- wartbare, testbare Kalkulationslogik
- später leicht vereinfachbar/erweiterbar

## Phase 5 - Mailversand mit Resend
Ziel: verlässliche Anfrage-Kommunikation.

1. Action Mailer konfigurieren (`RESEND_API_KEY`).
2. Mailer + Templates für:
   - Kundenbestätigung
   - Admin-Benachrichtigung
3. Fehlerbehandlung und Logging ergänzen.

Ergebnis:
- stabiler Versand wie bisher, aber im Rails-Stack integriert

## Phase 6 - Datenübernahme
Ziel: produktive Inhalte übernehmen.

1. Supabase-Datenexport für relevante Tabellen (Produkte/Kategorien/Varianten/Event-Inhalte).
2. Importskripte nach SQLite (idempotent) erstellen.
3. Produktbilder übernehmen:
   - entweder initial von bestehender URL herunterladen und attachen
   - oder im Admin schrittweise neu pflegen
4. Stichproben zur Datenvalidierung durchführen.

Ergebnis:
- inhaltlich vollständiger Startbestand im neuen System

## Phase 7 - Tests & Qualität
Ziel: Regressionen vermeiden, speziell beim Kalkulator.

1. Model- und Service-Tests für Preislogik.
2. Request-/Controller-Tests für Kern-Endpoints.
3. Systemtests für:
   - Admin Login
   - Produktpflege
   - Eventpflege
   - Calculator Anfrage-Flow
4. Smoke-Test-Checkliste für Deployment.

Ergebnis:
- belastbare Qualitätsbasis für weitere Iterationen

## Phase 8 - Deployment-Readiness (ohne Cutover-Strategie)
Ziel: App deploybar auf Hetzner wie Hausl.

1. `config/deploy.yml` für `zapfe-rails` vorbereiten.
2. Persistentes Storage-Volume für SQLite + Active Storage konfigurieren.
3. Secrets definieren:
   - `RAILS_MASTER_KEY`
   - `SECRET_KEY_BASE`
   - `RESEND_API_KEY`
4. Basis-Monitoring/Logs prüfen.

Ergebnis:
- technisch bereit für DNS-Umschaltung zum gewünschten Zeitpunkt

## Offene Entscheidungen für Start
1. Soll `inquiries` in V1 persistiert werden oder nur Mailversand?
2. Admin-UI deutschsprachig vollständig in V1 oder zunächst gemischt?
3. Event-Sortierung: manuell (Position) oder rein datumsgesteuert?
