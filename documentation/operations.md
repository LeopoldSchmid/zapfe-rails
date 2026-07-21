# Produktionsbetrieb, Monitoring und Incidents

## Health- und Alarmmatrix

`GET /up` ist nur ein Boot-/Liveness-Signal. `POST /monitoring/deep` verlangt den
Monitoring-Token als `Authorization: Bearer …` oder `X-Monitoring-Token` und prüft
DB-Schreiben, Queue-DB, Cache, Storage-Schreiben/-Lesen/-Löschen und Mail-Rendering.
Tokens in Query-Parametern werden abgewiesen. Der bestehende Inquiry-Synthetic
prüft zusätzlich den Kernprozess.

Der externe Monitor muss mindestens alarmieren auf:

| Signal | Warnung | Kritisch |
| --- | --- | --- |
| Liveness | 2 Fehler/5 min | 5 min nicht erreichbar |
| Deep Health / Inquiry | 1 Fehler | 2 Fehler in Folge |
| Queue ältester Job | 2 min | 10 min |
| fehlgeschlagene Zustellungen | 1 in 15 min | 5 in 15 min |
| Platte belegt | 75 % | 85 % oder weniger als 2 Backup-Sätze frei |
| Backup-Alter | 26 h | 48 h |
| Fehlerquote HTTP 5xx | 1 %/5 min | 5 %/5 min |

Alarme brauchen eine Rufbereitschaft, Eskalationskontakt und einen monatlich
getesteten Zustellweg. Ohne externen Monitoring-Anbieter ist diese Matrix nur die
Konfiguration, noch kein belegter Alarm.

## Offsite-Backupzugang

Die Zapfe-Produktionssicherung verwendet eine eigene Storage-Box-Identität und
einen eigenen Remoteordner; keine private SSH-Identität und kein geteilter
Anwendungszugang dürfen dafür verwendet werden. Der aktuelle Zielhost ist in
`documentation/backup_restore.md` dokumentiert. Vor Livebetrieb muss der
Betreiber den nur für Backups bestimmten Schlüssel im Secret Manager hinterlegen,
die Server-Host-Identität aus einer vertrauenswürdigen Quelle in `known_hosts`
prüfen und einen echten verschlüsselten Upload mit isoliertem Restore belegen.

## Datenschutzarme Logs

Keine Mailadresse, Telefonnummer, Anschrift, Nachrichtentexte, Dokumentinhalte,
Tokens oder rohe Exceptions zentral erfassen. Fehler werden durch Klasse,
interne Objekt-ID und SHA-256-Digest korreliert. Zugriff ist rollenbasiert; die
Standardaufbewahrung beträgt 30 Tage, Security-Events gemäß dokumentierter
Retention. Exporte in Tickets oder Chat sind zu schwärzen.

## Job- und Zustellfehler

Dokument- und Push-Zustellungen besitzen persistente Outbox-Zustände und
idempotente Jobs. `failed`-Einträge werden alarmiert, fachlich geprüft und erst
danach erneut eingereiht. Vor Replay prüfen: Dokument-Prüfsumme, Empfänger,
Providerstatus und ob bereits `delivered` vorliegt. Niemals durch direktes Setzen
des Erfolgsstatus reparieren.

## SQLite-Wartung

- Täglich read-only: `bin/rails operations:sqlite_check`.
- Wöchentlich im Wartungsfenster und nach Backup:
  `CONFIRM_SQLITE_MAINTENANCE=1 bin/rails operations:sqlite_checkpoint`.
- `VACUUM` nur bei relevantem Freelist-Anteil, nach verifiziertem Backup, mit
  gestoppten Web-/Job-Schreibzugriffen:
  `CONFIRM_SQLITE_MAINTENANCE=1 bin/rails operations:sqlite_vacuum`.
- Die Tasks verweigern mutierende Wartung bei zu wenig freiem Platz. DB und Dateien
  werden weiterhin nur als gemeinsamer Backup-Satz gesichert.

## Incident und Datenschutzverletzung

Incident eröffnen, Zeitpunkt/Scope festhalten, Beweise schreibgeschützt sichern,
Secrets rotieren, Auswirkung begrenzen und Wiederherstellung dokumentieren. Bei
Personenbezug sofort den Ablauf in `documentation/privacy_breach_runbook.md`
starten; die 72-Stunden-Frist ist ein Entscheidungs- und Dokumentationsprozess,
kein automatisches Warten bis zum Fristende.

## SLO und Kapazitätsgrenzen

Startziel pro Kalendermonat: 99,5 % erfolgreiche Kernprozess-Verfügbarkeit,
p95 Serverantwort unter 500 ms für öffentliche HTML-Requests und unter 1 s für
Admin-Listen, 99 % Queue-Start innerhalb 2 Minuten sowie 99 % Zustellversuche
innerhalb 10 Minuten. Geplante Wartung zählt zur Nichtverfügbarkeit.

Bis ein repräsentativer Lasttest höhere Grenzen belegt, gilt als konservatives
Betriebsbudget: 100 gleichzeitige Sessions, 10 Jobs/s kurzzeitig, maximal 10 GB je
SQLite-Datei, 70 % dauerhaft belegter Plattenplatz und 25 MB je Upload. Bei 70 %
einer Grenze Kapazitätsreview auslösen; bei 85 % Schreiblast reduzieren und
skalieren. Diese Annahmen sind vor Go-live mit realem Datenmix zu messen.

## Container-Lieferkette

Das Ruby-Base-Image ist für `linux/amd64` per Digest fixiert. Dependabot oder ein
monatlicher Wartungs-PR aktualisiert Tag und Digest gemeinsam; CI baut danach das
Produktionsimage, blockiert bekannte ungefixte kritische/hohe Befunde nicht, wohl
aber alle behebbaren kritischen/hohen Befunde, und archiviert eine CycloneDX-SBOM.
APT-Pakete werden bewusst aus dem im Base-Image konfigurierten Debian-Repository
bezogen und durch den fertigen Image-Scan kontrolliert.

Eine Registry-Signatur und Build-Provenance benötigen einen organisationsgebundenen
Registry-/OIDC-Trust und sind vor Go-live extern einzurichten. Ohne verifizierbaren
Trust-Root darf eine bloß lokal erzeugte Signatur nicht als Freigabenachweis gelten.
