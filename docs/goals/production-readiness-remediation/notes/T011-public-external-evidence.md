# T011 – Öffentliche externe Evidenz

Stand: 17. Juli 2026. Diese Prüfung ersetzt weder den im Kundenkonto
abgeschlossenen Vertrag noch eine Betreiber-, Rechts- oder Steuerfreigabe.

## Hetzner

Öffentlich verifiziert:

- Hetzner stellt einen AV-Vertrag nach Art. 28 DSGVO bereit; der konkrete
  Vertrag wird im Kundenkonto abgeschlossen und enthält die kundenspezifischen
  Datenarten und Betroffenengruppen.
- Aktuelle Subunternehmerliste und TOMs sind veröffentlicht. Das jährliche
  Auditprotokoll wird Kunden mit abgeschlossenem AV-Vertrag im Portal
  bereitgestellt.
- Cloud-Daten in Falkenstein, Nürnberg oder Helsinki bleiben laut Hetzner in
  der EU; der konkrete gebuchte Produktstandort ist jedoch nur im Account
  belastbar nachweisbar.
- Die im Deployment hinterlegte IP `157.180.19.232` wird durch öffentliche,
  nicht amtliche IP-Datenbanken dem Hetzner-Netz und überwiegend Helsinki
  zugeordnet. Das ist nur ein Hinweis, kein Standortbeleg.

Primärquellen:

- https://docs.hetzner.com/de/general/company-and-policy/data-protection-at-hetzner/
- https://www.hetzner.com/AV/DPA_de.pdf
- https://www.hetzner.com/AV/subunternehmer.pdf
- https://docs.hetzner.com/de/general/security-and-identify/technical-and-organizational-measures/
- https://docs.hetzner.com/general/infrastructure-and-availability/data-centers-and-connection/

Noch erforderlich:

- Produkt-/Account-ID und gebuchter Standort;
- exportierter/archivierter abgeschlossener AV-Vertrag samt Datum;
- aktuelle Subunternehmer- und TOM-Prüfung durch benannten Owner;
- Offsite-Backupziel, das nicht automatisch durch den App-Serverstandort belegt
  ist.

## Resend

Öffentlich verifiziert:

- DPA-Stand 31. Dezember 2025; Plus Five Five, Inc. / Resend verarbeitet als
  Auftragsverarbeiter und bindet EU-Standardvertragsklauseln ein.
- Das DPA nennt E-Mail-Adresse, Metadaten, Nachrichtentext und mögliche Anhänge
  als übertragene Daten; Tracking kann zusätzlich IP-, Geräte- und
  Clientinformationen umfassen.
- Primäre Verarbeitung findet in den USA statt. Eine EU-Versandregion ändert
  nicht den Speicherort der Accountdaten: Metadaten, Logs und API-Daten bleiben
  laut Resend in den USA.
- Kundendaten werden laut DPA nach Vertragsende innerhalb von 90 Tagen gelöscht;
  reguläre E-Mail-Daten werden laut Dokumentation 30 Tage gehalten. Backups
  werden 30 Tage aufbewahrt und global repliziert.
- Die aktuelle öffentliche Subprocessor-Liste enthält zahlreiche US-Anbieter,
  unter anderem AWS, Cloudflare, Datadog, Google, Supabase und Vercel.
- Resend bietet auf qualifizierten kostenpflichtigen Accounts gegen Aufpreis
  eine Deaktivierung der Speicherung von Nachrichtentexten an. Für den
  aktuellen Account ist dies nicht belegt.

Primärquellen:

- https://resend.com/legal/dpa
- https://resend.com/legal/subprocessors
- https://resend.com/docs/dashboard/domains/regions
- https://resend.com/docs/security
- https://resend.com/docs/dashboard/webhooks/how-to-store-webhooks-data
- https://resend.com/docs/knowledge-base/how-do-i-ensure-sensitive-data-isnt-stored-on-resend

Noch erforderlich:

- Account-/Vertrags-ID und Nachweis, dass das DPA wirksam akzeptiert wurde;
- gewählte Versandregion, Tracking-Einstellungen und Content-Storage-Status;
- dokumentierte Transferprüfung/TIA einschließlich SCC und gegebenenfalls
  EU-US Data Privacy Framework;
- Entscheidung, ob Resend für Rechnungs-/Angebotsinhalte akzeptiert wird oder
  ein EU-residenter SMTP-Anbieter gewählt werden muss.

## Gesellschaftsdaten

Repository und aktuelle Website nennen übereinstimmend:

- ape2tap UG (haftungsbeschränkt), Habsburgerstr. 38, 79104 Freiburg;
- Amtsgericht Freiburg, HRB 731370;
- Vertretung: Leopold Schmid;
- USt-IdNr. DE369035041.

Nicht amtliche Registeraggregatoren bestätigen Firma, Anschrift, Register und
Geschäftsführer für die Eintragung vom Juli 2024. Da kein aktueller amtlicher
Registerauszug und keine VIES-/Steuerunterlage vorliegen, bleibt LEG-001 offen.
Ein Aggregator ist kein ausreichender Produktionsfreigabebeleg.

## GitHub / Branch Protection

Remote ist `LeopoldSchmid/zapfe-rails`, Defaultbranch im lokalen Repository ist
`master`. Die GitHub CLI ist in dieser Umgebung nicht authentifiziert. Daher
konnte weder der aktuelle Branch-Protection-Status gelesen noch ein absichtlich
roter Probe-PR durchgeführt werden. QUAL-001 bleibt extern offen.

## Unverändert nicht öffentlich entscheidbar

- Beschäftigtenzahl, Umsatz und Bilanzsumme für VSBG/BFSG;
- tatsächlicher B2C/B2B-/Behördenmix und Vertragsschlussweg;
- Steuer-/Rechtsfreigaben und Verfahrensdokumentation;
- echte Account-, Live-, Host-, Alarm-, Restore-, Signatur- und Lastnachweise;
- benannte Verantwortliche, Stellvertretungen und Unterschriften.

