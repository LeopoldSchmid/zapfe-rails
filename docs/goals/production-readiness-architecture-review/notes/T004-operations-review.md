# T004 – Produktionsbetrieb, Reliability und Recovery

Stand: 2026-07-16. Repository-basierter Review; Produktionsserver, Docker-
Volumes, DNS, Provider-Dashboards und reale Backups wurden nicht verändert oder
ausgelesen.

## Architektur des Betriebs

- Ein Kamal-Webserver auf `157.180.19.232`, TLS über Kamal Proxy.
- Rails/Puma und Solid Queue in demselben Container/Prozessverbund
  (`SOLID_QUEUE_IN_PUMA=true`).
- Vier SQLite-Dateien (primary/cache/queue/cable), Active Storage und sonstige
  Dateien gemeinsam auf einem einzigen lokalen Docker-Volume.
- Resend SMTP, Web Push, optionales self-hosted Umami; Uptime Kuma/Telegram laut
  externer Betriebsdokumentation.

## Bestätigte Befunde

### OPS-001 – Kein belegtes Backup-/Restore-System; Single Point of Failure (kritisch)

`config/deploy.yml`, `config/database.yml` und `config/storage.yml` legen
Geschäftsdaten, Queue, Cable, Cache und Uploads auf ein lokales Volume eines
einzelnen Hosts. Im Repository gibt es keinen automatisierten Backup-Plan, keine
Offsite-/immutable Kopie, Verschlüsselungs-/Retention-Regel, Restore-Probe,
RPO/RTO oder Alarm auf Backup-Fehler. Host-/Volume-Verlust kann daher alle
Kunden-, Auftrags-, PDF- und Dateidaten gleichzeitig vernichten.

Empfehlung: SQLite-konsistente Snapshots plus Active-Storage-Dateien, mindestens
eine verschlüsselte Offsite-Kopie, definierte RPO/RTO, tägliche Erfolgsalarme
und regelmäßig dokumentierter Restore in isolierter Umgebung. Cache/queue/cable
fachlich getrennt behandeln.

### OPS-002 – Produktionsersatz-Skript ist destruktiv, inkonsistent und ungetestet (kritisch)

`script/replace_prod_storage_from_staging` löscht ohne Bestätigung oder
Vorab-Backup den gesamten Produktions-Volume-Inhalt und kopiert danach Staging.
Es prüft weder Quelle, freien Platz, Integrität noch Vollständigkeit, bietet
keinen Rollback und verwendet im Remote-Block trotz konfigurierbarer Variablen
fest codierte Volume-Namen. Der im Repository sichtbare Zeilenumbruch in
`cp -a /\n from/. /to/` macht den Kopierbefehl zudem wahrscheinlich fehlerhaft –
nach bereits erfolgter Löschung. Das Skript darf nicht ausgeführt werden.

Empfehlung: entfernen/sperren oder in ein explizit bestätigtes, fail-safe
Recovery-Werkzeug mit Quell-/Zielprüfung, Snapshot, Prüfsummen, Maintenance,
atomarem Umschalten und Rollback umbauen; automatisiert gegen Wegwerf-Volumes
testen.

### OPS-003 – Fachstatus „versendet“ wird vor erfolgreicher Mailzustellung gesetzt (hoch)

`Offers::SendMail` und `Invoices::SendMail` setzen Status/Timestamp und Activity
innerhalb des Locks, bevor `deliver_later` tatsächlich SMTP erreicht. Ein
Queue-/SMTP-Fehler lässt das System daher „versendet“ anzeigen, obwohl keine Mail
ging. Es fehlen Zustände wie queued/delivered/failed, Idempotency-Key,
Wiederhol-/Reconciliation-Workflow und Bounce/Complaint-Verarbeitung.

Empfehlung: Outbox-/Delivery-Modell; erst erfolgreichen Provider-Handoff als
sent markieren, Message-ID/Fehler/Audit speichern, idempotent wiederholen und
Fehler sichtbar alarmieren.

### OPS-004 – Background Jobs haben keine explizite Retry-/Fehlerstrategie (hoch)

`ApplicationJob` enthält nur auskommentierte Beispiele. Push- und Mailjobs haben
keine abgestimmten `retry_on`/`discard_on`-Regeln oder Dead-letter-/Failed-job-
Überwachung. `DueTaskPushNotificationsJob` setzt `last_push_reminded_on` bereits
nach dem Enqueue; scheitern nachgelagerte Jobs, wird am selben Tag nicht erneut
erinnert. Netzwerkfehler im Web-Push-Service werden nicht klassifiziert.

Empfehlung: je Fehlerklasse begrenztes Backoff, Idempotenz, Failed-job-Alarm,
Requeue/Replay-Runbook und fachliche Zustandsübergänge nach Erfolg.

### OPS-005 – Monitoring deckt zentrale Abhängigkeiten nicht ab (hoch)

`/up` prüft im Wesentlichen Rails-Boot. `/monitoring/inquiry_flow` validiert ein
nicht gespeichertes Objekt und rendert Mails, testet aber weder DB-Schreiben,
Active Storage, Queue-Ausführung, SMTP-Handoff noch Resend-Zustellung. Es fehlen
belegte Metriken/Alarme für Queue-Alter/Fehler, Plattenplatz, SQLite-Integrität,
Backups, 5xx/Exceptions, Antwortzeiten, Zertifikat, Mail-Bounces und
Geschäftsfluss. Sentry ist nur als „nächster Ausbauschritt“ dokumentiert.

### OPS-006 – Logs/Incidents sind nicht produktionsreif operationalisiert (hoch)

Rails schreibt strukturarm auf STDOUT; zentrale Aggregation, Zugriffsschutz,
Retention, PII-Redaktion jenseits der Parameterfilter, Error Tracking,
Korrelation von Jobs/Mails und Alarmregeln sind nicht belegt. Es existiert kein
Incident-Runbook, On-call-Verantwortung, Eskalationsweg, Statuskommunikation,
Postmortem- oder DSGVO-Breach-Prozess. SEC-009 bestätigt zusätzlich explizite
PII im Spam-Log.

### OPS-007 – Migrationen laufen beim Web-Boot ohne belegte sichere Deploy-Strategie (mittel-hoch)

`bin/docker-entrypoint` führt bei jedem Serverstart `db:prepare` aus. Bei einem
einzigen SQLite-Volume und Rolling Deploy kann neuer Code/Migration neben altem
Code laufen; Rückwärtskompatibilität, Maintenance/Lock-Zeit, Backup vor Migration
und Rollback sind nicht dokumentiert. Hooks prüfen nach Boot nur eine
Beispielausgabe. Schema-Drift wurde in T001 bestätigt: `db/schema.rb` enthält
Tabellen ohne korrespondierende aktuelle Migrationen/Anwendungscode, wodurch ein
frischer Aufbau nicht zuverlässig dasselbe Schema belegt.

### OPS-008 – Ein Host und in-process Queue koppeln alle Ausfallarten (hoch)

Web, Jobs, vier SQLite-DBs, Dateien und Monitoring-Ziel liegen laut Konfiguration
weitgehend auf demselben Server. Web-Restart stoppt Queue-Verarbeitung; CPU/RAM-
oder Disk-Druck eines Jobs wirkt auf Requests. Es fehlen Ressourcenlimits,
Kapazitätsgrenzen, separate Worker-Liveness und Hochverfügbarkeit. Für den
aktuellen kleinen Umfang kann SQLite sinnvoll sein, aber nur mit bewusstem
Single-node-Betriebsmodell und getesteter Recovery.

### OPS-009 – Datenbank-/Datei-Härtung und Wartung sind nicht belegt (mittel-hoch)

SQLite-Foreign-Keys und viele fachliche Unique-Indizes sind positiv. Nicht
belegt sind jedoch `PRAGMA integrity_check`, WAL-/Checkpoint-/Vacuum-Strategie,
Disk-Füllstandsgrenzen, Korruptionsalarm, Verschlüsselung at rest, Upload-
Orphan-Purge sowie konsistente Sicherung zwischen DB-Referenzen und Dateien.
Alle Datenbanken und Uploads teilen einen Volume-/Disk-Budget.

### OPS-010 – Deployment-/Supply-Chain-Reproduzierbarkeit ist begrenzt (mittel)

Der Container läuft erfreulicherweise als UID 1000 und nutzt Multi-stage Build.
Das Base Image `ruby:3.4.5-slim` und apt-Pakete sind aber nicht per Digest/Version
fixiert; kein Image-/OS-Vulnerability-Scan, SBOM, Signatur/Provenance oder
automatisierter Post-deploy-Smoke/Rollback ist belegt. CI triggert Push nur auf
`master`, was dem verifizierten Origin-Default-Branch entspricht; eine
automatische, gate-gebundene Deployment-Pipeline ist dagegen nicht belegt.

### OPS-011 – Root-SSH und personenbezogene Pfade erschweren sichere Übergabe (mittel)

Kamal verbindet als `root`, und Deploy-/Recovery-Skripte enthalten einen
benutzerspezifischen privaten Key-Pfad. Least-privilege-Deploy-Account,
Schlüsselrotation, Host-Härtung, Firewall/Patch-Management und reproduzierbare
Operator-Übergabe sind nicht dokumentiert.

### OPS-012 – Verfügbarkeits-/Kapazitätsannahmen und SLO fehlen (mittel)

Keine SLO/SLI, Lastannahmen, Maximalgrößen für DB/Uploads, Performance-Baseline,
Lasttest, Queue-Latenzziel oder geplantes Wartungsfenster. Listen wie
Admin-Anfragen und Ressourcen können mit Datenwachstum vollständig geladen und
in Ruby weiterverarbeitet werden; T005 bewertet Code/Performance vertieft.

## Positive Feststellungen

- TLS, HSTS, Secure Cookies und non-root Runtime-Container sind eingerichtet.
- SQLite-Datenbanken sind getrennt nach primary/cache/queue/cable; Foreign Keys
  und zahlreiche Unique-/Suchindizes stärken Konsistenz.
- Solid Queue räumt fertige Jobs regelmäßig auf; Task-Reminder ist deklariert.
- Produktionsboot bricht bei fehlendem Resend-Key ab statt still falsch zu
  konfigurieren; Mailer-Fehler werden grundsätzlich nicht verschluckt.
- Staging verhindert explizit Kunden-Angebots-/Rechnungsversand.
- Uptime Kuma/Telegram und ein synthetischer Render-Check sind ein sinnvoller
  Anfang, ersetzen aber keine End-to-End- und Recovery-Signale.

## Priorisierte Betriebsmaßnahmen

1. Vor jedem weiteren Produktionsrisiko: destruktives Replace-Skript sperren;
   konsistentes Backup plus erfolgreichen Restore beweisen.
2. Vor Produktion: kritische Dependencies, Fehler-/Job-/Mailzustände,
   failed-job-/disk-/backup-/5xx-Alarme und Incident-Runbook.
3. Vor Migrationen: getrennten Migrationsschritt, Backup, Kompatibilitätsregel
   und getesteten Rollback etablieren; Schema reproduzierbar machen.
4. Zeitnah: zentrale datensparsame Logs/Error Tracking, SLOs, Kapazitäts- und
   SQLite-Wartungsplan, Least-privilege Deploy.
5. Später/bei Wachstum: Queue entkoppeln, Dateien off-host replizieren und
   Datenbank-/Host-HA anhand realer Last und RTO neu entscheiden.

## Nicht aus dem Repository verifizierbar

- Ob externe Hetzner-Snapshots/Backups, Restore-Tests oder Host Monitoring real
  existieren.
- Aktueller Disk-/RAM-/CPU-Zustand, Provider-Firewall, Patching und SSH-Policy.
- Uptime-Kuma-/Telegram-Konfiguration und tatsächliche Alarmzustellung.
- Resend-Bounces/Provider-Logs und tatsächliche Queue-Fehler.
- Reale Datenmenge, Traffic, RPO/RTO und Verfügbarkeitsanforderung.
