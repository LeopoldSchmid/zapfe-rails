# Testing

Stand: 2026-02-27

## Ziel
- Tests sollen lokal reproduzierbar laufen.
- Rails-Tests decken Businesslogik und Controller ab.
- Browser-nahe Flows werden mit Playwright abgesichert.
- Rails-Systemtests nutzen ebenfalls Playwright statt Selenium.

## Test-Arten im Projekt
- `bin/rails test`
  - Gesamte Rails-Test-Suite.
  - Umfasst aktuell Model-, Controller-, Mailer- und Systemtests.
- `bin/rails test test/system`
  - Rails-Systemtests.
  - Laufen browserbasiert ueber `capybara-playwright-driver`.
- `npx playwright test`
  - Eigenstaendige End-to-End-Tests aus `tests/`.
  - Startet standardmaessig selbst einen lokalen Rails-Testserver.

## Einmaliges Setup
```bash
bundle install
npm install
npx playwright install chromium
bin/rails db:prepare
```

Hinweise:
- `npx playwright install chromium` wird pro Rechner/Umgebung benoetigt, damit der Browser lokal verfuegbar ist.
- Die eigenstaendigen Playwright-Tests verwenden `RAILS_ENV=test`.

## Haefige Test-Kommandos
```bash
bin/rails test
bin/rails test test/system
bin/rails test test/system/calculator_toggle_test.rb
npx playwright test
npx playwright test tests/smoke.spec.ts
npm run test:e2e:headed
```

## Wie das Setup aktuell funktioniert

### Rails-Systemtests
- Konfiguration in `test/application_system_test_case.rb`.
- Driver: `:playwright`
- Browser: Chromium
- Headless standardmaessig aktiv.
- Fuer sichtbaren Browser lokal:

```bash
PLAYWRIGHT_HEADED=1 bin/rails test test/system
```

Das ersetzt bewusst das fruehere Selenium/Chromedriver-Setup, weil es lokal anfaelliger war.

### Eigenstaendige Playwright-Tests
- Konfiguration in `playwright.config.ts`.
- Testdateien liegen unter `tests/`.
- `playwright.config.ts` startet bei Bedarf selbst:

```bash
RAILS_ENV=test bin/rails db:prepare
RAILS_ENV=test bin/rails server -b 127.0.0.1 -p 3200
```

- `PLAYWRIGHT_SKIP_WEBSERVER=1` kann genutzt werden, wenn der Testserver bereits separat laeuft.
- `PLAYWRIGHT_PORT` erlaubt einen abweichenden lokalen Port.

Beispiel:
```bash
PLAYWRIGHT_SKIP_WEBSERVER=1 PLAYWRIGHT_PORT=3201 npx playwright test
```

## Konventionen fuer neue Tests

### Rails-Tests
- Businesslogik nicht nur ueber Views absichern, sondern bevorzugt in Models, Services oder Controller-Tests.
- Browserinteraktionen, die eng an servergerenderte UI gekoppelt sind, koennen in `test/system` liegen.
- Fuer DOM-Zugriffe stabile IDs oder klare, semantische Selektoren verwenden.

### Playwright-E2E
- Vollstaendige Nutzerfluesse mit echtem Browser in `tests/*.spec.ts`.
- Bevorzuge `getByRole`, `getByLabel`, `getByText` oder stabile IDs statt fragiler CSS-Ketten.
- Neue Specs sollten unabhaengig und lokal reproduzierbar sein.
- Wenn ein Test Auth oder spezielle Daten braucht, die Vorbereitung explizit im Test oder ueber klar dokumentierte Helpers machen.

## Debugging
- Sichtbarer Browser:
```bash
PLAYWRIGHT_HEADED=1 npx playwright test
```

- Playwright UI:
```bash
npm run test:e2e:ui
```

- Einzelne Rails-Systemtests:
```bash
bin/rails test test/system/<datei>_test.rb
```

- Einzelne Playwright-Spec:
```bash
npx playwright test tests/<datei>.spec.ts
```

## Typische Fehlerbilder
- `browser executable doesn't exist`
  - Loesung: `npx playwright install chromium`
- Port-Konflikt beim Playwright-Webserver
  - Loesung: `PLAYWRIGHT_PORT=3201 npx playwright test`
- Bereits laufender lokaler Server stoert den Test
  - Loesung: Entweder Server beenden oder mit `PLAYWRIGHT_SKIP_WEBSERVER=1` gezielt denselben Port verwenden.
- Versehentlich versionierte Test-Artefakte
  - Reports unter `playwright-report/` und `test-results/` sind nur lokal und gehoeren nicht in neue Commits.

## Erwartung bei Aenderungen
- Jede relevante Aenderung an Businesslogik mindestens mit Rails-Tests absichern.
- Bei UI- oder Flow-Aenderungen mindestens den betroffenen Systemtest oder die betroffene Playwright-Spec ausfuehren.
- Bei groesseren Eingriffen in zentrale Flows:
  - `bin/rails test`
  - `bin/rails test test/system`
  - `npx playwright test tests/smoke.spec.ts`
