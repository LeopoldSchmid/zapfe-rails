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

## Admin Login
Der erste Admin wird per Seed erzeugt:
```bash
ADMIN_EMAIL=admin@zapfe.local ADMIN_PASSWORD=change-me-now bin/rails db:seed
```

Dann Login unter:
- `/admin/login`

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
Aktueller Deploy-Target ist `staging.zapfe.duzend.net` auf Hetzner.

DNS:
- `A staging.zapfe.duzend.net -> 157.180.19.232`

Benötigte Secrets in deiner Shell:
```bash
cp .kamal/deploy.env.example .kamal/deploy.env
# Werte in .kamal/deploy.env eintragen
set -a; source .kamal/deploy.env; set +a
```

Erstsetup und Deploy:
```bash
script/kamal_with_env setup -d staging
script/kamal_with_env deploy -d staging
```

Bequemer Wrapper (lädt `.kamal/deploy.env` automatisch):
```bash
script/kamal_with_env setup -d staging
script/kamal_with_env deploy -d staging
```

Späterer Cutover auf `zapfe.jetzt`:
1. `config/deploy.yml` `proxy.hosts` auf `zapfe.jetzt` und `www.zapfe.jetzt` erweitern.
2. `APP_HOST` auf `zapfe.jetzt` setzen.
3. DNS für `@` und `www` auf Hetzner-IP umstellen.
4. `script/kamal_with_env deploy -d staging`.
