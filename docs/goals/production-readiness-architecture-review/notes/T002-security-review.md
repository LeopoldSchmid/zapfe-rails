# T002 – Security-Review

## Methode und Scanner

- Manuelle Prüfung von Authentifizierung, Autorisierung, Sessions,
  Passwort-Reset, Parameterhandling, Uploads/Downloads, Rich Text, CSP,
  Security Header, Secrets, Monitoring, Push, Jobs und Deployment.
- `bundle exec brakeman --no-pager --format text --no-exit-on-warn --no-exit-on-error`
  lief vollständig: 37 Controller, 43 Modelle, 122 Templates, 79 Checks,
  0 Fehler, 1 Medium-Warnung zu `permit!` in der Anti-Spam-Hilfsmethode.
- `bin/importmap audit` lief grün: keine verwundbaren Importmap-Pakete gefunden.
- `bundle exec bundler-audit check --database /tmp/zapfe-ruby-advisory-db
  --update --config config/bundler-audit.yml` verwendete die am 2026-07-15
  aktualisierte Advisory-Datenbank (Commit
  `32a64d01964828d2f71ba17fb623a73142e03a3d`) und meldete verwundbare Gems.
- Produktions-Rack-Smoke-Test bestätigte für `/admin/login`: TLS/HSTS,
  `Secure`, `HttpOnly`, `SameSite=Lax`, CSP, `X-Frame-Options: SAMEORIGIN`,
  `X-Content-Type-Options: nosniff` und `Referrer-Policy:
  strict-origin-when-cross-origin`.
- Ein Model-Probe bestätigte, dass ein ein Zeichen langes Admin-Passwort gültig ist.

## Bestätigte Findings

### SEC-001 – Bekannte Schwachstellen in produktiven Runtime-Abhängigkeiten

- Priorität: **kritisch / sofort vor weiterer Produktionseinführung**
- Wahrscheinlichkeit: hoch (öffentlich erreichbarer Rails/Rack-Stack)
- Auswirkung: je nach Advisory Session-Fälschung, Stored XSS, Datei-/Pfadzugriff,
  unbeabsichtigte statische Dateifreigabe sowie CPU-/Speicher-DoS.
- Evidenz: `Gemfile.lock`; aktueller Bundler-Audit gegen Advisory-DB vom
  2026-07-15 schlägt fehl.
- Besonders produktionsrelevant:
  - Rails/Action Pack/Action View/Active Storage/Active Support `8.1.2` →
    mindestens `8.1.2.1`
  - Rack `3.2.5` → mindestens `3.2.6`
  - Rack Session `2.1.1` → mindestens `2.1.2`
  - Puma `7.2.0` → mindestens `7.2.1` oder `8.0.2`
  - ActionText/Trix `2.1.16` → mindestens `2.1.18`
  - Loofah `2.25.0` → mindestens `2.25.1`
  - Nokogiri `1.19.1` → mindestens `1.19.4`
  - weitere Treffer: `addressable`, `crass`, `erb`, `json`, `msgpack`,
    `concurrent-ruby`, `sqlite3`, `websocket-driver`, `net-imap` und `bcrypt`.
- Einordnung: Nicht jeder transitive Treffer ist über die aktuelle Anwendung
  ausnutzbar (z. B. JRuby- oder ungenutzte IMAP-Pfade). Die unmittelbar im
  Request-, Session-, Upload- und Rich-Text-Pfad liegenden Rails/Rack/
  Active-Storage/Trix-Treffer sind jedoch direkt relevant. Der Gate-Fehlschlag
  allein blockiert einen belastbaren Produktionsfreigabe-Status.
- Empfehlung: Abhängigkeiten kontrolliert auf gepatchte Versionen aktualisieren,
  Lockfile erneut auditieren, vollständige Tests ausführen und die Advisory-Liste
  einzeln auf Restrelevanz prüfen. Keine CVE pauschal ignorieren.
- Verifikation: Bundler Audit, Brakeman, Rails-/System-/E2E-Suite komplett grün.

### SEC-002 – Alle Admin-Konten besitzen faktisch Vollzugriff

- Priorität: **hoch / vor Produktion**
- Wahrscheinlichkeit: mittel
- Auswirkung: Ein kompromittiertes oder unpassend vergebenes internes Konto kann
  weitere Konten inklusive Passwörtern ändern, Konten deaktivieren,
  Systemeinstellungen und Finanzdaten bearbeiten, Dokumente herunterladen und
  geschäftskritische Zustände verändern.
- Evidenz: alle Admin-Controller erben lediglich `Admin::BaseController` mit
  `require_admin!` (`app/controllers/admin/base_controller.rb:1-4`).
  `Admin::AdminUsersController` erlaubt jedem angemeldeten Admin Änderungen an
  `password`, `active`, E-Mail und Signatur anderer Konten
  (`app/controllers/admin/admin_users_controller.rb:25-43`).
- Empfehlung: Mindestens Rollen `owner/admin` und `member` oder explizite
  Policy-Regeln für Konten, Systemeinstellungen, Finanz-/Dokumentenaktionen und
  destruktive Vorgänge. Rechte serverseitig prüfen; UI-Ausblendung genügt nicht.
- Verifikation: negative Controller-/Policy-Tests je privilegierter Aktion.

### SEC-003 – Keine Mindest-Passwortstärke und keine MFA für den Internet-Admin

- Priorität: **hoch / vor Produktion**
- Wahrscheinlichkeit: mittel bis hoch
- Auswirkung: Kontoübernahme durch schwache oder wiederverwendete Passwörter;
  danach Vollzugriff gemäß SEC-002.
- Evidenz: `AdminUser` nutzt `has_secure_password`, besitzt aber keine
  Mindestlängen- oder Komplexitätsprüfung (`app/models/admin_user.rb:1-19`). Eine
  read-only Validierungsprobe mit Passwort `x` ergab `valid: true`. MFA/WebAuthn
  ist im Auth-Pfad nicht vorhanden.
- Positiv: bcrypt-Hashing, normalisierte eindeutige E-Mail, Login-Rate-Limit und
  generische Reset-Antwort sind vorhanden.
- Empfehlung: lange Passphrasen erzwingen (mindestens 12 Zeichen als
  Ausgangspunkt), kompromittierte Passwörter verhindern und für interne Konten
  WebAuthn/Passkeys oder TOTP einführen. Bootstrap-/Testpasswörter klar trennen.
- Verifikation: Model-/Controller-Tests und realer MFA-Login-/Recovery-Test.

### SEC-004 – Bestehende Sessions werden nach Passwortänderung nicht widerrufen

- Priorität: **hoch / vor Produktion**
- Wahrscheinlichkeit: mittel
- Auswirkung: Eine gestohlene Session bleibt nach Passwort-Reset oder
  administrativer Passwortänderung gültig. Es gibt außerdem keine belegte
  absolute oder Idle-Session-Laufzeit.
- Evidenz: Cookie-Session enthält nur `admin_user_id`
  (`app/controllers/application_controller.rb:13-16`); Passwort-Update ändert
  keinen Session-/Credential-Version-Zähler
  (`app/controllers/admin/passwords_controller.rb:19-25`,
  `app/controllers/admin/admin_users_controller.rb:25-28`). Login setzt die ID,
  ohne explizit `reset_session` aufzurufen
  (`app/controllers/admin/sessions_controller.rb:11-20`).
- Empfehlung: `session_version`/`credentials_changed_at` serverseitig prüfen,
  alle Sessions nach Passwort-/Rollenänderung widerrufen, Session bei Login
  rotieren und absolute/Idle-Laufzeit definieren. Deaktivierung wird bereits bei
  jedem Request über `AdminUser.active` wirksam.
- Verifikation: Integrationstest mit alter Session vor/nach Passwortwechsel.

### SEC-005 – Passwort-Reset kann ungebremst Mail und Queue belasten

- Priorität: **mittel / vor Produktion**
- Wahrscheinlichkeit: hoch bei öffentlichem Endpoint
- Auswirkung: E-Mail-Belästigung, Resend-Kosten/Quotenverbrauch und Queue-Last.
- Evidenz: `POST /admin/password/reset` ist öffentlich; `create` besitzt weder
  Rate-Limit noch Cooldown (`config/routes.rb:25-28`,
  `app/controllers/admin/passwords_controller.rb:8-14`).
- Empfehlung: IP- und konto-/E-Mail-basierte Limits, kurzer Cooldown,
  missbrauchssichere Telemetrie und gegebenenfalls CAPTCHA erst nach
  risikobasiertem Trigger.
- Verifikation: Controller-Tests für Burst und per-account Cooldown.

### SEC-006 – Upload-Schutz ist uneinheitlich und vertraut Client-MIME

- Priorität: **mittel bis hoch / vor Produktion**
- Wahrscheinlichkeit: mittel (Adminzugriff erforderlich; Kontoübernahme erhöht sie)
- Auswirkung: Speicher-DoS, gefährliche oder falsch klassifizierte Inhalte,
  Malware-Verteilung an Teammitglieder sowie Angriffsfläche in Parsern und
  Active Storage.
- Evidenz:
  - Inquiry/Order/Procurement prüfen 25 MB und `content_type`, aber keine
    Magic-Byte-/Inhaltsprüfung (`app/models/inquiry.rb:83-87`,
    `app/models/order.rb:59-63`, `app/models/procurement_plan.rb:27-31`).
  - Help-Screenshots prüfen nur MIME, nicht Größe
    (`app/models/help_request.rb:14-19`).
  - Checklist-Template/Checklist-Item, Product und Event besitzen Attachments
    ohne sichtbare Model-Limits (`app/models/checklist_template_item.rb:1-6`,
    `app/models/order_checklist_item.rb:1-15`, `app/models/product.rb:1-10`,
    `app/models/event.rb:1-6`).
  - Downloads werden korrekt über authentifizierte, parent-gescopte Controller
    und `Content-Disposition: attachment` ausgeliefert; `nosniff` ist aktiv.
- Empfehlung: zentrale Attachment-Policy mit Größenlimit, erlaubten
  tatsächlichen Dateisignaturen, Bilddekodierung/Re-Encoding, PDF-Prüfung,
  optional Malware-Scan/Quarantäne und expliziter Download-Policy. Gepatchtes
  Active Storage aus SEC-001 ist Voraussetzung.
- Verifikation: Tests mit falschem MIME, Polyglot, Oversize, ungültigem Bild/PDF
  und direktem Blob-Zugriff ohne Auth.

### SEC-007 – Monitoring-Secret wird als Query-Parameter transportiert

- Priorität: **mittel / vor Produktion**
- Wahrscheinlichkeit: mittel
- Auswirkung: Token kann in Proxy-/Uptime-/Browser-Logs, Exporten, Verlauf oder
  Referer-Daten landen; ein Besitzer kann den internen Synthetic-Check auslösen.
- Evidenz: `/monitoring/inquiry_flow?token=...`
  (`documentation/archive/monitoring.md:29-42`,
  `app/controllers/monitoring_controller.rb:31-36`). Secure Compare und
  Blank-Secret-Fail-Closed sind positiv.
- Empfehlung: Token in `Authorization: Bearer` oder einem dedizierten Header
  senden, Logs redigieren, Rotation dokumentieren und Endpoint zusätzlich am
  Proxy begrenzen, soweit praktikabel.
- Verifikation: kein Token in Access-/App-/Monitoring-Logs; alter Token nach
  Rotation ungültig.

### SEC-008 – CSP ist aktiv, aber als XSS-Barriere zu breit

- Priorität: **mittel / zeitnah**
- Wahrscheinlichkeit: mittel
- Auswirkung: Bei einer HTML-Injection dürfen Skripte von jeder HTTPS-Domain
  und Inline-Styles ausgeführt werden; die CSP reduziert den Blast Radius daher
  weniger als möglich.
- Evidenz: `script-src 'self' https:` und `style-src 'self' https:
  'unsafe-inline'` (`config/initializers/content_security_policy.rb:8-23`);
  Produktions-Header-Smoke-Test bestätigt die effektive Policy.
- Empfehlung: `script-src` auf `self`, Nonce und konkret erforderliche
  Analytics-Origin beschränken; `default-src` nicht pauschal um `https:`
  erweitern; Umami mit `connect-src`/konkreter Script-Origin abbilden;
  `style-src` schrittweise härten. Zunächst Report-Only beobachten.
- Verifikation: CSP-Report-Only ohne legitime Verstöße, danach Enforcement und
  Browser-Smoke-Test.

### SEC-009 – Spam-Logging umgeht die zentrale PII-Filterung

- Priorität: **mittel / vor Produktion**
- Wahrscheinlichkeit: hoch
- Auswirkung: E-Mail, IP und User-Agent blockierter Anfragen gelangen explizit
  in Logs und können dort länger/weiter als nötig gespeichert werden.
- Evidenz: manuelle String-Interpolation in
  `app/controllers/inquiries_controller.rb:26-30`; der Parameterfilter in
  `config/initializers/filter_parameter_logging.rb:6-28` greift auf diese
  bereits gebaute Logzeile nicht mehr.
- Empfehlung: E-Mail entfernen oder hashen, IP nur gekürzt/risikobasiert
  speichern, strukturierte Security-Events mit kurzer Aufbewahrung nutzen und
  Logzugriff/Rotation definieren.
- Verifikation: Test-/Staging-Log enthält keine direkte E-Mail oder volle IP.

### SEC-010 – Security-Ereignisse und Kontenänderungen sind nicht auditierbar

- Priorität: **mittel / vor Produktion**
- Wahrscheinlichkeit: hoch (Ereignisse treten sicher auf)
- Auswirkung: Kontoübernahmen, Rechte-/Passwortänderungen und fehlgeschlagene
  Logins lassen sich nur eingeschränkt untersuchen; Verantwortlichkeit für
  sicherheitskritische Änderungen fehlt.
- Evidenz: `Activity` wird für viele Geschäftsvorgänge genutzt, nicht jedoch für
  Login/Logout, Reset, Konten-/Rollenänderung oder Systemeinstellungen. Es gibt
  kein zentrales Security-Event-Modell beziehungsweise externes Audit-Logging.
- Empfehlung: manipulationserschwerte Security-/Admin-Audit-Events mit Actor,
  Zeitpunkt, Request-ID, Aktion und minimal erforderlichem Kontext; keine
  Passwörter/Tokens/unnötige PII. Alarmierung für auffällige Login-/Reset-Muster.
- Verifikation: definierte Ereignismatrix und Incident-Walkthrough.

### SEC-011 – Host- und Browser-Capability-Härtung ist unvollständig

- Priorität: **niedrig bis mittel / zeitnah**
- Wahrscheinlichkeit: niedrig bis mittel hinter Kamal-Proxy
- Auswirkung: zusätzliche Angriffsfläche bei Proxy-Fehlkonfiguration und mehr
  Browser-Capabilities als benötigt.
- Evidenz: `config.hosts` bleibt leer
  (`config/environments/production.rb:91-98`); Produktions-Smoke-Test liefert
  keine `Permissions-Policy`. Deploy-Proxy besitzt konkrete Hosts, was das
  Host-Risiko reduziert.
- Empfehlung: Rails-Host-Allowlist für Produktiv-/Staging-Domains sowie minimale
  Permissions-Policy (z. B. Kamera, Mikrofon, Geolocation deaktivieren, falls
  nicht benötigt). Proxy-Forwarded-Header-Vertrauen nach Rack-Patches prüfen.
- Verifikation: falscher Host wird abgewiesen; Header-Smoke-Test.

### SEC-012 – Admin-Service-Worker kontrolliert den gesamten Origin

- Priorität: **niedrig / später**
- Wahrscheinlichkeit: niedrig
- Auswirkung: Die aktuelle Fetch-Logik ist sicher begrenzt, aber eine spätere
  Änderung könnte unbeabsichtigt öffentliche Seiten oder Loginantworten cachen.
- Evidenz: Registrierung unter `/service-worker.js` erzeugt Scope `/`
  (`app/javascript/controllers/pwa_controller.js:7-10`), obwohl Manifest und
  Produktzweck auf `/admin/` begrenzt sind. Der aktuelle Worker cached
  ausdrücklich nur das Manifest (`app/views/pwa/service_worker.js.erb:16-23`).
- Empfehlung: Worker unter `/admin/service-worker.js` mit Scope `/admin/`
  ausliefern oder die globale Scope-Entscheidung als Security-Invariante testen.
- Verifikation: `registration.scope` und Cache-Inhalt im Browser-Test.

## Privacy-/Security-Übergabepunkt

Push-Nachrichten enthalten aktuell Kundenname und Aufgabentitel
(`app/jobs/due_task_push_notifications_job.rb:13-16`,
`app/controllers/admin/tasks_controller.rb:56-61`). Das kann auf Sperrbildschirm,
Browseranbieter-Infrastruktur oder fremd eingesehenem Gerät sichtbar werden.
Die technische Zustellung ist erwartungsgemäß verschlüsselt; die
Datenminimierung und Geräte-/Offboarding-Regeln werden in T003 bewertet.

## Kein bestätigter Befund / positiv

- Keine Brakeman-Hinweise auf SQL Injection, RCE, Template Injection oder
  bestätigtes XSS im Anwendungscode.
- Die Brakeman-`permit!`-Warnung betrifft `raw_inquiry_params`, das nur für
  Spamfelder/Logging/Message-Verifier verwendet und nicht massenweise einem
  Model zugewiesen wird. Es bleibt unnötig breit, ist aber im aktuellen Pfad
  keine bestätigte Mass-Assignment-Lücke.
- Views escapen normale Nutzertexte; Rich Text läuft über Action Text/Lexxy.
- Admin-Downloads werden über Parent-Beziehungen gescopet.
- Secrets-Dateien enthalten im Git-Stand Referenzen, keine erkannten Rohsecrets;
  `.env*`, `config/*.key` und `.kamal/deploy.env` sind ignoriert.
- CSRF ist auf der App aktiv; `PwaController` überspringt Forgery Protection nur
  für read-only Manifest/Service-Worker-Routen.
- Passwort-Reset-Antwort vermeidet Konto-Enumeration; Token läuft nach 30
  Minuten ab und wird durch Passwortänderung invalidiert.
- TLS-/Cookie-/HSTS-/Clickjacking-/MIME-Schutz war im lokalen Produktions-Rack-
  Smoke-Test aktiv.

## Tooling-Hinweis

`bin/brakeman` erzwingt `--ensure-latest`. Mit der gelockten Version 8.0.2
beendete der Wrapper den Lauf lediglich mit „not latest“ und Exit 5; der
eigentliche Scan musste über `bundle exec brakeman` ausgeführt werden. Das ist
fail-closed, aber der lokale/CI-Gate ist aktuell rot und liefert ohne Umgehung
keine Analyse. Nach dem Dependency-Update muss der normale `bin/brakeman`-Pfad
wieder vollständig grün laufen.
