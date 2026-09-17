# Befristete Produktionsausnahme: Kollegentest

Stand: 17. September 2026.

## Entscheidung

Für einen begrenzten technischen Kollegentest darf der aktuelle Stand auf
`https://zapfe.jetzt` ausgerollt werden, obwohl die vollständige
Produktionsfreigabe noch nicht erteilt ist. Die Ausnahme gilt bis zum Review
am **24. September 2026**.

- Owner und verantwortlicher Betreiber: **Leopold Schmid**
- Vertretung: **Johannes Wiese**
- Zweck: Test des Produktionspfads durch Kollegen
- Keine Kundenkommunikation und keine Einladung realer Kunden während des
  Pilotzeitraums
- Bevorzugt ausschließlich Testdaten verwenden
- Die öffentliche Website bleibt technisch erreichbar; diese Ausnahme ist
  daher kein Ersatz für eine vollständige rechtliche, datenschutzrechtliche
  oder betriebliche Go-live-Freigabe

Die Entscheidung wurde vom Betreiber am 17. September 2026 im Arbeitschat
bestätigt. Die offenen externen NO-GO-Gates in
`production_readiness_matrix.md` bleiben unverändert offen.

## Akzeptiertes Risiko

Backup-/Restore-Nachweis, formaler Migrationsnachweis, Host-/Deploy-Härtung,
externe Alarmierung sowie Rechts-, Steuer- und Datenschutzfreigaben sind noch
nicht vollständig als Produktionsnachweis dokumentiert. Ein Fehler kann daher
zu Datenverlust, Betriebsunterbrechung, unvollständiger Alarmierung oder einer
nicht freigegebenen Verarbeitung führen. Die öffentliche Erreichbarkeit der
Website bedeutet außerdem, dass der Pilot nicht technisch auf Kollegen
beschränkt ist.

## Verbindliche Gegenmaßnahmen

1. Vor dem Deploy einen konsistenten, verschlüsselten Backup-Satz von
   Datenbank und Active Storage erstellen und dessen Prüfsumme prüfen.
2. Den Backup-Satz isoliert wiederherstellen oder die vorhandene
   Restore-Prüfung unmittelbar vor dem Release nachvollziehbar bestätigen.
3. `bin/rails db:prepare` genau einmal im neuen Image mit dem
   Produktions-Storage ausführen; bei einem Fehler keinen Traffic umschalten.
4. Erst danach Web- und Job-Rolle deployen und `/up`, Deep Health, Adminlogin,
   Rechner sowie Inquiry-Synthetic prüfen.
5. Während des Piloten keine Kundenkommunikation starten, keine Marketingdaten
   aktivieren und keine Umami-Analytics einschalten.
6. Fehlerquote, Queue, Mailzustellung, freien Speicher und Logs mindestens
   30 Minuten beobachten.
7. Bei kritischem Fehler auf das vorige Image zurückrollen, sofern die
   Migration rückwärtskompatibel ist; andernfalls den Release stoppen und
   vorwärts reparieren beziehungsweise den dokumentierten Restorepfad nutzen.

## Ablaufdatum und Neubewertung

Am 24. September 2026 wird entschieden, ob der Pilot beendet, die vollständige
Produktionsfreigabe erteilt oder die Ausnahme mit aktualisiertem Risiko und
neuem Reviewtermin verlängert wird. Eine Verlängerung darf nicht automatisch
erfolgen. Bei Datenleck, kompromittiertem Zugang, Datenverlust oder kritischer
Störung gilt die Ausnahme sofort als beendet und der Incident-/Breach-Ablauf
ist zu starten.
