# Architecture Review (2026-02-27)

## Kurzfazit

Die Basis ist solide: klassischer Rails-Stack, klare Domänenmodelle, überschaubare Controller, grüne Tests (`bin/rails test`: 38 Tests, 0 Fehler). Das Hauptproblem liegt nicht im Framework, sondern in der Schichtung der Web-App: wesentliche Produktlogik sitzt unstrukturiert im Frontend, ist doppelt implementiert und nur schwach an das Domänenmodell angebunden. Dadurch steigt das Risiko für Regressionen, inkonsistente Preise und schwer wartbare UI-Änderungen.

## Positiv

- Rails bleibt weitgehend im Standard-Setup, ohne unnötige Meta-Architektur.
- CRUD-Bereiche im Admin sind nachvollziehbar und einfach gehalten.
- Grundlegende SEO- und Structured-Data-Bausteine sind vorhanden.
- Die wichtigsten Kernpfade sind testbar und aktuell grün.

## Zentrale Findings

### 1. Frontend-Domain-Logik ist in einer einzelnen, monolithischen Datei konzentriert

Datei: [app/javascript/application.js](/home/leo/dev/projects/zapfe-rails/app/javascript/application.js)

- Die komplette Logik fuer Warenkorb, Preisberechnung, Filter, Overlay-Steuerung, Page-Transitions und Formular-Synchronisation liegt in einer einzigen Datei mit 696 Zeilen.
- Der Code umgeht die vorhandene Stimulus-Struktur fast komplett, obwohl das Projekt explizit Hotwire/Stimulus verwendet.
- Das erschwert Wiederverwendung, gezielte Tests und sichere Änderungen, weil mehrere Verantwortlichkeiten eng gekoppelt sind.

Konkrete Symptome:

- `initCalculatorPage` mischt Pricing, Formularzustand, Persistenz und Rendering ([app/javascript/application.js](/home/leo/dev/projects/zapfe-rails/app/javascript/application.js#L120)).
- `initDrinksPage` enthält einen zweiten, leicht abweichenden Warenkorb- und Variantenauswahl-Stack ([app/javascript/application.js](/home/leo/dev/projects/zapfe-rails/app/javascript/application.js#L472)).

Empfehlung:

- In Stimulus-Controller aufteilen: `cart_controller`, `calculator_controller`, `drink_filters_controller`, `page_transition_controller`.
- Gemeinsame Pure Functions fuer Preis- und Cart-Logik in ein separates Modul auslagern.

### 2. Doppelte Cart- und Variant-Logik erzeugt Divergenzrisiko

Datei: [app/javascript/application.js](/home/leo/dev/projects/zapfe-rails/app/javascript/application.js)

- Variantenauswahl, Cart-Rendering, Mengenaenderung und `localStorage`-Sync sind fuer `/calculator` und `/drinks` jeweils separat implementiert.
- Beide Implementierungen sind aehnlich, aber nicht identisch. Damit ist praktisch vorprogrammiert, dass sich Verhalten mittelfristig auseinanderentwickelt.

Beispiele:

- Separates `applyVariantStyles` in beiden Bereichen ([app/javascript/application.js](/home/leo/dev/projects/zapfe-rails/app/javascript/application.js#L187), [app/javascript/application.js](/home/leo/dev/projects/zapfe-rails/app/javascript/application.js#L503)).
- Separates Cart-Rendering via HTML-Template-Strings ([app/javascript/application.js](/home/leo/dev/projects/zapfe-rails/app/javascript/application.js#L229), [app/javascript/application.js](/home/leo/dev/projects/zapfe-rails/app/javascript/application.js#L582)).

Empfehlung:

- Eine zentrale Cart-API im Frontend definieren.
- Rendering entweder serverseitig als Partials oder clientseitig ueber eine gemeinsame View-Komponente kapseln.

### 3. Unsanitized `innerHTML` mit Produktdaten ist ein echtes XSS-Risiko

Datei: [app/javascript/application.js](/home/leo/dev/projects/zapfe-rails/app/javascript/application.js)

- Produktnamen, Marken und Labels stammen aus der Datenbank, werden in `localStorage` abgelegt und spaeter ungeescaped via `innerHTML` wieder in den DOM geschrieben.
- Sobald Admin-Daten unerwartete HTML-Fragmente enthalten, kann Frontend-Markup oder Script-Injektion entstehen.

Betroffene Stellen:

- Rechner-Warenkorb ([app/javascript/application.js](/home/leo/dev/projects/zapfe-rails/app/javascript/application.js#L229))
- Drinks-Warenkorb ([app/javascript/application.js](/home/leo/dev/projects/zapfe-rails/app/javascript/application.js#L582))

Empfehlung:

- Kein `innerHTML` fuer datengetriebene Inhalte.
- DOM-Nodes programmgesteuert erzeugen oder serverseitig gerenderte sichere HTML-Fragmente verwenden.

### 4. Der Preisrechner schreibt wesentliche Geschaeftsdaten nur in Freitext-/JSON-Felder

Dateien:

- [app/views/pages/calculator.html.erb](/home/leo/dev/projects/zapfe-rails/app/views/pages/calculator.html.erb)
- [app/javascript/application.js](/home/leo/dev/projects/zapfe-rails/app/javascript/application.js)
- [app/models/inquiry.rb](/home/leo/dev/projects/zapfe-rails/app/models/inquiry.rb)

- Mietoption, Mietdauer, Uhrzeit, Lieferadresse und Cart-Zustand werden nicht als saubere, typisierte Domänendaten persistiert.
- Stattdessen landen diese Informationen in `selected_options` (Freitext) und `pricing_snapshot` (JSON-Blob) ([app/javascript/application.js](/home/leo/dev/projects/zapfe-rails/app/javascript/application.js#L293), [app/javascript/application.js](/home/leo/dev/projects/zapfe-rails/app/javascript/application.js#L327)).
- Das erschwert Auswertung, Nachvollziehbarkeit, spätere Preislogik, Admin-Oberflächen und Integrationen.

Zusätzlich:

- Start-/Enddatum, Uhrzeiten und Lieferadresse sind im Formular keine echten `Inquiry`-Attribute, sondern lose Eingabefelder ohne klare Server-Semantik ([app/views/pages/calculator.html.erb](/home/leo/dev/projects/zapfe-rails/app/views/pages/calculator.html.erb#L42), [app/views/pages/calculator.html.erb](/home/leo/dev/projects/zapfe-rails/app/views/pages/calculator.html.erb#L90)).

Empfehlung:

- `Inquiry` um strukturierte Felder erweitern (`rental_mode`, `starts_on`, `ends_on`, `delivery_street`, `delivery_postcode`, `delivery_city`).
- Preisberechnung als explizites Domain-Objekt modellieren (z. B. `InquiryPricing`).

### 5. Event-Listener-Lifecycle ist nicht sauber und kann sich bei Navigation aufstauen

Datei: [app/javascript/application.js](/home/leo/dev/projects/zapfe-rails/app/javascript/application.js)

- In `initCalculatorPage` wird bei jedem Seitenbesuch ein globaler `resize`-Listener auf `window` registriert, ohne Cleanup ([app/javascript/application.js](/home/leo/dev/projects/zapfe-rails/app/javascript/application.js#L411)).
- Mit Turbo-Navigation fuehrt das mittelfristig zu mehrfach ausgefuehrter Logik und schwer nachvollziehbaren UI-Effekten.

Empfehlung:

- Lifecycle in Stimulus `connect`/`disconnect` kapseln.
- Globale Listener immer explizit deregistrieren.

### 6. Server-Tests geben teilweise ein truegerisches Signal

Dateien:

- [test/controllers/pages_controller_test.rb](/home/leo/dev/projects/zapfe-rails/test/controllers/pages_controller_test.rb)
- [app/controllers/pages_controller.rb](/home/leo/dev/projects/zapfe-rails/app/controllers/pages_controller.rb)

- Der Test "drinks supports query filtering" suggeriert serverseitiges Filtern, aber der Controller wertet `params[:q]` gar nicht aus ([app/controllers/pages_controller.rb](/home/leo/dev/projects/zapfe-rails/app/controllers/pages_controller.rb#L17)).
- Der Test besteht nur deshalb, weil auf ein bestimmtes Textmuster geprüft wird, nicht auf das tatsächliche Filterverhalten ([test/controllers/pages_controller_test.rb](/home/leo/dev/projects/zapfe-rails/test/controllers/pages_controller_test.rb#L35)).

Risiko:

- Das Test-Signal ist gruen, obwohl die beschriebene Funktionalitaet nicht serverseitig existiert.

Empfehlung:

- Tests enger am echten Verhalten ausrichten.
- JS-Interaktionen als Systemtests abdecken, Controller-Tests nicht mit irrefuehrenden Parametern aufladen.

## Architektur-Einschaetzung nach Schicht

### Routing und Controller

- Routing ist klar und klein gehalten ([config/routes.rb](/home/leo/dev/projects/zapfe-rails/config/routes.rb)).
- `PagesController` ist aktuell eher ein Presenter fuer statische Seiten und fuer das Volumen noch akzeptabel.
- Mittelfristig sollte aber alles, was nicht rein statisch ist (Produktlisting, Preislogik, SEO-Landingpages mit Datenbezug), aus dem Sammelcontroller herausgezogen werden.

### Modelle und Datenbank

- Die Kernmodelle sind klar geschnitten: `Category`, `Product`, `ProductVariant`, `Event`, `Inquiry`.
- Die DB-Struktur ist fuer einen MVP gut genug ([db/schema.rb](/home/leo/dev/projects/zapfe-rails/db/schema.rb)).
- Die groesste Luecke ist nicht Normalisierung im Produktbereich, sondern das untermodellierte Anfrage-/Pricing-Domainmodell.

### Mailer und Hintergrundverarbeitung

- `deliver_later` ist richtig eingesetzt ([app/controllers/inquiries_controller.rb](/home/leo/dev/projects/zapfe-rails/app/controllers/inquiries_controller.rb#L5)).
- Das Monitoring prueft Mailer-Rendering sinnvoll, ohne Daten anzulegen ([app/controllers/monitoring_controller.rb](/home/leo/dev/projects/zapfe-rails/app/controllers/monitoring_controller.rb#L14)).
- Der `ApplicationMailer`-Default (`from@example.com`) kollidiert konzeptionell mit dem spezifizierten Default im `InquiryMailer`; funktional ist das nicht akut kaputt, aber als Basiskonfiguration inkonsistent ([app/mailers/application_mailer.rb](/home/leo/dev/projects/zapfe-rails/app/mailers/application_mailer.rb#L2)).

### Views und Helper

- Der `ApplicationHelper` uebernimmt inzwischen SEO-Metadaten, Bild-Helfer und JSON-LD-Logik zentral. Das ist sinnvoll.
- Gleichzeitig waechst er zu einer Sammelstelle fuer alles, was "irgendwo hin muss" ([app/helpers/application_helper.rb](/home/leo/dev/projects/zapfe-rails/app/helpers/application_helper.rb)).
- Wenn weitere Landingpages hinzukommen, sollte SEO-/Schema-Logik in klarere Presenter oder Konfigurationsobjekte ausgelagert werden.

## Priorisierte Maßnahmen

### P1

- XSS-Risiko durch `innerHTML` entfernen.
- Cart- und Pricing-Logik in wiederverwendbare Module trennen.
- `Inquiry` fuer echte Preisrechner-Daten strukturieren.

### P2

- `application.js` in Stimulus-Controller aufbrechen.
- Event-Listener-Cleanup sauber implementieren.
- Irrefuehrende Tests korrigieren und Coverage auf kritische Rechenlogik verschieben.

### P3

- `PagesController` mittelfristig entlasten.
- SEO-/Structured-Data-Konfiguration von `ApplicationHelper` entkoppeln.
- Mailer-Basiskonfiguration konsolidieren.

## Empfohlene Zielarchitektur

- Rails bleibt serverseitig fuer Rendering, Persistenz und Mailfluss verantwortlich.
- Stimulus wird wieder das primaere Muster fuer page-lokale Interaktivitaet.
- Preisrechnerlogik wird als explizite Domain-Schicht modelliert, nicht als unstrukturierter Formular-Nebenkanal.
- Der Warenkorb bekommt genau eine Frontend-Implementierung und genau ein Datenformat.
