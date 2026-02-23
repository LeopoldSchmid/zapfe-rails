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
