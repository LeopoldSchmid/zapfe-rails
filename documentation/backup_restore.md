# Backup und Restore

Stand: 16.07.2026

## Sicherheitsziel

Das produktive Storage-Volume enthält Primary-, Queue-, Cache- und Cable-SQLite-
Datenbanken sowie Active-Storage-Dateien. Ein Backup ist erst belastbar, wenn
alle fachlich benötigten Dateien enthalten, jede SQLite-Kopie konsistent, das
Archiv verschlüsselt offsite gespeichert und ein isolierter Full-Restore
erfolgreich geprüft wurde.

`script/replace_prod_storage_from_staging` ist absichtlich gesperrt. Es darf
nicht reaktiviert oder umgangen werden. Ein Restore erfolgt immer in ein neues
leeres Verzeichnis beziehungsweise Volume; der spätere Cutover ist eine
separate, reviewpflichtige Betreiberaktion mit Rollback.

## Backup erstellen

Auf dem Anwendungscontainer oder einem Host mit lesbarem Storage und `sqlite3`,
`tar`, `sha256sum` sowie `age`:

```bash
script/backup_storage \
  --source /rails/storage \
  --output /secure-export/zapfe-storage-2026-07-16.tar.gz.age \
  --age-recipient age1REPLACE_WITH_BACKUP_RECIPIENT
```

Das Skript:

1. akzeptiert nur explizite absolute Pfade und überschreibt nie ein Archiv;
2. kopiert jede SQLite-Datenbank über deren Online-Backup-API;
3. prüft jede Kopie mit `PRAGMA integrity_check`;
4. übernimmt die übrigen Storage-Dateien ohne Live-WAL/-SHM-Dateien;
5. schreibt SHA-256-Prüfsummen für jede Payload-Datei;
6. verschlüsselt für Offsite-Backups mit einem `age`-Empfänger.

`--allow-plaintext` existiert ausschließlich für isolierte lokale Tests oder
wenn das Archiv unmittelbar durch einen freigegebenen verschlüsselten Kanal
weiterverarbeitet wird. Unverschlüsselte Archive dürfen nicht offsite abgelegt
werden.

## Upload auf die Offsite-Storage-Box

Die Produktions-Storage-Box lautet derzeit
`u635934.your-storagebox.de` in Falkenstein. Der Upload erfolgt bewusst in einem
eigenen Schritt, damit ein fehlgeschlagener Transport niemals das lokale Archiv
oder vorhandene Offsite-Sätze löscht. Vor der ersten Nutzung muss der Betreiber
in der Storage Box **SSH-Support** aktivieren (Port 23); „External Reachability“
bleibt deaktiviert.

Für jede Anwendung ist ein eigener Storage-Box-User, eigener Remoteordner und
eigener SSH-Schlüssel zu verwenden. Der private Schlüssel, die `known_hosts`-
Datei und der `age`-Identity-Key gehören ausschließlich in den Secret Manager
beziehungsweise auf den Restore-Host, nie in Rails Credentials oder Git.

```bash
script/upload_offsite_backup \
  --archive /secure-export/zapfe-storage-2026-07-20.tar.gz.age \
  --host u635934.your-storagebox.de \
  --user STORAGE_BOX_SUBACCOUNT \
  --ssh-key /run/secrets/zapfe_backup_storagebox_key \
  --known-hosts /run/secrets/zapfe_storagebox_known_hosts \
  --remote-path zapfe/2026-07-20/zapfe-storage-2026-07-20.tar.gz.age
```

Der Befehl akzeptiert nur `age`-verschlüsselte Archive, verlangt eine explizite
Host-Identität, verweigert unsichere Pfade und bestehende Remoteziele und
vergleicht nach dem Upload die SHA-256-Prüfsumme. Er löscht niemals lokale oder
entfernte Daten. Die konkrete Backupfrequenz, Generationenaufbewahrung, Key-
Owner und der erfolgreiche echte Restore bleiben Betreiberfreigaben.

## Täglicher Lauf

Der beschlossene Startwert ist täglich 03:30 Uhr `Europe/Berlin`, RPO 24 Stunden und RTO vier
Stunden. `script/run_offsite_backup` erstellt dafür einen eindeutigen
UTC-Zeitstempel und ruft erst `backup_storage`, dann `upload_offsite_backup`
auf. Bis der getrennt zu testende Löschpfad vorliegt, werden keine alten Sätze
automatisch gelöscht; die beschlossene Aufbewahrung von 30 täglichen Sätzen ist
deshalb als Zielwert, nicht als bereits aktive Löschautomatik zu behandeln.

Auf dem Produktionshost ist der Systemd-Timer `zapfe-offsite-backup.timer`
aktiviert. Er läuft täglich um 03:30 Uhr `Europe/Berlin` mit bis zu fünf Minuten
Zufallsverzögerung. Prüfen ohne Ausführung:

```bash
systemctl status zapfe-offsite-backup.timer --no-pager
systemctl list-timers zapfe-offsite-backup.timer --no-pager
```

## Restore isoliert prüfen

Der private `age`-Identity-Key gehört nicht auf denselben Host und nicht in Rails
Credentials. Restore immer zuerst in ein neues Wegwerfvolume:

```bash
script/restore_storage \
  --archive /secure-export/zapfe-storage-2026-07-16.tar.gz.age \
  --identity /secure-key/age-identity.txt \
  --target /restore-check/zapfe-storage
```

Vor dem Schreiben prüft das Skript Pfadtraversal, Format, alle SHA-256-
Prüfsummen und jede SQLite-Datenbank. Ein vorhandenes nicht-leeres Ziel wird
immer abgelehnt und niemals gelöscht.

Danach sind mindestens zu prüfen:

- Rails startet mit einer Kopie des Restores;
- Adminlogin und Stichproben aus Anfragen, Aufträgen, Angeboten und Rechnungen;
- zufällig ausgewählte Active-Storage-Dateien und finalisierte PDFs;
- Queuezustand und geplante Jobs;
- Anzahl/Größe der Datenbanken und Dateien gegen die Backup-Metrik.

## Noch festzulegende Betreiberwerte

Vor Produktionsfreigabe müssen verbindlich dokumentiert und real getestet sein:

- RPO und RTO;
- Backupfrequenz und Aufbewahrungsstaffel;
- Offsite-Ziel, Region, AVV und Zugriffskontrolle;
- Owner und Recovery für den Verschlüsselungsschlüssel;
- Erfolgs-, Alters-, Größen- und Fehleralarme;
- monatlicher automatischer Restore-Smoke und regelmäßiger manueller
  Full-Restore;
- Lösch-/Legal-Hold-Nachlauf in Backupgenerationen;
- Vier-Augen-Freigabe und Rollback für einen Produktions-Cutover.

Ein lokal erzeugtes Archiv allein schließt OPS-001 nicht. Das Finding ist erst
erledigt, wenn ein aktueller verschlüsselter Offsite-Satz erfolgreich isoliert
restored und der Nachweis protokolliert wurde.
