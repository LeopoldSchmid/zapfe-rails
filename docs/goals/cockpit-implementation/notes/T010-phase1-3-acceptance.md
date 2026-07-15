# Phase 1–3 – Abnahme der Auftragszentrale

Stand: 2026-07-14

## Automatisierter Nachweis

- `bin/rails test`: 130 Tests, 535 Assertions, grün.
- `bin/rails test test/system/admin_inquiry_to_order_test.rb test/system/admin_offer_to_procurement_test.rb`: 2 Browserflüsse, grün.
- Der vollständige Systemtest-Sammellauf enthält zwei unabhängige Preisrechner-Fehler (`CalculatorToggleTest`); sie betreffen keine Cockpit-Route.

## Manueller Abnahmelauf

| Ablauf | Aktion | Erwartetes Ergebnis |
| --- | --- | --- |
| Angebot und PDF | Auftrag öffnen, Entwurf erstellen, Position mit Bezugsquelle anlegen, finalisieren und PDF öffnen. | Angebotsnummer, Beträge, Rabatt und PDF sind vorhanden; nach Finalisierung sind Daten nicht mehr änderbar. |
| Versand | Finalisiertes Angebot per E-Mail versenden. | Versand wird eingeplant und in der Chronik protokolliert; das PDF ist angehängt. |
| Annahme und Beschaffung | Angebot als angenommen markieren und im Auftrag einen Beschaffungsplan erzeugen. | Auftrag wird „Beauftragt“; Quelle, Preis-/Konditionssnapshot, Bestellfrist und offene Bestellaufgabe erscheinen. Lieferantenangebot oder Bestellbestätigung kann als PDF/Bild direkt am Plan angehängt werden. |
| Nicht rückgabefähig | Beschaffungsplan mit einer nicht rückgabefähigen Position auf „Bestätigt“ setzen. | Ohne bewusste Bestätigung wird der Status blockiert. Über die Bestätigungsaktion werden Status, Zeitpunkt und handelnder Admin gespeichert. |
| Externe Leistung | Eine freie Angebotsposition, etwa externe Kühlanhänger-Miete oder Lieferung/Miete, anlegen, finalisieren, annehmen und in die Beschaffung übernehmen. | Die Position erscheint im Beschaffungsplan auch ohne Lieferantenquelle; direkte Kosten und Menge bleiben sichtbar. |
| Terminverschiebung | Bei einem Auftrag mit relativer Aufgabe das Veranstaltungsdatum ändern. | Die relative Fälligkeit wird entsprechend neu berechnet. |
| Ressourcen | Zwei Ressourcen anlegen, eine Einheit reservieren und eine kollidierende Reservierung versuchen. Danach den Ressourcenbereich öffnen. | Kollision wird blockiert; die Wochenansicht zeigt die Reservierung und freie Tage. |
| Checklisten | Unter „Checklisten“ eine Vorlage mit Punkten anlegen, sie im Auftrag anwenden und Punkte abhaken. | Der Auftrag erhält eine eigene Kopie; der Fortschritt und Abschlussstatus werden aktualisiert. |
| Wiederkehrende Reihe | Unter „Vorlagen“ eine Reihen-Vorlage mit Tags, Produkten, Aufgaben, Checklisten, Ressourcen und Zeiten anlegen; neuen Auftrag damit erzeugen und daraus einen Angebotsentwurf anlegen. | Es entsteht ein eigener Auftrag mit den gewählten Vorgaben; Aufgaben/Checklisten sind kopiert, Ressourcen nur bei Datum und gültigen Zeiten reserviert. Vorausgewählte Produkte erscheinen als editierbare Angebotspositionen. |
| Arbeitszeit | Im Angebot geplante Zeit und im Auftrag Ist-Zeit erfassen. | Geplante und tatsächliche Kosten werden getrennt im Auftrag angezeigt. |

## Bewusst offene Punkte

- Detailinhalte der Checklisten gemeinsam mit dem Team.
- Rechtliche/fachliche Prüfung des Angebots-PDF vor Produktivbetrieb.
- DSGVO-Löschung, Backup/Restore, Rechnungen/XRechnung und PWA bleiben außerhalb dieses Tranche.
