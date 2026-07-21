# Sicherer Deployment- und Migrationsablauf

## Rollen und Grenzen

Kamal startet `web` und `job` als getrennte Container. Ein Web-Restart beendet
damit nicht mehr den Queue-Worker. Beide Rollen sowie SQLite und Active Storage
liegen weiterhin auf demselben Host und Volume. Das ist eine bewusst akzeptierte
Single-Node-Grenze, keine Hochverfügbarkeit.

Der Container startet niemals automatisch Migrationen. Beim Web-Start führt der
Entrypoint `db:abort_if_pending_migrations` aus und bricht bei ausstehenden
Migrationen ab. Ein Release benötigt daher einen expliziten Migrationsschritt.

## Release-Checkliste

1. CI inklusive Tests, Brakeman, Dependency-, Image- und SBOM-Prüfung muss grün sein.
2. Wartungsfenster ankündigen und Queue-Zufluss bei nicht rückwärtskompatiblen
   Änderungen stoppen.
3. Einen verschlüsselten, konsistenten DB-/Datei-Backup-Satz nach
   `documentation/backup_restore.md` erstellen und dessen Prüfsummen verifizieren.
4. Das neue Image bauen und in die Registry pushen, aber noch keinen Traffic
   umschalten.
5. Migration genau einmal in einem kurzlebigen Container des neuen Images mit
   demselben Storage-Volume und denselben Produktions-Secrets ausführen:
   `bin/rails db:prepare`. Der konkrete Kamal-Befehl ist vor Automatisierung in
   Staging gegen die eingesetzte Kamal-Version zu testen.
6. Migrationsergebnis und `bin/rails db:abort_if_pending_migrations` prüfen.
7. Web- und Job-Rolle deployen. Danach `/up`, den authentisierten Deep-Health-Check,
   einen Inquiry-Synthetic sowie Queue- und Mail-Outbox prüfen.
8. Fehlerquote, Queue-Latenz, freien Plattenplatz und Zustellfehler mindestens
   30 Minuten beobachten.

## Migrationsregeln

- Schemaänderungen müssen expand/contract folgen: zuerst additive, kompatible
  Änderung; Daten getrennt backfillen; alte Spalte frühestens in einem späteren
  Release entfernen.
- Lange Tabellen-Rewrites und unbeschränkte Backfills sind im Release-Schritt
  verboten. Sie benötigen ein getestetes Batch-Skript und ein Wartungsfenster.
- Eine fehlgeschlagene Migration stoppt den Release. Web wird nicht mit teilweise
  migriertem Schema gestartet.
- `db:rollback` ist kein allgemeiner Notausgang. Bei destruktiven oder bereits
  verwendeten Änderungen wird vorwärts repariert oder der vollständige konsistente
  Backup-Satz in einer isolierten Umgebung wiederhergestellt.

## Rollback

Bei reinem Anwendungscode wird auf das vorige Image zurückgeschaltet, sofern das
Schema rückwärtskompatibel ist. Nach einer inkompatiblen Datenänderung darf kein
altes Image gestartet werden. Dann Traffic stoppen, Incident eröffnen und anhand
des vorab getesteten Plans vorwärts reparieren oder DB und Dateien gemeinsam aus
dem Backup wiederherstellen.

## Noch extern einzurichten

- Dedizierter Unix-Benutzer `zapfe-deploy` ohne Passwort- und Root-Login, nur mit
  den für Docker/Kamal nötigen Rechten; kein persönlicher Schlüsselpfad im Repo.
- Personenunabhängiger SSH-Key im Secret Manager, dokumentierter Owner und
  Rotation mindestens jährlich sowie sofort bei Rollenwechsel oder Verdacht.
- Host-Firewall (nur SSH/HTTP/HTTPS), automatische Security-Updates,
  SSH-Allowlist/Fail2ban und zentral alarmierte Systemlogs.
- Der genaue Einmal-Migrationsbefehl muss in Staging bewiesen werden, bevor er als
  automatischer Hook produktiv verwendet wird.
