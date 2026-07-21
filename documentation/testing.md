# Testing

Stand: 2026-07-16

## Ziel
- Tests sollen lokal reproduzierbar laufen.
- Rails-Tests decken Businesslogik und Controller ab.
- Browser-nahe Flows werden mit Playwright abgesichert.
- Rails-Systemtests nutzen ebenfalls Playwright statt Selenium.

## Test-Arten im Projekt
- `bin/rails test`
  - Gesamte Rails-Test-Suite.
  - Umfasst aktuell Model-, Controller-, Mailer- und Systemtests.
- `COVERAGE=1 bin/rails test`
  - Erzeugt den in CI archivierten Line-/Branch-Coverage-Trend unter `coverage/`.
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
- Die eigenstaendigen Playwright-Tests verwenden `RAILS_ENV=test` und eine
  separate Datenbank unter `storage/playwright.sqlite3`; sie verändern die
  Minitest-Datenbank nicht.
- Auf Arch- oder anderen nicht offiziell unterstuetzten Linux-Systemen kann Playwrights Host-Pruefung trotz funktionierendem Chromium fehlschlagen.
- In diesem Projekt laufen die E2E-Skripte deshalb mit `PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS=1` und explizit mit dem `chromium`-Projekt.

## Haefige Test-Kommandos
```bash
bin/rails test
COVERAGE=1 bin/rails test
bin/bundler-audit check
bin/brakeman --no-pager
bin/rubocop
bin/rails test test/scripts/production_storage_safety_test.rb
bin/rails test test/system
bin/rails test test/system/calculator_toggle_test.rb
npm run test:e2e
npm run test:e2e:local
PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS=1 npx playwright test tests/smoke.spec.ts --project=chromium
npm run test:e2e:headed
```

Der Storage-Safety-Test arbeitet ausschließlich in temporären Verzeichnissen.
Er belegt SQLite-Online-Backup, Dateisnapshot, Prüfsummen, Restore in ein leeres
Ziel, Ablehnung beschädigter Archive und die technische Sperre des ehemaligen
Staging-zu-Produktion-Skripts. Der reale verschlüsselte Offsite-Restore bleibt
ein separater Betreiber-Nachweis; siehe `documentation/backup_restore.md`.

Die verbindliche Release-Wahrheit ist `.github/workflows/ci.yml`: Ruby-/Importmap-
Security-Scans, RuboCop, Rails-Tests mit Coverage-Artefakt, Systemtests, ein kompletter
Migrationsaufbau sowie Produktionsimage-, Trivy- und SBOM-Gate. Lokale Einzeltests
ersetzen diese PR-Checks nicht.

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
DATABASE_URL=sqlite3:storage/playwright.sqlite3 RAILS_ENV=test bin/rails db:prepare
DATABASE_URL=sqlite3:storage/playwright.sqlite3 RAILS_ENV=test bin/rails server -b 127.0.0.1 -p 3200
```

- `PLAYWRIGHT_SKIP_WEBSERVER=1` kann genutzt werden, wenn der Testserver bereits separat laeuft.
- `PLAYWRIGHT_PORT` erlaubt einen abweichenden lokalen Port.
- `PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS=1` umgeht auf nicht offiziell unterstuetzten Distributionen die fehlerhafte Ubuntu-basierte Dependency-Pruefung.

Beispiel:
```bash
PLAYWRIGHT_SKIP_WEBSERVER=1 PLAYWRIGHT_PORT=3201 PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS=1 npx playwright test --project=chromium
```

Lokaler Audit gegen bereits laufende Dev-App auf `127.0.0.1:3001`:
```bash
npm run test:e2e:local
npm run test:e2e:local:headed
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
PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS=1 PLAYWRIGHT_HEADED=1 npx playwright test --project=chromium
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
PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS=1 npx playwright test tests/<datei>.spec.ts --project=chromium
```

## Typische Fehlerbilder
- `browser executable doesn't exist`
  - Loesung: `npx playwright install chromium`
- `Host system is missing dependencies` auf Arch oder anderer nicht offiziell unterstuetzter Distribution
  - Loesung: Chromium mit `ldd` pruefen und die Projekt-Skripte bzw. `PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS=1` mit `--project=chromium` verwenden.
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
