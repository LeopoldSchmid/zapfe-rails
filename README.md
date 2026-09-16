# Zapfe Rails

Rails 8.1.2 Rewrite von Zapfe mit Fokus auf einfache Infrastruktur und wartbaren Standard-Stack.

## Stack
- Rails 8.1.2
- Hotwire (Turbo + Stimulus)
- Tailwind CSS
- SQLite3
- Active Storage (Disk)
- Action Mailer (Resend SMTP)

## Lokal starten
```bash
cp .env.example .env
bin/rails db:prepare
bin/rails db:seed
bin/dev
```

## Testing
Setup und Konventionen stehen in:
- `documentation/testing.md`

Wichtige Kommandos:
```bash
bin/rails test
bin/rails test test/system
npx playwright test
```

## Admin Login
Die drei internen Konten werden per Seed erzeugt. Passwörter nur über die Umgebung setzen:
```bash
LEOPOLD_ADMIN_PASSWORD='...' \
DENNIS_ADMIN_PASSWORD='...' \
JOHANNES_ADMIN_PASSWORD='...' \
bin/rails db:seed
```

Dann Login unter:
- `/admin/login`
- im Produktions-Test: `https://zapfe.jetzt/admin` (nicht eingeloggte Personen werden zum Login weitergeleitet)

## Öffentliche Seiten
- `/`
- `/events`
- `/drinks`
- `/calculator`
- `/contact`
- `/impressum`
- `/datenschutz`

## Notizen
- Kalkulator ist initial ohne Geo-/Distanzberechnung.
- Anfragen werden gespeichert (`inquiries`) und per Mail verschickt.

## Legacy Import
Produkte/Varianten aus dem alten Projekt importieren:
```bash
bin/rails zapfe:import_legacy_products
```
Optional mit eigener Quelle:
```bash
SOURCE=/pfad/zur/datei.txt bin/rails zapfe:import_legacy_products
```

Event-Beispiele aus Altprojekt einspielen:
```bash
bin/rails zapfe:import_legacy_event_samples
```

Produktbilder aus Supabase-Bucket in Active Storage syncen (zuerst Dry-Run):
```bash
bin/rails zapfe:sync_supabase_images
```
Echter Import:
```bash
DRY_RUN=false bin/rails zapfe:sync_supabase_images
```
Falls nötig mit expliziter Altprojekt-Env-Datei:
```bash
SOURCE_ENV=/home/leo/dev/projects/zapfe/.env DRY_RUN=false bin/rails zapfe:sync_supabase_images
```

## Mobile Referenz-Screenshots
Die Vergleichsbilder liegen unter:
- `documentation/Screenshots_old_website`

## Deploy (Kamal)
`zapfe.intern` ist der Name der Anwendung/PWA, keine zusätzliche Host-Adresse.
Für den Kollegentest ist der Produktionspfad `https://zapfe.jetzt` mit dem
Admin-Einstieg `https://zapfe.jetzt/admin` vorgesehen. Staging bleibt unter
`staging.zapfe.duzend.net` als separater Vorabtest verfügbar.

DNS:
- `A staging.zapfe.duzend.net -> 157.180.19.232`

Benötigte Secrets in deiner Shell:
```bash
cp .kamal/deploy.env.example .kamal/deploy.env
# Werte in .kamal/deploy.env eintragen
set -a; source .kamal/deploy.env; set +a
```

Für PWA-Push einmalig VAPID-Schlüssel erzeugen und **nur** in `.kamal/deploy.env` hinterlegen:
```bash
bin/rails push:vapid_keys
```
Die drei ausgegebenen Werte `VAPID_PUBLIC_KEY`, `VAPID_PRIVATE_KEY` und `VAPID_SUBJECT` gehören in `.kamal/deploy.env`. In `.kamal/secrets.staging` stehen nur die Verweise `NAME=$NAME`. `.env` bleibt ausschließlich für die lokale Rails-Entwicklung.

Staging-Erstsetup und -Deploy:
```bash
script/kamal_with_env setup -d staging
script/kamal_with_env deploy -d staging
```

Bequemer Wrapper (lädt `.kamal/deploy.env` automatisch):
```bash
script/kamal_with_env setup -d staging
script/kamal_with_env deploy -d staging
```

Produktionsdeploy für den Kollegentest, nachdem DNS, Hostzugang, Backup,
Migration und Freigaben geprüft sind. `setup` nur beim erstmaligen Einrichten
des Hosts ausführen:
```bash
script/kamal_with_env deploy
```
Beim erstmaligen Einrichten stattdessen zuerst `script/kamal_with_env setup`
ausführen und danach den in `documentation/deployment.md` beschriebenen
expliziten Migrationsschritt durchführen.

Die Werte `MONITORING_TOKEN` sowie die drei `*_ADMIN_PASSWORD` werden nur über
`.kamal/deploy.env` beziehungsweise den Secret-Store gesetzt. Nach dem
expliziten Migrationsschritt wird der Seed einmalig im Produktionscontainer
ausgeführt:
```bash
script/kamal_with_env app exec --roles web --reuse "bin/rails db:seed"
```
Danach die drei Bootstrap-Passwörter aus dem Secret-Store entfernen. Die
persönlichen Konten bleiben bestehen; spätere Deploys benötigen keine
Bootstrap-Passwörter mehr.
