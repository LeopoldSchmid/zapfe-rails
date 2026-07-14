# Phase 1 – manueller Abnahmelauf

Stand: 2026-07-14

## Vorbereitung

1. Lokale Datenbank migrieren: `bin/rails db:migrate`.
2. Drei persönliche Admin-Konten mit eigenen Zugangsdaten anlegen. Für die lokale Seed-Datei müssen alle sechs Variablen gesetzt sein, zum Beispiel:

   ```bash
   LEOPOLD_ADMIN_EMAIL=leopold@example.test LEOPOLD_ADMIN_PASSWORD='...' \
   DENNIS_ADMIN_EMAIL=dennis@example.test DENNIS_ADMIN_PASSWORD='...' \
   JOHANNES_ADMIN_EMAIL=johannes@example.test JOHANNES_ADMIN_PASSWORD='...' \
   bin/rails db:seed
   ```

3. Server starten: `bin/rails server` und mit einem der drei Konten unter `/admin/login` anmelden.

## Abnahmefälle

| Fall | Aktion | Erwartetes Ergebnis |
| --- | --- | --- |
| Unzugewiesener Eingang | Eine Anfrage über das öffentliche Kontaktformular absenden; anschließend das Cockpit öffnen. | Die Anfrage erscheint im Dashboard und in der Anfragenliste deutlich als „Unzugewiesen“. |
| Übernahme und Status | Anfrage öffnen, Verantwortlichen, Status, nächsten Schritt und Fälligkeit setzen. | Angaben bleiben nach dem Speichern sichtbar; die Chronik enthält die Status- und Verantwortungsänderung. |
| Filter und Wartestatus | In der Liste nach Status, Verantwortlichem und „Heute fällig“ filtern; eine Anfrage auf „Wartet auf Kunde“ setzen. | Nur passende Einträge erscheinen; das Dashboard zeigt den Wartestatus. |
| Notiz und Datei | Eine Notiz hinzufügen sowie eine kleine PDF-, JPG-, PNG- oder WebP-Datei hochladen und öffnen. Danach testweise eine andere Dateiendung oder Datei über 25 MB auswählen. | Zulässige Datei ist herunterladbar; unzulässige Dateien werden abgelehnt. Der Download funktioniert nur nach Admin-Anmeldung. |
| Umwandlung | Anfrage in einen Auftrag umwandeln und danach die Aktion erneut auslösen. | Genau ein Auftrag entsteht; Kontakt-, Veranstaltungs- und Verantwortungsdaten sind vorhanden. Die Ursprungsanfrage bleibt verlinkt und damit mitsamt ihren Notizen und Dateien erreichbar. |
| Manueller Auftrag | Einen Auftrag direkt anlegen. | Name/Firma, Veranstaltungsdatum, Ort und verantwortlicher Admin sind erforderlich; E-Mail und Telefon bleiben optional. |
| Archiv | Anfrage bzw. Auftrag archivieren und anschließend die normale Liste sowie „Archiv“ öffnen. | Archivierte Vorgänge fehlen in der normalen Liste und erscheinen im Archiv. |
| Kontoschutz | Ein Konto deaktivieren und Anmeldung prüfen. Danach versuchen, das letzte aktive Konto zu deaktivieren. | Deaktivierte Konten können sich nicht anmelden; das letzte aktive Konto lässt sich nicht deaktivieren. |

## Noch nicht als Phase-1-Abnahme abgeschlossen

- DSGVO-Löschung bzw. Anonymisierung, Backup/Restore und die spätere Ereignishistorie für Angebote/Rechnungen/Zahlungen gehören zu späteren Arbeitspaketen.
