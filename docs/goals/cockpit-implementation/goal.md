# Zapfe-Auftragszentrale implementieren

## Objective

Die bestehende Rails-Anwendung wird schrittweise zu einer nutzbaren internen Auftragszentrale erweitert. Zuerst werden Phase 0 validiert sowie Phase 1 bis 3 als zusammenhängender, testbarer erster Betriebsablauf umgesetzt: Anfrage übernehmen → Auftrag anlegen → Angebot kalkulieren und versenden → Beschaffung, Aufgaben und konkrete Ressourcen planen. Rechnungen/XRechnung und PWA bleiben an ihre ausdrücklich offenen Entscheidungsblöcke gebunden.

## Original Request

`documentation/cockpit_implementation_plan.md` lesen, daraus einen strukturierten Implementierungsplan erstellen und die beschriebene Erweiterung anschließend Schritt für Schritt mit Überblick über Erledigtes, Fehlendes und offene Fragen umsetzen.

## Intake Summary

- Input shape: `existing_plan`
- Audience: internes Zapfe-Dreierteam
- Authority: `requested`
- Proof type: `test`
- Completion proof: getestete, mobile Admin-Flows erfüllen die Exit-Kriterien der in Scope befindlichen Roadmap-Phasen; das Roadmap-Dokument und Board zeichnen Status und offene Entscheidungen nach.
- Goal oracle: reale bzw. anonymisierte Durchläufe für Anfrage→Auftrag, Angebot→Versand sowie bestätigter Auftrag→Beschaffung/Aufgaben/Ressourcen, ergänzt durch Modell-, Integration- und Browser-Tests.
- Likely misfire: viele Tabellen oder Modelle anzulegen, ohne einen sicheren, durchgängigen operativen Ablauf und eingefrorene Dokument-Snapshots zu liefern.
- Blind spots considered: unbekannte Ist-Datenqualität des Katalogs, bestehende Admin-Authentifizierung, PDF-Renderer/Deployment, Backup/DSGVO sowie die fachlich offenen Entscheidungen für Rechnungen und PWA.
- Existing plan facts: Phasen, Statuswerte, Modellgrenzen, technische Leitlinien, Nicht-Ziele und Exit-Kriterien aus `documentation/cockpit_implementation_plan.md` bleiben maßgeblich und werden vor jeder betroffenen Phase validiert.

## Goal Oracle

Der Oracle ist ein receipt-gestützter Nachweis, dass die folgenden Abläufe mit Tests funktionieren und zu den vereinbarten Exit-Kriterien passen:

1. Persönlicher Admin übernimmt eine unzugewiesene Anfrage und wandelt sie idempotent in genau einen Auftrag um.
2. Ein Auftrag erhält versionierte Angebotsentwürfe mit Kalkulation, Lieferantenvergleich, festgeschriebenem PDF und protokolliertem Versand.
3. Ein bestätigter Auftrag führt zu nachvollziehbarer Beschaffung, relativen Aufgaben und konfliktfreier Reservierung konkreter Ressourcen.

Phase 4 und 5 werden erst aktiviert, wenn ihre im Roadmap-Dokument markierten Entscheidungen vorliegen; technische Spikes dürfen diese Entscheidung vorbereiten, aber keine rechtlich oder fachlich bindenden Annahmen treffen.

## Goal Kind

`existing_plan`

## Current Tranche

Kontinuierliche Umsetzung von Phase 0 bis einschließlich Phase 3. Die Arbeit läuft in vertikalen Paketen weiter, bis die Exit-Kriterien des ersten nutzbaren Cockpits geprüft sind. Jede Phase erhält vor ihrem ersten Schreibpaket eine Evidence-/Entscheidungsprüfung. Die Roadmap bleibt lebendes Fortschritts- und Entscheidungsdokument.

## Non-Negotiable Constraints

- Rails-Monolith und Hotwire-first beibehalten.
- Anfrage und Auftrag bleiben getrennte Phasen; die Konvertierung ist idempotent.
- Geldwerte mit `BigDecimal`, Zeiten in `Europe/Berlin`, Dokument- und Preiswerte als Snapshots.
- Interne Funktionen ausschließlich im geschützten Admin-Namespace; persönliche aktive Admin-Konten und nachvollziehbare Aktivitäten.
- Keine stillschweigende Umsetzung der offenen Rechnungs-, XRechnung-, Push- oder Rechtsentscheidungen.
- Bestehende, fremde oder uncommittete Änderungen bleiben erhalten.
- Jede Arbeitseinheit liefert Datenmodell, Businesslogik, Oberfläche und angemessene Tests zusammen.

## Stop Rule

Nicht nach dem Planen oder nach einem einzelnen Modell stoppen. Nur an einer echten Entscheidungsgrenze ohne sichere lokale Folgearbeit wird die konkrete benötigte Entscheidung abgefragt; ansonsten wird der nächste größte testbare vertikale Schnitt aktiviert.

## Canonical Board

Machine truth lives at `docs/goals/cockpit-implementation/state.yaml`.

## Run Command

```text
/goal Follow docs/goals/cockpit-implementation/goal.md.
```
