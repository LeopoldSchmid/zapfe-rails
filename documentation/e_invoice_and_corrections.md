# Rechnungsintegrität, XRechnung und Korrekturen

Stand: 16. Juli 2026. Steuerliche und GoBD-bezogene Schlussfreigabe bleiben Aufgabe von Betreiber und Steuerberatung.

## Technische Umsetzung

- Rechnungsnummern stammen aus einem pro Jahr eindeutig indizierten, transaktional gesperrten `InvoiceSequence` statt aus `count + 1`. Beim ersten Lauf wird hinter vorhandenen Legacy-Nummern begonnen.
- Finalisierung ist idempotent. PDF, UBL-XRechnung, Snapshots und SHA-256-Prüfsummen entstehen in einer DB-Transaktion; Dateien werden vor dem Commit hochgeladen. Bei einem Fehler werden Transaktion und Sequenz zurückgerollt und vorab hochgeladene Objekte entfernt.
- Jeder Download und jeder Mailversand prüft PDF und XML gegen die gespeicherte Prüfsumme. Eine Abweichung sperrt den Vorgang.
- Mischsteuern werden je Steuersatz mit Bemessungsgrundlage und Steuerbetrag im Snapshot, PDF und XML ausgewiesen. Gesamtrabatte werden proportional je Steuersatz verteilt.
- Ein Storno verändert keine Rechnungspositionen. Es erzeugt eine eigene unveränderliche Stornorechnung (`CreditNote`, Typ 381) mit eigener Nummer, Referenz, PDF, XML, Prüfsumme und Auditspur. Das Original wechselt nur in den Status `cancelled`.

## XRechnung-Nachweis

Erzeugt wird UBL 2.1 mit XRechnung Customization-ID 3.0. Der synthetische Mischsteuerbeleg und die synthetische Stornorechnung wurden am 16. Juli 2026 mit folgenden offiziellen Artefakten geprüft:

- KoSIT Validator 1.6.2, SHA-256 laut GitHub-Release: `244978514ad48f67c7573acfffc8f4fd73d81feda6f276710033f9913579857e`
- `validator-configuration-xrechnung` 3.0.2, Release 2026-01-31
- Ergebnis für beide Dokumente: XML Schema `Y`, Schematron `Y`, `ACCEPTABLE`

Referenzaufruf:

```bash
java -jar validator-1.6.2-standalone.jar \
  -s scenarios.xml -r /path/to/xrechnung-config -h invoice.xml
```

Bei einem Versionswechsel der XRechnung-Konfiguration muss dieser Gate mit Rechnung und CreditNote wiederholt und dokumentiert werden.

## Externe Freigaben vor Produktion

- Kundenmix (B2B/B2C/öffentliche Auftraggeber), Vorjahresumsatz und Nutzung der Übergangsregelung entscheiden.
- Leitweg-ID beziehungsweise Buyer Reference, elektronische Adressen, Zahlungsdaten, Firmierung, Register- und Steuerangaben mit echten Empfängern prüfen.
- Eingangskanal und unveränderte Archivierung eingehender E-Rechnungen definieren; ein E-Mail-Postfach deckt nur den Empfang, nicht den internen Prüf-/Archivprozess ab.
- Steuerberatung muss Storno-, Berichtigungs-, Nummernkreis- und Aufbewahrungsverfahren freigeben.
- Für einen GoBD-Prüfpfad reicht lokaler Active Storage trotz Prüfsummen nicht allein: unveränderbare Archivspeicherung, Berechtigungen, Export, Verfahrensdokumentation und regelmäßige Integritätskontrolle sind als Betreiberprozess nachzuweisen.
