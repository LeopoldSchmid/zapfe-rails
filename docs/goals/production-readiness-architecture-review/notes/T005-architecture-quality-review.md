# T005 – Architektur, Tests, Accessibility, Performance und PWA

Stand: 2026-07-16. Produktcode wurde nicht verändert. Browser-Suites wurden nach
einem sandboxbedingten Socket-Fehler zulässigerweise mit lokalem Testserver
außerhalb der Netzwerk-Sandbox wiederholt; nur diese Wiederholung ist fachlich
gewertet.

## Gate-Ergebnisse

| Gate | Ergebnis |
|---|---|
| `bin/rails test` | grün: 178 Runs, 706 Assertions, 0 Fehler/Fehlschläge/Skips |
| `RAILS_ENV=test bin/rails db:seed:replant` | grün |
| `bin/rubocop` | rot: 264 Dateien, 30 Layout/Style-Offenses, 16 autocorrectable |
| Rails-Systemtests | rot: 13 Runs, 32 Assertions, 6 Failures, 2 Errors |
| Playwright E2E | rot: 2 bestanden, 1 fehlgeschlagen |
| Security-Gates | siehe T002: Importmap grün; Dependency-Gate und Brakeman-Wrapper rot |

Systemtest-Fehler sind überwiegend veraltete Text-/DOM-Erwartungen
(`Login erfolgreich`, `GESCHÄTZTER PREIS`, alte Calculator-IDs/Links), enthalten
aber auch einen nicht funktionierenden Mobile-Navigationstest. Der Playwright-
Smoke erwartet die alte Überschrift „Preis grob einschätzen“. Damit ist der
Browser-Gate derzeit nicht als Release-Signal nutzbar, selbst wenn Teile des
Produkts funktionieren.

## Architektur-/Qualitätsbefunde

### ARCH-001 – Frischer Datenbankaufbau ist wegen Schema-Drift nicht reproduzierbar (hoch)

`db/schema.rb` enthält `configuration_sessions`, `scenes`, `solutions` und
`solution_variants`; dafür existieren weder aktuelle Migrationen noch Models.
Ein frischer Aufbau aus Migrationen kann daher vom eingecheckten Schema und von
Produktion abweichen. Das gefährdet Deploy, Test, Restore und Onboarding.

Empfehlung: Ursprung bestimmen; ungenutzte Tabellen per Migration entfernen
oder fehlende Migrationen sauber rekonstruieren. Frischen `db:prepare` aus leerem
Storage in CI gegen erwartetes Schema testen.

### ARCH-002 – Direkter Auftrag aus Vorlage kann teilweise angelegt bleiben (hoch)

`Admin::OrdersController#create` speichert den Auftrag und ruft erst danach
`Orders::ApplyTemplate#materialize!` in einer neuen Transaktion auf. Scheitern
Tags, Aufgaben, Checklisten, Anhänge oder Reservierungen, bleibt ein Auftrag ohne
vollständige Vorlageninhalte bestehen und die Request-Exception wird nicht
fachlich behandelt.

Empfehlung: Auftrag und vollständige Materialisierung in eine Service-
Transaktion legen; klare Konfliktmeldung für Ressourcen; Rollback-Test für jeden
Materialisierungsschritt.

### ARCH-003 – Statusübergänge sind verteilt und nicht als Invarianten modelliert (mittel-hoch)

Statuslisten und deutsche Label/Übergangsbedingungen liegen in Models,
Controllern, Views und Services. Modelvalidierungen schützen Finalisierung nur
teilweise; aus einem Draft wären programmatisch unerwartete Statussprünge
möglich. Mail-, Angebots-, Rechnungs-, Bestell- und Auftragszustände bilden keine
einheitlich auditierbare Transition-Policy.

Empfehlung: explizite Commands/Transition-Methoden mit erlaubten Von→Nach-
Übergängen, atomaren Side Effects und Contract-Tests; Views fragen Fähigkeiten
statt eigene Statuslisten ab.

### ARCH-004 – Controllers/Views bündeln zunehmend viele Verantwortungen (mittel)

140 Ruby/JS-Komponenten sind grundsätzlich überschaubar und die neuen Services
trennen wichtige Geschäftsprozesse positiv. Gleichzeitig enthält
`Admin::OrdersController` 204 Zeilen für CRUD, Attachments, Audit, mehrere
Arbeitsbereiche und Queries; `InquiriesController` mischt Spam-Erkennung,
Rate-Limits, Logging, Persistenz und Mail; mehrere öffentliche ERB-Seiten haben
250–323 Zeilen. Das erhöht Änderungs- und Testkopplung.

Empfehlung: vertikale Use Cases/Form Objects/Queries für Anfrageannahme,
Auftragsänderung und Attachments; wiederverwendbare View-Komponenten nur an
echten Fachgrenzen, nicht als rein kosmetische Zerteilung.

### ARCH-005 – Nummern/PDF/Filesystem-Side-Effects sind nur teilweise atomar (hoch)

Angebots- und Rechnungsnummern nutzen `count + 1`; Parallelität, gelöschte
Datensätze und mehrere Prozesse sind nicht gezielt getestet. PDF-Dateianlage und
DB-Transaktion können auf dem lokalen Dateisystem keine echte atomare Einheit
bilden. Fehlgeschlagene Aktivität/PDF-Erzeugung kann Orphans oder unklare
Wiederholung erzeugen. Siehe auch LEG-005 und OPS-003.

Empfehlung: DB-gestützte Sequenz/Counter mit Retry bei Unique-Konflikt,
idempotente Finalisierung, nachprüfbare Dokument-Checksumme und Orphan-Recovery.

### QUAL-001 – Alle drei release-relevanten statischen/browsernahen Gates sind rot (hoch)

RuboCop, Rails-Systemtests und Playwright sind aktuell nicht grün; zusätzlich
blockieren Security-Gates. Besonders problematisch ist nicht die Zahl kleiner
Style-Offenses, sondern dass Änderungen mit roten Baselines nicht zuverlässig
zwischen Regression und Altfehler unterscheiden können.

Empfehlung: Gate-Baseline sofort grün machen, CI verpflichtend schützen und
fehlgeschlagene Browsererwartungen gegen aktuelles gewünschtes Verhalten
aktualisieren – nicht blind Tests löschen.

### QUAL-002 – Kritische Failure-, Concurrency- und Jobpfade sind ungetestet (hoch)

Keine Jobtests für `DueTaskPushNotificationsJob`/`PushNotificationJob`; keine
Tests für SMTP-/Queue-/Push-Ausfall, Retry/Idempotenz, parallele
Angebots-/Rechnungsnummern, gemischte Steuersätze im Rechnungs-PDF,
Template-Rollback, Restore oder Retention/Löschung. Testabdeckung wird nicht
gemessen; ein grünes 178er Unit-/Controller-Ergebnis belegt diese Risiken daher
nicht.

### QUAL-003 – JavaScript und Accessibility haben keine automatisierte Regressionserkennung (mittel-hoch)

Es gibt zahlreiche Stimulus-Controller, aber keine JS-Unit-/Component-Tests und
keinen axe/Lighthouse/WCAG-Gate. Nur drei eigenständige Playwright-Tests decken
wenige öffentliche Flows ab; Auth-/PWA-/Push-/Keyboard-/Screenreader-Flows sind
dort nicht enthalten.

### QUAL-004 – Generierte Scaffold-Views und veraltete Dokumentation erzeugen Rauschen (niedrig-mittel)

Nicht verwendete `create/update/destroy.html.erb`-Scaffoldseiten liegen für
mehrere Controller im Repository. Testing-Dokumentation behauptet sinngemäß,
`bin/rails test` umfasse Systemtests, während Systemtests separat ausgeführt
werden müssen; die rote Browserbaseline ist nicht vermerkt. Das erschwert
Onboarding und kann falsche Release-Sicherheit erzeugen.

### PERF-001 – Admin-Listen sind unpaginiert und teils quadratisch im View (mittel)

Anfragen, Aufträge, Kunden, Produkte und Ressourcen werden ohne Pagination
geladen. Der Ressourcenkalender selektiert für jede Ressource und jeden Tag erneut
in Ruby über alle Wochenreservierungen. Produkt-/Lieferantenansichten bauen große
Form-/Association-Bäume. Mit aktueller kleiner Datenmenge plausibel, aber ohne
Lastgrenzen und Query-/Response-Budgets skaliert dies vorhersehbar schlecht.

Empfehlung: Pagination/Filter, Query Objects, Kalenderdaten einmal indexieren,
Bullet/query-count Tests und realistische Volumen-Benchmarks.

### PERF-002 – Repository/Image-Build trägt große unoptimierte Medienquellen (niedrig-mittel)

`app/assets/images` umfasst ca. 113 MB, darunter einzelne 6–17-MB PNG/JPEG.
Optimierte WebP-/Public-Varianten werden positiv genutzt, aber Quelloriginale
werden beim Docker-`COPY . .` und Asset-Pipeline-Kontext mitgeführt. Das erhöht
Build-/Push-/Storage-Kosten und birgt das Risiko versehentlicher Auslieferung.

## Accessibility-Befunde (manueller Code-/Browserreview, kein Voll-Audit)

### A11Y-001 – Kein belastbarer WCAG/BFSG-Nachweis (hoch, falls BFSG anwendbar; sonst mittel)

Keine automatisierte Regelprüfung, keine manuelle Tastatur-/Screenreader-
Testmatrix, keine Kontrastmessung und keine Barrierefreiheitserklärung. LEG-003
beschreibt die bedingte BFSG-Anwendbarkeit. Ein technischer Code-Review kann
Konformität nicht bestätigen.

### A11Y-002 – Mobile Menüs kommunizieren Zustand und Fokus nicht (mittel-hoch)

Öffnen-Buttons haben kein `aria-expanded`/`aria-controls`; der Controller toggelt
nur CSS und Body-Overflow. Fokus wird weder ins Menü gesetzt noch eingeschlossen
oder beim Schließen zurückgegeben, Escape wird nicht behandelt. Gleiches Risiko
besteht für den Admin-Mobile-Header; der entsprechende Systemtest ist rot.

### A11Y-003 – Skip-Link und aktuelle Navigation fehlen (mittel)

Public/Admin-Layouts haben `<main>`, aber keinen „Zum Inhalt“-Link. Öffentliche
und Admin-Hauptnavigation markieren den aktuellen Link nur visuell, nicht mit
`aria-current`. Bei umfangreicher Adminnavigation kostet das viele Tabstopps.

### A11Y-004 – Autoplay-Videos besitzen keinen Pause-Mechanismus (mittel-hoch)

Vier sichtbare Produkt-/Getränkevideos starten automatisch, loopen und werden
durch `lazy_video_controller.js` auch programmatisch abgespielt. Es gibt keine
Pause-/Stopsteuerung; `prefers-reduced-motion` stoppt diese Videos und die
Page-Transition/Cue-Animationen nicht vollständig. Das widerspricht dem
WCAG-Grundsatz für länger laufende bewegte Inhalte neben anderem Inhalt.

### A11Y-005 – Fehler/Status und Medienalternativen sind uneinheitlich (mittel)

Admin-Flashes besitzen `aria-live`; öffentliche Flashes nicht. Clientseitige
Formfehler setzen keinen belegten Fokus/`aria-invalid`/`aria-describedby`.
Einige dynamische Adminbilder haben keine fachlich aussagekräftigen Alttexte;
Videos haben kurze Labels, aber keine Textalternative für relevante Inhalte.

## PWA-Befunde

### PWA-001 – Service Worker kontrolliert unnötig den gesamten Origin (niedrig-mittel)

Die Manifest-Scope ist `/admin/`, der Service Worker liegt/registriert sich aber
unter `/service-worker.js` und kontrolliert dadurch standardmäßig den gesamten
Origin. Positiv: Fetch-Code cached ausschließlich das Manifest und niemals
authentifiziertes HTML. Dennoch vergrößert Root-Scope die Wirkung eines späteren
Service-Worker-Fehlers oder Kompromisses.

### PWA-002 – Update-/Offline-/Fehler-UX und Tests fehlen (mittel)

`skipWaiting`/`clients.claim` aktualisieren sofort, ohne Versionshinweis;
Install-/Push-Controller werfen Netzwerkfehler ohne sichtbaren Recovery-Pfad.
Es gibt keine automatisierten Tests für Manifest/Installability, Worker-Update,
Offline-Verhalten, Push-Permission denied, Abmeldung/Subscription-Cleanup oder
Notification Click. Die bewusste Entscheidung, Admin-HTML nicht offline zu
cachen, ist aus Security-Sicht positiv und sollte als Produktverhalten erklärt
werden.

## Positive Feststellungen

- Klare Rails-/Hotwire-Monolitharchitektur mit gut benannten fachlichen Services,
  Foreign Keys, Unique-Indizes, Locks und Snapshots an vielen kritischen Stellen.
- 178 schnelle Unit/Model/Controller/Service-Tests sind vollständig grün; Seeds
  sind reproduzierbar.
- Semantische Grundstruktur (`lang=de`, `main`, nav labels, viele echte Labels,
  sinnvolle Alttexte, Admin-Live-Region) ist vorhanden; sichtbare Fokusstyles und
  teilweise Reduced-Motion-Regeln existieren.
- PWA cached keine vertraulichen Adminseiten; Push ist opt-in und die Manifest-
  Scope ist auf Admin ausgerichtet.
- Responsive WebP-Bilder und Lazy-Video-Laden reduzieren öffentliche Netzlast.

## Empfohlene Verifikation nach Korrektur

1. `bin/rails test` und Seeds grün halten.
2. RuboCop, alle 13 Rails-Systemtests, alle Playwright-Specs sowie Security-Gates
   auf grün bringen und als verpflichtende PR-Checks schützen.
3. Leere Datenbank vollständig aus Migrationen aufbauen und Schema vergleichen.
4. Neue Tests für Rollback, Concurrency, gemischte Steuer, Mail/Queue/Push-Ausfall,
   Retention und Restore.
5. axe-core in öffentliche und authentifizierte Browser-Smokes integrieren;
   ergänzend Tastatur, 200/400-% Zoom, Kontrast, Reduced Motion und mindestens
   NVDA/VoiceOver manuell prüfen.
6. Realistische Datenmenge laden und Query-Zahl, p95-Latenz, Memory sowie
   Kalender-/Indexseiten messen.
