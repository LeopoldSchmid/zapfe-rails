# Datenschutz-Lebenszyklus und Betroffenenrechte

Stand: 16. Juli 2026. Dieses Runbook ist eine technische Arbeitsgrundlage und ersetzt keine anwaltliche oder steuerliche Freigabe.

## Eingang und Identitätsprüfung

Anfragen auf Auskunft, Berichtigung, Einschränkung oder Löschung werden mit Eingangsdatum und Frist intern erfasst. Vor Offenlegung oder Änderung muss die Identität über einen bereits bekannten Kommunikationskanal hinreichend geprüft werden. Keine Ausweiskopie dauerhaft speichern. Zweifel, Identitätsnachweis, Entscheidungen und Antworten werden in einem zugriffsbeschränkten Vorgang dokumentiert.

## Auskunft und Berichtigung

`bin/rails privacy:export EMAIL=synthetic@example.test` erzeugt einen JSON-Export der zu einer E-Mail auffindbaren Anfragen, Kontakte, Kunden, Aufträge, Angebote und Rechnungen. Der Export darf nur verschlüsselt beziehungsweise über einen zuvor verifizierten Kanal übermittelt werden. Berichtigungen erfolgen in den führenden Datensätzen; finalisierte Rechnungen werden nicht überschrieben, sondern über den freigegebenen Korrekturprozess behandelt.

## Löschung, Einschränkung und Legal Hold

Der Löschservice `Privacy::SubjectData` arbeitet transaktional und fail-closed:

- Ein aktiver `PrivacyLegalHold` sperrt den Lauf vollständig.
- Jeder Rechnungsbezug sperrt die Löschung, bis eine steuerlich/rechtlich freigegebene Frist abgelaufen ist.
- Ohne Sperre werden die betroffenen nicht-rechnungsbezogenen Vorgänge einschließlich Active-Storage-Zuordnungen gelöscht.
- Ein append-only `PrivacyErasureTombstone` enthält nur einen HMAC-Digest und Zähler. Er verhindert, dass gelöschte Daten bei einem Restore unbemerkt dauerhaft wieder produktiv werden.

Vor jedem echten Lauf sind Identität, Suchumfang, Legal Hold und Rechnungsbezug im Vier-Augen-Prinzip zu prüfen. Es gibt bewusst keinen produktiven Rake-Befehl zur Löschung.

## Backup-Nachlauf

Nach einem Restore müssen alle Tombstones, deren `erased_at` nach dem Stand des Backups liegt, gegen die wiederhergestellte Datenbank nachgezogen werden, bevor sie Netzwerkzugang oder produktive Zugangsdaten erhält. Der aktuelle Offsite-Prozess, RPO/RTO und die endgültige Fristmatrix benötigen Betreiberfreigabe.

## Noch extern freizugebende Fristen

Für jede Datenkategorie sind Zweck, Rechtsgrundlage, Startpunkt, Frist, Löschart, Legal-Hold-Ausnahme, Backup-Nachlauf und verantwortliche Rolle schriftlich freizugeben. Insbesondere Rechnungs-/Steuerunterlagen, erfolglose Anfragen, Auftragsunterlagen, Kommunikationsdaten, Logs, Push-Abonnements und Security-Auditdaten dürfen nicht mit frei erfundenen Standardfristen automatisiert gelöscht werden.
