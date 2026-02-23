# Nächste Schritte (offen)

## 1. Funktionsparität fertigstellen
- `Events`: Inhalte/Feinschliff finalisieren (UI + Text), falls nötig zusätzliche Felder im Admin ergänzen.
- `Kontakt`: optional FAQ-Bereich wie im Altprojekt wieder ergänzen (falls gewünscht).
- `Drinks/Calculator`: End-to-End UX manuell prüfen (Mobile + Desktop), insbesondere Variantenwahl, Warenkorb-Sync, Preisberechnung.
- `Rechtliches`: Impressum/Datenschutz final juristisch prüfen und ggf. Text anpassen.

## 2. Daten & Assets
- Produktbilder aus Supabase nach Active Storage synchronisieren:
  - Dry run: `bin/rails zapfe:sync_supabase_images`
  - Echtlauf: `DRY_RUN=false bin/rails zapfe:sync_supabase_images`
- Danach Stichprobe in `/drinks` und `/calculator` machen.

## 3. E-Mail-Funktionen testen (später)
- Status:
  - Versand über `/contact` und `/calculator` auf Staging manuell erfolgreich getestet.
  - Automatisierte Tests vorhanden:
    - `test/controllers/inquiries_controller_test.rb`
    - `test/mailers/inquiry_mailer_test.rb`
- Optional:
  - End-to-End Mail-Zustellung (Resend Dashboard + Spam-Ordner) periodisch prüfen.

## 4. Staging Deploy (Hetzner)
- DNS in der **autoritativen Zone** setzen:
  - `A staging.zapfe.duzend.net -> 157.180.19.232`
- Secrets exportieren:
  - `KAMAL_REGISTRY_PASSWORD`
  - `RAILS_MASTER_KEY` (aus `config/master.key` dieses Repos)
  - `SECRET_KEY_BASE`
  - `RESEND_API_KEY`
- Deploy:
  - `script/kamal_with_env setup -d staging`
  - `script/kamal_with_env deploy -d staging`
- Smoke-Test:
  - `/`, `/calculator`, `/drinks`, `/contact`, `/admin/login`

## 5. Cutover auf zapfe.jetzt (wenn bereit)
- `config/deploy.yml`:
  - `proxy.hosts` auf `zapfe.jetzt` (+ optional `www.zapfe.jetzt`) ändern.
  - `APP_HOST` auf `zapfe.jetzt` setzen.
- Neu deployen: `script/kamal_with_env deploy`
- DNS umstellen:
  - `@` und `www` von Netlify auf Hetzner-IP.
- Danach finaler Smoke-Test + Mail-Test.

## 6. Betrieb
- Regelmäßige Backups für `storage/` (SQLite + Active Storage).
- Optional Monitoring/Alerting ergänzen (Uptime + Fehlertracking).
