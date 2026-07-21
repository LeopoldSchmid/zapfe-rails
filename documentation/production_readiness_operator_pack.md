# Betreiberpaket zur Produktionsfreigabe

Stand: 21. Juli 2026. Dieses Paket trennt bereits implementierte technische
Kontrollen von Nachweisen, die nur der Betreiber, seine Anbieter sowie Rechts-
und Steuerberatung liefern können. Leere Freigabefelder sind ein bewusstes
`NO-GO`; sie dürfen nicht durch Annahmen ersetzt werden.

## Freigabekopf

| Feld | Verbindlicher Eintrag |
| --- | --- |
| Verantwortliche Gesellschaft / ladungsfähige Anschrift | **ape2tap UG (haftungsbeschränkt), Habsburgerstr. 38, 79104 Freiburg im Breisgau** – vom Betreiber am 20.07.2026 als aktuell bestätigt; amtlicher Beleg noch offen |
| Vertretungsberechtigte Person(en) | **Leopold Schmid** – vom Betreiber am 20.07.2026 als aktuell bestätigt; amtlicher Beleg noch offen |
| Handelsregister / Registernummer / Registergericht | **Amtsgericht Freiburg, HRB 731370** – vom Betreiber am 20.07.2026 als aktuell bestätigt; aktueller Registerauszug noch offen |
| USt-IdNr. oder Wirtschafts-IdNr., falls vorhanden | **DE369035041** – vom Betreiber am 20.07.2026 als aktuell bestätigt; Steuer-/VIES-Beleg noch offen |
| Datenschutzverantwortung und Stellvertretung | **Leopold Schmid** – intern verantwortliche Person; **Johannes Wiese** – Vertretung. Vom Betreiber am 21.07.2026 bestätigt. Dies ist keine Bestellung als gesetzlicher Datenschutzbeauftragter. |
| Security-/Incident-Owner und Stellvertretung | **Leopold Schmid** – primärer Owner; **Johannes Wiese** – Vertretung. Vom Betreiber am 21.07.2026 bestätigt. Alarm- und Incidentkanäle: `info@zapfe.jetzt`, `ape2tap.blackforest@gmail.com` und Telegram `duzend_monitoring_bot` (Testnachricht am 21.07.2026 angekommen). |
| Datenschutzrechte-Kanal | `info@zapfe.jetzt` – vom Betreiber am 21.07.2026 als Kanal für Auskunft, Berichtigung, Löschung und Widerspruch festgelegt; Antwortfrist grundsätzlich ein Monat, Identität bei Zweifeln angemessen prüfen. |
| Steuerberatung / Freigabeperson | **OFFEN** |
| Rechtsprüfung / Freigabeperson | **OFFEN** |
| Geplanter Produktionsstart | **OFFEN** |

## A. Unmittelbare Betreiberentscheidungen

Jede Zeile benötigt Datum, verantwortliche Person, Beleglink beziehungsweise
Dokument-ID und eine eindeutige Entscheidung.

| Gate / Findings | Benötigte Entscheidung oder Evidenz | Status |
| --- | --- | --- |
| Impressum, LEG-001 | Alle Angaben des Freigabekopfs gegen Registerauszug und Steuerunterlagen prüfen; berufs-/aufsichtsrechtliche Angaben und Liquidationsstatus ausdrücklich mit `nicht zutreffend` oder Beleg beantworten. § 5 DDG verlangt insbesondere Name, Anschrift, Vertretung, schnellen elektronischen Kontakt, Registerdaten und vorhandene Steuer-/Wirtschafts-ID. | **TEILWEISE – Betreiberbestätigung vom 20.07.2026 liegt vor; amtliche Belege und Rechtsprüfung offen** |
| VSBG, LEG-002 | Beschäftigtenzahl am 31.12.2025; Teilnahmebereitschaft/-pflicht; falls Teilnahme: zuständige Stelle mit Anschrift und Website. Auch § 37 VSBG für nicht beigelegte Streitigkeiten in den Prozess aufnehmen. | **TEILWEISE – keine freiwillige Teilnahme beschlossen; bei maximal drei tätigen Personen greift die allgemeine Websitepflicht nach § 36 Abs. 1 Nr. 1 VSBG voraussichtlich nicht. Prozess für Einzelfallhinweis nach § 37 VSBG und Rechtsprüfung offen** |
| BFSG, LEG-003/A11Y-001 | B2C-Vertragsschlussweg beschreiben; Zahl der Beschäftigten, Umsatz und Bilanzsumme belegen. Kleinstunternehmen: weniger als 10 Personen und höchstens 2 Mio. EUR Umsatz **oder** Bilanzsumme; Dienstleistungs-Ausnahme rechtlich bestätigen. Andernfalls Konformitäts-/Barrierefreiheitsinformation und manuelles Audit freigeben. | **TEILWEISE – Größenangaben sprechen für ein Kleinstunternehmen; B2C-Scope, Finanzbeleg und rechtliche Bestätigung der Ausnahme offen** |
| Fernabsatz, LEG-007 | Für Anfrage, Angebot, Annahme und Zahlung exakt festlegen, wann bei B2C ein Vertrag entsteht. Informationspflichten, Vertragsbestätigung, Widerruf und mögliche termingebundene Freizeit-Ausnahme des § 312g Abs. 2 Nr. 9 BGB rechtlich pro Produktpfad prüfen. | **TEILWEISE – tatsächlicher B2B-/B2C-Mix und Vertragsschlusspunkte beschrieben; B2B-Prozessformalisierung und Rechtsprüfung offen** |
| Preisangaben, LEG-008 | Jede B2C-Preisclaim-Liste freigeben. Gesamtpreis einschließlich Umsatzsteuer und Preisbestandteilen ausweisen; bei Aufgliederung Gesamtpreis hervorheben. Klären, ob der Rechner nur unverbindliche Indikation oder bereits Angebot/Werbung mit Preis ist. | **BLOCKIERT – Claim-/Rechtsprüfung fehlt** |
| Rechnungen, LEG-005/006/ARCH-005 | Kundenmix B2B/B2C/Behörden, Vorjahresumsatz, E-Rechnungs-Übergang, Empfangskanal, Buyer Reference/Leitweg-ID, Nummernkreis, Storno/Korrektur und Archivverfahren durch Steuerberatung freigeben. Rechnungen/Buchungsbelege aktuell mindestens acht Jahre ab Jahresende einplanen; längere Sonderfristen prüfen. | **BLOCKIERT – Steuerfreigabe fehlt** |
| Datenschutz, PRIV-001/002/006/007 | Verarbeitungstätigkeiten, Rechtsgrundlagen, Empfänger, Drittlandtransfers, Fristen, Rechtekanal, Identitätsprüfung, DPIA-Screening, TOMs und Breach-Kontakte freigeben. | **BLOCKIERT – Betreiber-/Rechtsfreigabe fehlt** |

Amtliche Grundlagen: [§ 5 DDG](https://www.gesetze-im-internet.de/ddg/__5.html),
[§ 36 VSBG](https://www.gesetze-im-internet.de/vsbg/__36.html),
[§ 1 BFSG](https://www.gesetze-im-internet.de/bfsg/__1.html),
[§ 2 BFSG](https://www.gesetze-im-internet.de/bfsg/__2.html),
[§ 3 BFSG](https://www.gesetze-im-internet.de/bfsg/__3.html),
[§ 19 BFSGV](https://www.gesetze-im-internet.de/bfsgv/__19.html),
[§ 312g BGB](https://www.gesetze-im-internet.de/bgb/__312g.html),
[§ 3 PAngV](https://www.gesetze-im-internet.de/pangv_2022/__3.html),
[§ 147 AO](https://www.gesetze-im-internet.de/ao_1977/__147.html) und
[§ 14b UStG](https://www.gesetze-im-internet.de/ustg_1980/__14b.html).

## B. Auftragsverarbeiter und Transfers

Das Detailregister steht in `documentation/privacy_processors_register.md`.
Für jeden tatsächlich aktiven Dienst ist folgende Zeile vollständig zu
duplizieren und auszufüllen; Marketingseiten allein sind kein Vertragsbeleg.

| Pflichtfeld | Hetzner | Resend | Umami-Betreiber | Push-/Browserdienste | Mailbox/Clients |
| --- | --- | --- | --- | --- | --- |
| Produkt/Account/Vertrags-ID | **Hetzner Cloud CX22; Storage Box `u635934.your-storagebox.de` in Falkenstein (Deutschland) am 20.07.2026 angelegt; Zapfe-Subaccount `u635934-sub1` eingerichtet; interne Account-/Vertrags-ID offen** | offen | offen | offen | offen |
| Öffentliche DPA-Basis | DPA-/TOM-Muster und Subunternehmerliste öffentlich verifiziert | DPA vom 31.12.2025 mit EU-SCC öffentlich verifiziert | offen | offen | offen |
| AVV/DPA im eigenen Account, Abschlussdatum | **separater AVV/DPA für ape2tap UG (haftungsbeschränkt) am 20.07.2026 im Hetzner-Konto abgeschlossen; privater AVV bleibt getrennt** | offen | offen | offen | offen |
| Verantwortlicher Prüfer / nächste Prüfung | **Recovery-Key-Owner: Leopold Schmid; Vertretung: Johannes Wiese. Zugriff der Vertretung im Passwortmanager am 20.07.2026 bestätigt; nächster Reviewtermin offen** | offen | offen | offen | offen |
| Datenarten und Betroffene | offen | **Kontakt- und Kommunikationsdaten aus Kontaktanfragen sowie technische Versandmetadaten; Betroffene: anfragende Personen. Betreiberbestätigung vom 20.07.2026; weitere aktive Versandzwecke offen** | offen | offen | offen |
| Primärregion und Supportzugriffe | **Helsinki, Finnland (EU) laut Betreiberangabe vom 20.07.2026; Supportzugriffe und Accountbeleg offen** | Accountdaten/Metadaten/Logs/API laut Anbieter stets USA; Versandregion offen | offen | offen | offen |
| Subprozessorliste und Änderungsweg | öffentliche Liste verifiziert; Accountreview offen | öffentliche Liste verifiziert; 14-Tage-Änderungsmitteilung laut DPA; Accountreview offen | offen | offen | offen |
| Drittlandmechanismus (Angemessenheit/SCC) | abhängig vom gebuchten Standort; Accountbeleg offen | US-Verarbeitung und SCC im DPA verifiziert; Betreiberentscheidung vom 21.07.2026: ausschließlich notwendige transaktionale E-Mails über Resend zulässig; keine Marketingkampagnen | offen | offen | offen |
| TIA, falls erforderlich | offen | vereinfachte dokumentierte Risikoabwägung für den eng begrenzten Versandzweck noch zu hinterlegen | offen | offen | offen |
| Provider- und eigene Löschfrist | **30 tägliche Sicherungen. Automatische Remote-Aufbewahrung ist nach isoliertem Test am 21.07.2026 aktiv: täglich 03:50 Uhr Europe/Berlin, getrennt nach dem Backup. Recovery-Identity liegt außerhalb des Produktionsservers; öffentlicher age-Empfänger: `age1ulregnk00jaac402gsea3zjjudd9mf68v9vv35n4w8dl93zlw5qqvgddng`** | reguläre E-Mail-Daten 30 Tage; Backups 30 Tage; nach Vertragsende bis 90 Tage laut Anbieter – Accountkonfiguration offen | offen | offen | offen |
| Export/Löschung/Incident-Meldeweg getestet | **am 20.07.2026: dedizierter Zapfe-Subaccount, verschlüsselter Archivupload und isolierter Restore mit sechs geprüften SQLite-Datenbanken erfolgreich. Am 21.07.2026 wurde der Retention-Löschpfad in einem separaten Storage-Box-Testpfad erfolgreich geprüft; der produktive Timer ist aktiv.** | offen | offen | offen | offen |
| Live-Netzwerk-/Konfigurationsbeleg | **Storage Box in Falkenstein; SSH-Port 23 und getrennte Schlüsselidentität verifiziert. Initiales Archiv vom 20.07.2026 erfolgreich wiederhergestellt. Erster automatischer Lauf am 21.07.2026 erfolgreich: Archiv unter `zapfe/2026-07-21/`, SHA-256 `e415faaf8b1f43ca20ff8f58d4b00984292aafbd64afb713d98196b84eaf2d81`. systemd-Timer täglich 03:30 Europe/Berlin aktiv.** | offen | offen | offen | offen |

Produktionsregel: Nicht belegte optionale Dienste bleiben deaktiviert. Ein
notwendiger Dienst ohne freigegebenen AVV-/Transferpfad blockiert den Go-live.

Primärquellen für die öffentliche Providerbasis:

- Hetzner: [Datenschutz/AVV](https://docs.hetzner.com/de/general/company-and-policy/data-protection-at-hetzner/), [DPA-Muster](https://www.hetzner.com/AV/DPA_de.pdf), [Subunternehmer](https://www.hetzner.com/AV/subunternehmer.pdf) und [TOMs](https://docs.hetzner.com/de/general/security-and-identify/technical-and-organizational-measures/).
- Resend: [DPA](https://resend.com/legal/dpa), [Subprozessoren](https://resend.com/legal/subprocessors), [Regionen/Data Residency](https://resend.com/docs/dashboard/domains/regions), [Security/Backups](https://resend.com/docs/security) und [E-Mail-Retention](https://resend.com/docs/dashboard/webhooks/how-to-store-webhooks-data).

## C. Frist- und Löschmatrix

Die Anwendung enthält einen fail-closed Löschservice, Legal Holds, Export und
Tombstones. Automatisierung wird erst aktiviert, wenn diese Matrix freigegeben
ist.

| Datenklasse | Startpunkt | Frist | Löschart / Ausnahme | Freigabe |
| --- | --- | --- | --- | --- |
| Erfolglose Anfrage | Abschluss/letzter Kontakt | **sechs Monate** | anschließend löschen/anonymisieren; nur bei laufendem Anspruchs-, Beschwerde- oder Incident-Hold länger halten | Betreiberentscheidung vom 21.07.2026; Automatisierung und Test offen |
| Auftrag, Angebot, Kommunikation | Vertragsende/letzte Korrespondenz | **bis Ablauf von drei Jahren ab Ende des Abschlussjahres** | anschließend fachliche Daten minimieren/löschen; gesetzliche Geschäftsbrief-/Steuer- und Anspruchsfristen gehen vor | vorläufige Betreiberentscheidung vom 21.07.2026; Rechts-/Steuerprüfung, Automatisierung und Test offen |
| Rechnung/Buchungsbeleg | Ende Ausstellungsjahr | **8 Jahre als aktuelle gesetzliche Basis; Sonderfälle prüfen** | unveränderbar halten, danach kontrolliert löschen | Steuerberatung offen |
| Sonstige steuerrelevante Unterlagen | Ende Entstehungsjahr | sechs oder zehn Jahre je Einordnung; offen | AO-Einordnung dokumentieren | Steuerberatung offen |
| Uploads/Freitext | Löschung der zugehörigen Anfrage, des Angebots oder Auftrags | **identisch mit der zugehörigen Datenklasse** | Datei, Blob und Freitext gemeinsam löschen; nur bei dokumentiertem Hold länger halten | Betreiberentscheidung vom 21.07.2026; Automatisierung und Test offen |
| HTTP-/Proxylogs und Systemjournale | Erhebung | **maximal 30 Tage und maximal 500 MB für systemd-Journale** | automatisch rotieren; kein Roh-PII-Export; Zapfe-Docker-Logs sind je Datei auf 10 MB begrenzt | Journald-Konfiguration am 21.07.2026 aktiviert und mit 494,1 MB belegtem Speicher verifiziert; hostweite Prüfung alter, nicht zu Zapfe gehörender Container-Logs separat |
| Security-Audit | Ereignis | offen | pseudonymisiert; Incident-Hold | offen |
| Push-Abonnement | Abmeldung/Offboarding | unverzüglich plus technischer Nachlauf offen | Subscription und Schlüssel löschen | offen |
| Umami-Analytik | Erhebung | offen | Live-System und Backups einschließen | offen |
| Backups | Backupdatum | Generationenstaffel offen | verschlüsselt löschen; Tombstone-Nachlauf | offen |

## D. Betriebs- und Wiederanlaufnachweise

| Findings | Vor Go-live tatsächlich durchzuführender Nachweis | Status |
| --- | --- | --- |
| OPS-001 | Verschlüsseltes Offsite-Backup aktueller produktionsnaher Daten; isolierter Full-Restore einschließlich Dateien, Login, Rechnungen und Tombstone-Nachlauf; gemessene RPO/RTO. | **TEILWEISE – am 20.07.2026 verschlüsselter Offsite-Upload und isolierter Integritäts-Restore mit sechs SQLite-Datenbanken/258 Dateien erfolgreich. Der erste automatische Lauf am 21.07.2026 war erfolgreich. Beschlossen: täglich 03:30 Uhr Europe/Berlin, 30 tägliche Sicherungen, RPO 24 h, RTO 4 h. Die getestete automatische Aufbewahrung läuft täglich um 03:50 Uhr Europe/Berlin. Anwendungsstart sowie Login-/Rechnungs-/Tombstone-Stichprobe bleiben offen.** |
| OPS-005/006 | Externer Monitor ruft Liveness, Deep Health und Synthetic auf; Testalarm erreicht Rufbereitschaft; Incident-/Breach-Tabletop mit Zeitstempeln und Stellvertretung. | **TEILWEISE – Uptime Kuma läuft produktiv auf demselben Host wie Zapfe und prüft `zapfe.jetzt` per HTTP jede Minute. Der Telegram-Alarm `duzend_monitoring_bot` ist am 21.07.2026 dem Monitor zugeordnet und mit einem absichtlich fehlschlagenden, danach gelöschten Testmonitor erfolgreich getestet. Ein externer, unabhängiger Check für Server-/Netzausfall, Deep-Health-/Synthetic-Monitore und ein Incident-/Breach-Tabletop bleiben offen; die externe Monitor-Einrichtung wurde vom Betreiber am 21.07.2026 bewusst zurückgestellt.** |
| OPS-008/009/012 | Single-Node-Risiko schriftlich akzeptieren; Disk-/DB-/Upload-Budgets, Wartungsfenster und gemessener repräsentativer Lasttest; SQLite-Check/Checkpoint und Restore protokollieren. | offen |
| OPS-010 | Produktionsimage in Organisationsregistry mit OIDC-Provenance signieren und Signatur gegen dokumentierten Trust-Root verifizieren. | offen |
| OPS-011 | Dedizierten Deploy-User, nicht persönlichen Key, Firewall, SSH-Härtung, Patchprozess und Rotation am echten Host nachweisen. | offen |
| QUAL-001 | GitHub-Branch-Protection mit verpflichtenden Rails-, System-, Browser-/axe-, Security- und Imagechecks aktivieren und einen absichtlich roten Probe-PR blockieren lassen. | offen |

Verbindliche Werte, die der Betreiber eintragen muss:

- RPO: **24 Stunden**; RTO: **4 Stunden**.
- Backupfrequenz/-staffel und Offsite-Region: **täglich 03:30 Uhr Europe/Berlin, 30 tägliche Sicherungen, Falkenstein (Deutschland)**.
- Alarmempfänger: `info@zapfe.jetzt`, `ape2tap.blackforest@gmail.com` und Telegram `duzend_monitoring_bot` (Testnachricht am 21.07.2026 angekommen); Leopold Schmid primär, Johannes Wiese Vertretung. Beide Postfächer werden an Werktagen mindestens täglich geprüft (Betreiberbestätigung vom 21.07.2026). Bei Sicherheitsvorfall, möglichem Datenleck oder Ausfall: beide Kanäle sofort benachrichtigen; erste Einschätzung am selben Werktag, spätestens innerhalb von 24 Stunden. Bei bestätigtem Datenschutzvorfall wird innerhalb dieser Einschätzung die Meldepflicht einschließlich der 72-Stunden-Frist geprüft.
- Akzeptiertes monatliches SLO und Wartungsbudget: **offen**.
- Erwartete Spitzenlast, Datenwachstum und Uploadvolumen: **offen**.
- Recovery-Key-Owner: **Leopold Schmid**; dokumentierte Vertretung: **Johannes Wiese**. Tatsächlicher Zugriff der Vertretung im Passwortmanager: **am 20.07.2026 bestätigt**.

## E. Manuelle Accessibility-Freigabe

Automatisierte axe-/Keyboardtests sind grün. Vor einer Aussage zur vollständigen
Konformität sind mindestens zu protokollieren:

- Tastatur-only bei 200 % und 400 % Zoom sowie Reflow bei 320 CSS-Pixeln;
- NVDA/Firefox oder NVDA/Chrome unter Windows und VoiceOver/Safari auf iOS;
- Formularfehler, Statusmeldungen, Dialog-/Menüfokus und MFA;
- Aussagekraft aller Bildalternativen sowie Textalternative/Untertitel der
  Produktvideos;
- Kontrast in Hover, Fokus, Fehler, Disabled und High-Contrast/Forced-Colors;
- Freigabe einer BFSG-Information, falls der Scopecheck das verlangt.

Tester, Datum, Browser/AT-Version, Befunde und Retest: **offen**.

## F. Datenschutz- und Incident-Abnahme

Vor Freigabe müssen folgende Artefakte mit Owner, Version und Reviewdatum
vorliegen:

1. freigegebenes VVT auf Basis von `privacy_processing_inventory.md`;
2. freigegebene TOMs einschließlich Berechtigungsreview und Offboarding;
3. ausgefülltes Auftragsverarbeiter-/Transferregister inklusive TIA;
4. freigegebene Art.-13-Hinweise und Version im Anfrageformular;
5. dokumentiertes DPIA-Screening mit Entscheidung;
6. getesteter Export-/Berichtigungs-/Löschprozess und sicherer Antwortkanal;
7. Incidentkontakte, zuständige Aufsicht und jährliches Breach-Tabletop;
8. Nachweis, dass Umami-Livebetrieb und Browserstorage der freigegebenen
   §-25-TDDDG-/Art.-6-Entscheidung entsprechen.

## Go/No-Go-Unterschriften

| Rolle | Name | Entscheidung | Datum / Signatur / Beleg |
| --- | --- | --- | --- |
| Geschäftsführung | offen | NO-GO bis ausgefüllt | offen |
| Datenschutz | Leopold Schmid; Vertretung Johannes Wiese | NO-GO bis ausgefüllt | Rollen am 21.07.2026 bestätigt; Freigabe offen |
| Security/Betrieb | Leopold Schmid; Vertretung Johannes Wiese | NO-GO bis ausgefüllt | Rollen am 21.07.2026 bestätigt; Freigabe offen |
| Steuerberatung | offen | NO-GO bis ausgefüllt | offen |
| Rechtsprüfung | offen | NO-GO bis ausgefüllt | offen |

## G. Minimale Betreiberantwort für die nächste Remediationrunde

Die folgenden zehn Punkte reichen aus, um die verbleibenden Gates eindeutig zu
routen. Zu jeder Antwort gehört ein Beleglink oder eine Dokument-ID; sensible
Verträge und Secrets gehören nicht ins Repository.

1. **Gesellschaft – beantwortet am 20.07.2026:** Firma, Anschrift,
   Geschäftsführer, Amtsgericht Freiburg/HRB 731370 und DE369035041 wurden vom
   Betreiber als aktuell korrekt bestätigt. Aktueller Registerauszug und
   Steuer-/VIES-Nachweis sind noch als interne Beleg-IDs nachzutragen.
2. **Größe – beantwortet am 20.07.2026:** keine fest angestellten Personen und
   keine Gehaltszahlungen an die drei Gesellschafter. Alle drei Gesellschafter
   arbeiten relativ regelmäßig mit meist deutlich weniger als zehn Stunden pro
   Woche; Unterbrechungen von ein bis zwei Wochen kommen vor. Für die vorsichtige
   Größenprüfung werden daher ungefähr drei tätige Personen angesetzt. Umsatz
   2025 ungefähr 1.500 EUR, Prognose 2026 bis ungefähr 3.000 EUR und Bilanzsumme
   unter 10.000 EUR. Die Angaben sprechen deutlich für ein Kleinstunternehmen;
   interne Finanzbeleg-ID und rechtliche Bestätigung der konkreten
   BFSG-Dienstleistungsausnahme bleiben nachzutragen.
3. **Kunden/Vertrag – teilweise beantwortet am 20.07.2026:** bislang zwei
   Betriebsfeste mit direkter Vermietung an Unternehmen (B2B), montags
   Direktverkauf an Mitglieder auf einem Golfplatz (B2C) sowie eine Handvoll
   selbst organisierter Events mit jeweils weniger als 400 EUR Umsatz direkt
   mit Endkunden (B2C). Mangels belastbarer Fallzahl wird keine prozentuale
   Verteilung angegeben. Behördenkunden wurden nicht genannt. Vertragsschluss:
   B2B bislang per E-Mail mit Bestätigung, aber noch nicht formalisiert;
   Golfplatzverkauf bei Kartenzahlung unmittelbar vor dem Zapfen; selbst
   organisierte Events vor Ort. Offen bleibt eine einfache schriftliche
   Standardisierung des B2B-Prozesses.

   **VSBG-Entscheidung am 20.07.2026:** keine freiwillige Teilnahme an einem
   Verbraucherschlichtungsverfahren. Bei höchstens drei tätigen Personen liegt
   die Gesellschaft nach der Betreiberangabe unter der Ausnahme des § 36 Abs. 3
   VSBG für die allgemeine Information auf der Webseite. Falls eine konkrete
   Streitigkeit aus einem Verbrauchervertrag nicht beigelegt werden kann, muss
   vor der Antwort an den Kunden der Textform-Hinweis nach § 37 VSBG anhand der
   dann zuständigen Verbraucherschlichtungsstelle geprüft und versendet werden.
   Eine abweichende gesetzliche Teilnahmeverpflichtung oder Rechtsprüfung geht
   dieser Betreiberentscheidung vor.
4. **Hetzner – teilweise beantwortet am 20.07.2026:** Hetzner Cloud CX22 in
   EU Central Helsinki (Finnland). Ein separater AVV/DPA für die
   ape2tap UG (haftungsbeschränkt) wurde am 20.07.2026 im Hetzner-Konto
   abgeschlossen; ein vorhandener privater AVV bleibt davon getrennt. Interne
   Account-/Vertrags-ID ist noch offen. Als Offsite-Ziel wurde am 20.07.2026
   die Storage Box `u635934.your-storagebox.de` in Falkenstein (Deutschland)
   angelegt. Der getrennte Zapfe-Subaccount `u635934-sub1` mit dediziertem
   Server-Schlüssel wurde erfolgreich getestet. Die außerhalb des Servers
   erzeugte age-Recovery-Identity ist beim Betreiber gesichert; öffentlicher
   Empfänger: `age1ulregnk00jaac402gsea3zjjudd9mf68v9vv35n4w8dl93zlw5qqvgddng`.
   Recovery-Key-Owner ist Leopold Schmid, Vertretung Johannes Wiese; deren
   Passwortmanagerzugriff wurde am 20.07.2026 bestätigt.
   Das verschlüsselte Archiv `zapfe-storage-2026-07-20T190500Z.tar.gz.age`
   wurde unter `zapfe/2026-07-20/` mit SHA-256
   `9802413c0b699826d43ab097393f67ba5a002fa3d34918404152c65c4f93f7f9`
   hochgeladen und in einem isolierten Verzeichnis mit sechs SQLite-Datenbanken
   und 258 Dateien erfolgreich wiederhergestellt. Offen bleiben Anwendungsstart
   sowie Login-/Rechnungs-/Tombstone-Stichprobe, RPO/RTO, Automatisierung,
   Aufbewahrung und Schlüsselvertretung. Sensible
   Vertragsunterlagen gehören nicht ins Repository.
5. **Resend – teilweise beantwortet am 21.07.2026:** aktiv vor allem für
   Bestätigungs-E-Mails zu Kontaktanfragen. Die Betreiberentscheidung erlaubt
   Resend ausschließlich für notwendige transaktionale E-Mails; Marketing- und
   Werbetracking sind nicht freigegeben. Der Anwendungscode aktiviert kein
   Öffnungs- oder Klicktracking. DPA-Akzeptanzdatum, Versandregion und
   Content-Storage-Status im konkreten Account bleiben zu belegen; die
   vereinfachte Transfer-Risikoabwägung ist noch zu dokumentieren.
6. **Weitere Provider:** Betreiber und Accountnachweise für Umami, Push,
   Mailbox/Clients und Monitoring; nicht benötigte Dienste als deaktiviert
   bestätigen.
7. **Datenschutz:** benannte verantwortliche Person/Stellvertretung,
   freigegebene Fristmatrix, DPIA-Screening und zuständiger Rechte-/Breach-Kanal.
8. **Steuer/Recht:** Dokument-IDs der Freigaben für Rechnung/E-Rechnung,
   Archiv/Korrektur sowie DDG/MStV, VSBG, BFSG, Fernabsatz und PAngV.
9. **Betrieb:** RPO/RTO, SLO, Alarmempfänger, Recovery-Key-Owner sowie Links auf
   Full-Restore-, Alarm-, Host-Härtungs-, Last- und Registry-Signaturprotokolle.
10. **Accessibility/GitHub:** manuelles AT-/Zoom-/Reflow-Protokoll und Beleg für
    verpflichtende Branch-Protection-Checks samt blockiertem Probe-PR.
