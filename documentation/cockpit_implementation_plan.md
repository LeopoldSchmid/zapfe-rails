# Zapfe-Auftragszentrale – Implementierungsplan

**Dokumentstatus:** Entwurf / lebendes Quelldokument – fachliche Entscheidungen bis einschließlich Phase 3 eingearbeitet; Phase 4, Phase 5 und spätere Integrationen bleiben teilweise offen  
**Stand:** 2026-07-14  
**Vorgeschlagener Repository-Pfad:** `documentation/order_management_roadmap.md`  
**Verantwortung:** Zapfe-Entwicklerteam  

> **Implementierungsstand 2026-07-15:** Phasen 1 bis 3 sind als nutzbarer Arbeitsstand umgesetzt und auf Staging erprobt. Phase 4 besitzt bereits Rechnungsentwurf, Finalisierung, PDF, Versandbestätigung und Zahlungseingang, benötigt aber noch die fachliche Endabnahme. Die verbleibende Arbeit wird in dieser Reihenfolge erledigt: MVP-Härtung (inklusive Beschaffungs-/Dokumentenfälle und Betriebskonzept), mobile Optimierung, PWA, Push und danach die späteren Integrationen. Die nachfolgenden historischen Checkboxen werden schrittweise auf diesen Stand nachgezogen; sie sind kein verlässlicher Live-Fortschrittsindikator mehr.

## 1. Zweck dieses Dokuments

Dieses Dokument beschreibt die schrittweise Erweiterung von `zapfe-rails` zu einer internen Auftragszentrale. Es ist gleichzeitig:

- fachliche Zielbeschreibung,
- technische Roadmap,
- priorisierter Arbeitsvorrat,
- Sammlung offener Entscheidungen,
- Fortschritts- und Entscheidungsprotokoll.

Es soll vor jeder größeren Phase aktualisiert werden. Einzelne Punkte werden erst umgesetzt, nachdem der relevante Bestandscode analysiert und offene fachliche Fragen geklärt wurden.

### Statuskonvention

- `[ ]` noch nicht begonnen
- `[~]` in Arbeit
- `[x]` abgeschlossen
- `[!]` blockiert oder Entscheidung erforderlich

---

## 2. Ausgangslage im aktuellen Repository

Der aktuelle Stand von `zapfe-rails` wurde für dieses Dokument anhand des Hauptbranches betrachtet.

Vorhanden sind insbesondere:

- Rails 8.1 mit Hotwire, Turbo, Stimulus und Tailwind,
- servergerenderter öffentlicher Bereich und eigener Adminbereich,
- Admin-Authentifizierung über `AdminUser`; mehrere interne Konten sind im Datenmodell grundsätzlich möglich, eine vollständige Benutzerverwaltung, Deaktivierung und Änderungszuordnung fehlen jedoch noch,
- öffentliche Anfragen als `Inquiry`, inklusive Kalkulations-Snapshot,
- Produkte, Kategorien und Produktvarianten mit Verkaufspreisen,
- bisher noch keine strukturierte Abbildung von Lieferanten, mehreren Einkaufspreisen, Lieferzeiten, Rückgaberegeln oder lieferantenspezifischer Verfügbarkeit,
- teilweise historisch gewachsene Produkt-Metadaten, deren tatsächliche Nutzung und Datenqualität vor einer Erweiterung geprüft werden müssen,
- Action Mailer über Resend; die geschäftlichen Mailadressen liegen bei IONOS, Gmail wird derzeit lediglich als Mail-Client genutzt,
- Active Storage,
- Solid Queue, Solid Cache und Solid Cable,
- Minitest, Rails-Systemtests und Playwright,
- von Rails angelegte PWA-Dateien für Manifest und Service Worker, bisher jedoch ohne produktive Aktivierung.

Relevante bestehende Stellen:

- `Gemfile`
- `config/routes.rb`
- `db/schema.rb`
- `app/models/inquiry.rb`
- `app/controllers/inquiries_controller.rb`
- `app/controllers/admin/base_controller.rb`
- `app/views/layouts/admin.html.erb`
- `app/views/pwa/manifest.json.erb`
- `app/views/pwa/service-worker.js`
- `documentation/testing.md`

Noch nicht vorhanden sind eine eigentliche Auftragsverwaltung, Angebotsversionen, Auftragspositionen, Rechnungen, Ressourcenreservierungen, operative Checklisten sowie eine strukturierte Beschaffungsplanung über mehrere Getränkehändler und andere Bezugsquellen.

---

## 3. Produktziel

Zapfe soll einen Vorgang von der ersten Anfrage bis zum abgeschlossenen Auftrag in einer Anwendung begleiten. Anfrage und Auftrag bleiben dabei bewusst getrennte fachliche Phasen:

```text
Anfrage
  → neu / in Bearbeitung
  → wartet auf Kunde oder extern
  → manuelle Entscheidung durch das Team:
      ├─ in Auftrag umwandeln
      └─ ohne Auftrag abschließen

Auftrag (genau eine Veranstaltung)
  → Klärung und Kalkulation
  → versioniertes Angebot
  → Zusage
  → Vorbereitung
  → Veranstaltung
  → Rückgabe und Prüfung
  → Rechnung
  → Zahlung und Abschluss
```

Nicht jede Anfrage soll die Auftragsübersicht füllen. Eine neue Anfrage darf zunächst unzugewiesen sein, muss dann aber sichtbar und bewusst von einem Teammitglied übernommen werden. Ab der Übernahme ist sie ein aktiv betreuter Vorgang mit Verantwortlichem, Status und nächstem Schritt.

Die Anwendung soll für ein nebenberufliches Dreierteam sofort verständlich bleiben und gleichzeitig mit weiteren Produkten, Aufträgen und internen Mitarbeitenden wachsen können. Jede intern arbeitende Person soll ein eigenes Admin-Konto verwenden; gemeinsame Sammelzugänge sind nicht vorgesehen.

### Erfolgsbild des ersten nutzbaren Produkts

Ein Teammitglied kann:

1. eine neue Anfrage sichtbar als noch unzugewiesen erkennen, sie bewusst einem internen Verantwortlichen zuordnen und ihren Bearbeitungsstand verfolgen,
2. erkennen, ob Zapfe, der Kunde oder eine externe Stelle als Nächstes handeln muss,
3. eine Anfrage zu einem fachlich passenden Zeitpunkt manuell in einen Auftrag umwandeln oder ohne Auftrag abschließen,
4. pro Auftrag genau eine Veranstaltung verwalten,
5. mehrere Angebotsvarianten und nachvollziehbare Angebotsversionen kalkulieren,
6. Produkte und freie Positionen hinzufügen,
7. interne Kosten, begründete Rabatte und Deckungsbeitrag sehen,
8. bei Bedarf unterschiedliche Bezugsquellen und Einkaufskonditionen vergleichen,
9. eine Angebotsversion als PDF festschreiben und versenden,
10. die angenommene Variante als Grundlage des weiteren Auftrags verwenden,
11. konkrete einzelne Ressourcen wie `Ape #1` oder `Kegerator #1` reservieren,
12. automatische Standardaufgaben und zusätzliche manuelle Aufgaben mit Fälligkeiten verwalten,
13. chronologische Notizen, Dateien und relevante Kommunikation direkt an Anfrage beziehungsweise Auftrag nachvollziehen,
14. geplante und tatsächliche Arbeitszeit einschließlich interner Kosten erfassen,
15. mit einem persönlichen internen Admin-Konto arbeiten und erkennen, wer wichtige Änderungen vorgenommen hat.

---

## 4. Bewusste Nicht-Ziele für den ersten Ausbau

Folgende Themen werden nicht in die erste Version gepackt:

- vollständiges Kundenportal,
- automatische Onlinebuchung ohne persönlichen Kontakt,
- komplexe Warenwirtschaft,
- vollständige Finanzbuchhaltung oder automatische Bankbuchung; ein separates Financial Cockpit bleibt eine spätere Ausbaustufe,
- native Android- oder iOS-App,
- komplexe Rollen- und Rechtehierarchien; die grundlegende Mehrbenutzerfähigkeit mit persönlichen internen Admin-Konten gehört dagegen zum Kern,
- vollständige Synchronisation eingehender E-Mails in der ersten Ausbaustufe,
- KI-Automatisierung vor einem stabilen Grundprozess.

Sie bleiben mögliche spätere Ausbaustufen.

---

## 5. Architekturprinzipien

### 5.1 Rails-Monolith beibehalten

Die Auftragszentrale wird in die bestehende Rails-Anwendung und den vorhandenen Adminbereich integriert. Es entsteht zunächst kein separates Frontend, kein separates Backend und keine zusätzliche Datenquelle als führendes System.

### 5.2 Hotwire zuerst

Neue Oberflächen werden serverseitig mit Rails Views, Turbo Frames/Streams und kleinen Stimulus-Controllern umgesetzt. Größere JavaScript-Komponenten werden nur eingeführt, wenn Hotwire den konkreten Anwendungsfall nicht sinnvoll abbildet.

### 5.3 Anfrage und Auftrag sind getrennte Arbeitsphasen

`Inquiry` bleibt nicht nur ein passiver Formulareingang, sondern bildet die aktive Anfragephase ab. Eine neu eingehende Anfrage darf zunächst **unzugewiesen** sein. Es gibt bewusst keine automatische Verteilung per Standardperson oder Round-Robin. Die fehlende Zuständigkeit muss jedoch in Liste und Dashboard deutlich sichtbar sein, damit ein Teammitglied die Anfrage aktiv übernimmt.

Sobald eine Anfrage bearbeitet wird, besitzt sie mindestens:

- einen verantwortlichen `AdminUser`,
- einen einfachen Bearbeitungsstatus,
- einen nächsten Schritt mit optionaler Fälligkeit,
- eine nachvollziehbare Historie wichtiger Änderungen.

Die ersten Anfrage-Status sind:

```text
neu / in Klärung / wartet auf Kunde / wartet extern /
abgeschlossen / verworfen
```

Die ersten Auftrags-Status sind:

```text
in Vorbereitung / angeboten / beauftragt /
in Durchführung / abgeschlossen / storniert
```

Technisch werden stabile englische Werte verwendet, die Oberfläche zeigt die deutschen Bezeichnungen. Die Status bleiben bewusst schlank und können später anhand realer Nutzung erweitert werden.

Die Umwandlung in einen `Order` erfolgt manuell durch ein Teammitglied. Sie ist nicht fest an Angebotsversand, mündliche Zusage oder schriftliche Bestätigung gekoppelt, da der passende Zeitpunkt je Fall unterschiedlich sein kann. Die Umwandlung muss idempotent sein; eine Anfrage darf nicht versehentlich mehrfach in Aufträge überführt werden.

Beim Umwandeln werden alle vorhandenen fachlichen Daten übernommen beziehungsweise weiter verknüpft: Kontaktdaten, Veranstaltungsdaten, Notizen, Dateien, Verantwortlicher und die Beziehung zur ursprünglichen Anfrage. Nach der Umwandlung ist `Order` die zentrale Klammer für Kalkulation, Angebote, Aufgaben, Reservierungen, Dokumente und Rechnungen. Ein Auftrag steht zunächst immer für genau eine Veranstaltung.

### 5.4 Fachliche Dokumente werden versioniert und festgeschrieben

Entwürfe dürfen geändert werden. Versandte Angebote und finalisierte Rechnungen dürfen nicht stillschweigend nachträglich verändert werden.

Beim Festschreiben werden mindestens gespeichert:

- Empfängerdaten,
- Positionstexte,
- Mengen und Einheiten,
- Einzelpreise,
- Rabatte,
- Steuersätze,
- Summen,
- Dokumentnummer,
- Erstellungszeitpunkt,
- erzeugte Datei.

Spätere Änderungen erzeugen eine neue Angebotsversion oder ein Korrekturdokument. Angebotsversionen werden nicht überschrieben, weil sie den jeweiligen Verhandlungs- und Abstimmungsstand mit dem Kunden dokumentieren.

### 5.5 Katalog und Dokument-Snapshot trennen

Katalogpreise, Einkaufspreise und Lieferantenkonditionen können sich ändern. Bereits erstellte Angebote und Rechnungen dürfen dadurch nicht verändert werden. Eine Position kann auf ein vorhandenes Produkt oder eine Lieferantenkondition verweisen, speichert aber zusätzlich ihre damaligen Werte als Snapshot. Das gilt ebenso für Rabattart, Rabattbetrag beziehungsweise -satz, sichtbare Rabattbegründung und interne Kostenannahmen.

### 5.6 Produkt, Produktvariante, Bezugsquelle und Beschaffungsprofil trennen

Ein Produkt beschreibt die Getränkesorte beziehungsweise den kanonischen Artikel, zum Beispiel „Waldhaus Naturtrüb“. Eine `ProductVariant` beschreibt das konkrete Gebinde, zum Beispiel 20, 30 oder 50 Liter. Dieselbe Produktvariante wird nicht pro Händler dupliziert.

Die Lieferantenbeziehung wird separat modelliert:

```text
Product: Waldhaus Naturtrüb
  └─ ProductVariant: 30-Liter-Fass
       ├─ SupplierOffering: Südstar
       │    └─ ProcurementProfile: Südstar / Lagerware
       └─ SupplierOffering: Getränke Beck
            └─ ProcurementProfile: Beck / Lieferware
```

`SupplierOffering` verknüpft einen Händler mit genau einer kanonischen Produktvariante. Händlerinterne Artikelnummern oder SKUs liegen an dieser Beziehung und ändern nicht die Identität der Produktvariante.

Typische Vorlauf- und Rückgaberegeln werden nicht bei jeder Variante erneut eingetippt. Jeder Händler kann eigene wiederverwendbare **Beschaffungsprofile** definieren, zum Beispiel:

- Lagerware,
- Bestellware,
- Sonderbestellung,
- Lieferware mit Kühlung.

Ein Beschaffungsprofil kann mindestens enthalten:

- Bezeichnung,
- Vorlaufzeit in Tagen,
- Rückgabe möglich: ja, nein oder unbekannt,
- optionale Storno- oder Rückgabenotiz,
- optionale Hinweise zu Lieferung, Mindestbestellwert oder externer Ausstattung.

Eine `SupplierOffering` verweist auf eines dieser Profile und kann Regeln für echte Sonderfälle überschreiben. Dadurch kann etwa Augustiner bei Südstar mit 14 Tagen Vorlauf und ohne Rückgabe anders behandelt werden als eine gewöhnliche Lagerware, ohne dieselben Regeln bei jeder Variante zu duplizieren.

Einkaufspreise liegen an der Händler-Produktvarianten-Beziehung und werden historisiert. Ein Preis besitzt mindestens ein `valid_from`; eine Preisänderung erzeugt einen neuen gültigen Stand, statt alte Kalkulationen rückwirkend zu verändern. Beim Finalisieren eines Angebots werden Einkaufspreis, Beschaffungsprofil und alle Kostenannahmen zusätzlich als Snapshot eingefroren.

Als erste Lieferanten-Stammdaten werden angelegt:

1. Getränkemarkt Südstar als konfigurierbarer Standard,
2. Getränke Beck als zweite Bezugsquelle.

Der Standardlieferant wird nicht im Code fest verdrahtet. Die Kalkulation darf aus passenden Angeboten automatisch die voraussichtlich günstigste oder organisatorisch geeignetste Bezugsquelle anzeigen; die verbindliche Auswahl bleibt eine bewusste Entscheidung des Teams.

### 5.7 Verfügbarkeit im MVP aus Bezugsangebot und Beschaffungsprofil ableiten

Im ersten Ausbau gibt es keine zweite, parallel gepflegte Statuslogik für „aktuell verfügbar“, wenn dieselbe Information bereits durch vorhandene `SupplierOffering`s und deren Beschaffungsprofile ausgedrückt wird.

Für das MVP gilt:

- Existiert eine aktive `SupplierOffering`, führt der Händler die Produktvariante grundsätzlich.
- Das zugeordnete Beschaffungsprofil beschreibt Vorlauf und Rückgaberegel.
- Fehlt eine belastbare Information, kann dies als Notiz beziehungsweise unbekanntes Profil dokumentiert werden.
- Eine konkrete telefonische oder schriftliche Lieferzusage kann später am Beschaffungsvorgang beziehungsweise als Anlage dokumentiert werden.

Eine echte Live-Lagerverfügbarkeit wird erst ergänzt, wenn dafür eine verlässliche Händlerquelle existiert. Dadurch vermeiden wir doppelte, schnell widersprüchliche Pflege.

### 5.8 Bestehenden Getränkekatalog gezielt bereinigen

Vor einer Erweiterung des Produktmodells wird geprüft:

- welche vorhandenen Felder im aktuellen Code und im Adminbereich tatsächlich genutzt werden,
- welche Felder nur aus dem Altprojekt übernommen wurden,
- welche Werte uneinheitlich oder unvollständig sind,
- welche Informationen produktbezogen und welche lieferantenbezogen sind,
- ob Getränke, Mietartikel und Dienstleistungen langfristig in einem gemeinsamen Katalog oder in getrennten Modellen geführt werden sollen.

Nicht genutzte Felder werden nicht vorschnell weiter ausgebaut. Für erforderliche Änderungen wird eine kleine Migrations- und Bereinigungsstrategie erstellt, damit vorhandene Produktdaten erhalten bleiben.

### 5.8.1 Vermietressourcen als einzelne physische Objekte

Zapfe-eigene vermietbare Geräte werden als einzelne `Resource`-Objekte geführt, zum Beispiel `Ape #1` oder `Kegerator #1`.

Für das Ressourcen-MVP reichen zunächst:

- interne Bezeichnung,
- Ressourcentyp,
- aktiv oder inaktiv,
- optionale Konfigurationsnotiz, beispielsweise montierter Zapfkopf,
- optionale allgemeine Notiz.

Eine Ressource kann einem Auftrag beziehungsweise Angebot zugeordnet und für einen konkreten Zeitraum reserviert werden. Eine Kalenderansicht zeigt, welche konkrete Einheit wann verfügbar oder belegt ist. Doppelbuchungen werden verhindert oder unübersehbar gewarnt.

Automatische Pufferzeiten für Reinigung, Transport oder Wartung werden zunächst nicht eingeführt. Wartungs- und Reinigungshistorien sowie detaillierte Zustände bleiben spätere Erweiterungen.

### 5.9 Einfache, explizite Businesslogik

Für zentrale Aktionen werden kleine, klar benannte Services oder Commands verwendet, zum Beispiel:

- `Orders::CreateFromInquiry`
- `Offers::Duplicate`
- `Offers::Finalize`
- `Offers::SendToCustomer`
- `Invoices::CreateFromOrder`
- `Invoices::Finalize`
- `Invoices::BuildXRechnung`
- `Invoices::ValidateXRechnung`

Die genauen Namen werden bei der jeweiligen Phase geprüft. Eine zusätzliche State-Machine- oder Workflow-Bibliothek wird erst eingeführt, wenn die Übergänge tatsächlich komplex genug sind.

### 5.10 Seiteneffekte über Jobs

E-Mail-Versand, Push-Nachrichten und gegebenenfalls aufwendige Dokumenterzeugung sollen über Active Job und Solid Queue laufen. Kritische Zustandsänderungen müssen trotzdem transaktional und wiederholbar sein.

### 5.11 Aufgaben, relative Fälligkeiten und Checklisten

Das System unterstützt:

- automatisch erzeugte Standardaufgaben aus Vorlagen,
- jederzeit zusätzlich angelegte manuelle Aufgaben,
- vorerst nur auftragsbezogene Aufgaben; allgemeine wiederkehrende Betriebsaufgaben folgen später.

Eine Aufgabe beschreibt **was** erledigt werden muss. Eine Checkliste beschreibt **wie** diese Aufgabe ausgeführt wird.

Aufgaben besitzen Verantwortlichen, Status und Fälligkeit. Im MVP ist der erste fachliche Anker das Veranstaltungsdatum. Vorlagen können Abstände wie „14 Tage vorher“ oder „1 Tag danach“ definieren. Ändert sich das Veranstaltungsdatum, werden noch nicht manuell fixierte Fälligkeiten neu berechnet. Erinnerungen werden zunächst in der Anwendung beziehungsweise über Jobs vorbereitet und später zusätzlich über Web Push ausgeliefert.

Checklisten werden als wiederverwendbare Vorlagen an Aufgaben und Ressourcentypen gekoppelt. Als erste Strukturen werden vorgesehen:

- Ape packen,
- Ape aufbauen,
- Ape reinigen,
- Kegerator packen,
- Kegerator aufbauen,
- Kegerator reinigen.

Die konkreten Inhalte werden später gemeinsam ausgearbeitet. Jeder Checklistenpunkt kann optionale Hilfen enthalten:

- kurzen Anleitungstext,
- Bild beziehungsweise Datei,
- Link,
- Video-Link,
- zusätzliche Hinweise.

Dieses Hilfekonzept ist allgemein nutzbar und nicht auf Ape oder Kegerator beschränkt.

### 5.12 Interne Benutzerkonten und Nachvollziehbarkeit

`AdminUser` steht ausschließlich für interne Zapfe-Mitarbeitende. Kundenkonten sind nicht Teil dieses Modells.

Zu Beginn erhalten folgende Personen persönliche Konten:

- Leopold Schmid,
- Dennis Bühler,
- Johannes Wiese.

Alle drei aktiven Admins sind zunächst gleichberechtigt und dürfen weitere interne Admin-Konten anlegen, bearbeiten, deaktivieren und reaktivieren. Eine komplexe Rollenmatrix wird erst bei realem Bedarf ergänzt.

Jedes Konto besitzt mindestens:

- Name,
- E-Mail,
- aktiv oder deaktiviert,
- persönliche E-Mail-Signatur,
- persönliche Benachrichtigungseinstellungen,
- später eigene Push-Abonnements pro Gerät,
- optionale Telefonnummer.

Konten werden deaktiviert statt gelöscht, damit historische Zuständigkeiten und Aktivitäten erhalten bleiben. Gemeinsame Sammelzugänge sind nicht vorgesehen.

In der fachlichen Aktivitätshistorie werden im MVP mindestens protokolliert:

- Statuswechsel,
- Wechsel des Verantwortlichen,
- Finalisierung beziehungsweise Freigabe eines Angebots,
- Versand eines Angebots,
- Erstellung beziehungsweise Finalisierung einer Rechnung,
- Versand einer Rechnung,
- Erfassung eines Zahlungseingangs.

Jeder Eintrag enthält handelnden Admin und Zeitpunkt. Weitere Ereignisse werden ergänzt, wenn der reale Betrieb zeigt, dass sie für die Nachvollziehbarkeit wichtig sind.

### 5.13 Kommunikation, Chronik und Dateien

Ausgehende fachliche Kommunikation – insbesondere Angebote, Auftragsbestätigungen und Rechnungen – wird aus Zapfe versendet und als Aktivität am Vorgang protokolliert. Dabei werden mindestens Absender, Empfänger, Betreff, Dokumentbezug, Versandzeitpunkt und Status gespeichert.

Eingehende E-Mails bleiben zunächst im bestehenden Mail-Postfach. Eine spätere Integration wird **providerunabhängig** geplant und nicht an Gmail gekoppelt, da Gmail derzeit nur als Oberfläche für die bei IONOS gehosteten Mailadressen dient. Für die spätere Zuordnung werden stabile technische Merkmale vorgesehen, zum Beispiel eine Vorgangskennung in Reply-To-Adresse, Betreff oder Mail-Header. Ob die technische Anbindung später per IMAP, Weiterleitung an einen Inbound-Maildienst oder einer anderen Schnittstelle erfolgt, wird in einem eigenen Spike entschieden.

Die fachliche Chronik besteht aus vielen kleinen Einträgen statt einer einzigen überschreibbaren Freitextnotiz. Einträge enthalten Autor, Zeitpunkt, Typ und Inhalt. Dazu gehören insbesondere:

- Gesprächs- und Telefonnotizen,
- manuelle interne Notizen,
- Status- und Verantwortungswechsel,
- Versand von Dokumenten,
- später eingelesene oder manuell dokumentierte E-Mail-Kommunikation.

Im MVP dürfen fachlich relevante Bilder und PDF-Dateien an Anfrage oder Auftrag angehängt werden, zum Beispiel Fotos, unterschriebene Dokumente, externe Angebote, Bestellbestätigungen oder Übergabeprotokolle. Unterstützt werden zunächst PDF sowie gängige Bildformate; das Größenlimit beträgt 25 MB pro Datei. Die Binärdaten liegen in Active Storage; fachliche Metadaten und Berechtigungen bleiben im jeweiligen Vorgang. Die Aufbewahrung folgt grundsätzlich dem zugehörigen Vorgang und wird durch die DSGVO-Lösch- beziehungsweise Anonymisierungsstrategie ergänzt.

### 5.14 Kontakte bewusst einfach halten

In der ersten Version besitzt ein Auftrag einen primären Ansprechpartner beziehungsweise eine primäre Organisation als Snapshot. Mehrere Ansprechpartner mit Rollen wie Veranstaltung, Einkauf, Aufbau oder Buchhaltung werden erst eingeführt, wenn ein realer Bedarf entsteht.

Für einen Auftrag sind als Kundendaten nur ein Name oder eine Firma zwingend erforderlich. E-Mail-Adresse und Telefonnummer sind optional, da Anfragen auch über andere Kommunikationswege entstehen können. Rechnungsadresse und steuerrelevante Empfängerdaten werden spätestens vor Finalisierung einer Rechnung verpflichtend geprüft.

Beim Umwandeln einer Anfrage werden vorhandene Kontakt- und Veranstaltungsdaten vollständig übernommen. Das Datenmodell und die Dokumenterzeugung sollen eine spätere Mehrkontaktfähigkeit nicht unnötig erschweren.

### 5.15 Auftragswirtschaft und Unternehmensfinanzen trennen

Die Wirtschaftlichkeit eines Auftrags berücksichtigt direkte beziehungsweise variable Kosten, insbesondere Einkauf, Fremdmiete, Lieferung und Arbeitszeit. Fixkosten wie Versicherung, Stellplatz, Software oder Verwaltung werden nicht künstlich auf einzelne Aufträge verteilt.

Für den späteren Überblick über Gesamtunternehmen, Monat, Quartal und Jahr ist ein separates **Financial Cockpit** vorgesehen. Dieses darf Transaktionen und Exporte aus FINOM sowie später weitere Datenquellen importieren, kategorisieren und mit Auftragsumsätzen verbinden. Das Financial Cockpit ist analytisch und ersetzt keine Finanzbuchhaltung.

### 5.16 Wiederkehrende Veranstaltungen über Tags und konfigurierbare Vorlagen

Aufträge beziehungsweise Veranstaltungen können frei tagbar sein, zum Beispiel `Golfplatz`, `wiederkehrend` oder `Eigenveranstaltung`.

Vorlagen für Veranstaltungsreihen sind pro Reihe konfigurierbar. Sie können unter anderem:

- Felder vorausfüllen,
- Produkte und Ressourcen vorauswählen,
- typische Zeiten und Orte setzen,
- Aufgaben und Checklisten erzeugen,
- Verantwortliche vorauswählen,
- nicht benötigte Prozessschritte überspringen.

Welche Felder bei einer konkreten Reihe verwendet werden, wird nicht zentral fest verdrahtet. Für jede Durchführung entsteht weiterhin ein eigener Auftrag mit eigenem Datum, Reservierungen, Aufgaben, Kosten und Abschluss.

### 5.17 Arbeitszeit geplant und tatsächlich erfassen

Arbeitszeit wird als direkter Kostenfaktor mitgedacht. Pro Auftrag können Zeitaufwände zunächst geschätzt und nach der Durchführung tatsächlich erfasst werden.

Für den MVP werden zwei Kategorien verwendet:

- Organisation,
- Durchführung.

Zeitwerte besitzen Kategorie, Person, Dauer und einen internen Kostensatz. Zunächst genügt ein zentral konfigurierbarer Standardkostensatz; der konkrete Anfangswert wird vor produktiver Nutzung festgelegt. Geschätzte und tatsächliche Werte bleiben getrennt, damit spätere Angebote verbessert und Szenarien für Aushilfen oder Studierende gerechnet werden können.

### 5.18 Ressourcen-MVP: konkrete Einheit und Datumsreservierung

Ape und Kegerator werden als einzelne physische Ressourcen geführt. Eine Ressource kann Angebots- beziehungsweise Auftragspositionen zugeordnet und für den Veranstaltungszeitraum reserviert werden.

Für die erste nutzbare Version ist entscheidend:

- konkrete Einheit statt bloßer Menge,
- sichtbare Belegung im Ressourcen-Kalender,
- Warnung oder Blockierung bei Doppelbuchung,
- keine automatischen Pufferzeiten,
- kein vollständiger Wartungs- oder Zustandsworkflow als Voraussetzung.

Wartung, Reinigung, Defektstatus und Servicehistorie bleiben vorbereitet, werden aber erst später umgesetzt.

### 5.19 Operatives Dashboard statt Kennzahlenfriedhof

Das erste Dashboard beantwortet vor allem:

- Welche Veranstaltungen stehen als Nächstes an?
- Welche Anfrage ist noch keinem Verantwortlichen zugeordnet?
- Was ist als Nächstes zu tun?
- Welche Aufgabe oder Frist ist überfällig beziehungsweise bald fällig?
- Bei welchem Vorgang wartet Zapfe, der Kunde oder eine externe Stelle?

Ein zusammengesetzter Indikator „organisatorisch vollständig vorbereitet“ wird im MVP bewusst nicht eingeführt. Zunächst sollen konkrete offene Aufgaben und Fristen sichtbar sein. Ein solcher Indikator kann später aus realen Erfahrungen abgeleitet werden.

### 5.20 Bestehende Testkonventionen fortführen

- Businesslogik: Model- und Service-Tests
- Controller und Berechtigungen: Controller-/Integrationstests
- zentrale Admin-Flows: Rails-Systemtests oder Playwright
- Dokumente: strukturierte Inhalts- und Snapshot-Tests
- XRechnung: Validierung gegen eine offizielle Validator-Konfiguration

---

## 6. Vorgeschlagenes fachliches Modell

Die endgültige Struktur wird in Phase 0 gegen den aktuellen Code geprüft. Fachlich sind folgende Kernobjekte vorgesehen:

| Objekt | Aufgabe | Hinweis |
|---|---|---|
| `AdminUser` | Interner Mitarbeiterzugang | Persönliches Konto für Leopold Schmid, Dennis Bühler, Johannes Wiese und später weitere Mitarbeitende; alle drei Start-Admins zunächst gleichberechtigt |
| `Inquiry` | Aktive Anfragephase | Kann neu unzugewiesen eingehen; erhält bei Übernahme Verantwortlichen, Status, nächsten Schritt und Historie |
| `Order` | Zentrale Auftragsakte für genau eine Veranstaltung | Entsteht manuell aus Anfrage oder direkt; Status, Termin, Kunde, Zuständigkeit und nächster Schritt |
| `Offer` | Angebotsvariante und unveränderbare Version | Entwurf, finalisiert, versandt, angenommen, abgelehnt oder abgelaufen |
| `OfferLineItem` | Angebotsposition | Produktbezug optional; Netto-Verkaufspreis, Kosten, Rabatt und Beschaffungssnapshot |
| `Product` | Kanonisches Produkt | Getränkesorte beziehungsweise Grundartikel, unabhängig von Händler und Gebinde |
| `ProductVariant` | Konkretes Gebinde | Zum Beispiel 20-, 30- oder 50-Liter-Fass; gemeinsame Identität über alle Händler |
| `Supplier` | Bezugsquelle | Zunächst Getränkemarkt Südstar und Getränke Beck |
| `ProcurementProfile` | Wiederverwendbares Beschaffungsprofil eines Händlers | Händlerabhängige Vorlaufzeit, Rückgaberegeln und optionale Liefer-/Stornobedingungen |
| `SupplierOffering` | Händlerangebot für eine Produktvariante | Verknüpft Händler, Variante, Profil, Händler-SKU und zeitlich gültige Einkaufspreise |
| `SupplierPrice` oder Preisverlauf | Einkaufspreishistorie | Preis mit `valid_from`, optional `valid_until`; alte Stände bleiben nachvollziehbar |
| `ProcurementPlan` | Verbindliche Beschaffungsentscheidung pro Auftrag | Gewählte Quelle, Mengen, Snapshot, Bestellfrist und Status |
| Active-Storage-Anlage | Konkretes Händlerangebot oder sonstige Datei | Lieferantenangebote werden im MVP als Anlage beziehungsweise Notiz geführt, nicht als eigenes strukturiertes Objekt |
| `Invoice` | Rechnung | Nummer, Status, Fälligkeit, Zahlung und Finalisierung |
| `InvoiceLineItem` | Rechnungsposition | Unabhängiger Snapshot der tatsächlich berechneten Leistung |
| `Task` | Fachliches Was | Manuell oder aus Vorlage; Verantwortlicher, Status und relative/absolute Fälligkeit |
| `ChecklistTemplate` / `ChecklistItem` | Operatives Wie | Schritt-für-Schritt-Vorlagen, optional mit Text, Bild, Datei, Link oder Video |
| `Note` / `CommunicationEntry` | Chronologischer Eintrag | Telefonat, interne Notiz, ausgehende oder später eingehende E-Mail; Autor und Zeitpunkt |
| `Tag` / `Tagging` | Flexible Klassifikation | Freie Tags für Aufträge, Veranstaltungen und Vorlagen |
| `OrderTemplate` | Konfigurierbare Vorlage für eine Veranstaltungsreihe | Kann Felder, Ressourcen, Aufgaben und übersprungene Schritte je Reihe definieren |
| `TimeEntry` | Geplante oder tatsächliche Arbeitszeit | Kategorie `Organisation` oder `Durchführung`, Person, Dauer und Kostensatz |
| `Resource` | Einzelne physische Vermietressource | Name, Typ, aktiv/inaktiv und optionale Konfigurationsnotiz |
| `Reservation` | Zeitliche Belegung einer konkreten Ressource | Verknüpft Auftrag und einzelne Ressource; im MVP ohne automatische Pufferzeit |
| `Activity` | Fachliche Historie | Status-, Verantwortungs-, Dokument- und Zahlungsvorgänge mit Admin und Zeitpunkt |
| `PushSubscription` | Web-Push-Ziel | Erst in Phase 5 |
| spätere Finanzobjekte | Financial Cockpit | Banktransaktionen, Fixkosten und periodische Auswertungen; getrennt vom Auftrag |

### Noch zu analysierende, aber nicht mehr grundsätzlich offene Modellfragen

- Welche bestehenden Produktfelder werden nach der Code- und Datenanalyse behalten, umbenannt oder migriert?
- Werden Getränke, Zapfe-eigene Mietartikel, externe Mietartikel und Dienstleistungen langfristig in einem gemeinsamen Katalog oder in spezialisierten Modellen geführt?
- Nutzen Angebot und Rechnung getrennte Positionstabellen oder eine gemeinsame interne Dokumentpositionsabstraktion?
- Soll für Kundendaten zunächst ausschließlich ein Auftragssnapshot genügen oder lohnt früh ein kleines `Customer`-Modell?
- Wie wird die Pflichtbestätigung nicht rückgabefähiger Bestellungen technisch gestaltet?
- Welcher konkrete interne Standardkostensatz wird für Arbeitszeit eingetragen?
- Welcher PDF-Renderer passt am besten zum vorhandenen Deployment?

Diese Punkte sind Umsetzungsanalysen. Sie ändern die bereits beschlossene fachliche Richtung nicht.

### Bereits entschieden

- Anfrage und Auftrag bleiben getrennte Phasen.
- Neue Anfragen werden nicht automatisch verteilt; unzugewiesene Anfragen sind deutlich sichtbar und werden bewusst manuell übernommen.
- Die drei Start-Admins sind Leopold Schmid, Dennis Bühler und Johannes Wiese.
- Alle drei sind zunächst gleichberechtigt und dürfen interne Admin-Konten verwalten.
- Anfrage- und Auftragsstatus sind für den MVP fachlich festgelegt.
- Die Umwandlung in einen Auftrag erfolgt manuell und übernimmt vorhandene Daten.
- Ein Auftrag entspricht genau einer Veranstaltung.
- Kundenseitig sind zunächst nur Name oder Firma erforderlich; E-Mail und Telefon sind optional.
- Notizen sind chronologisch; relevante Bilder und PDFs bis 25 MB können angehängt werden.
- Angebote werden versioniert und finalisierte Werte eingefroren.
- Preise werden intern netto gepflegt; im MVP wird nur der konfigurierbare Standardsatz verwendet.
- Produkt und Gebindevariante werden getrennt; dieselbe Variante kann Angebote mehrerer Händler besitzen.
- Südstar ist erster Standardlieferant, Getränke Beck zweite Bezugsquelle.
- Vorlauf und Rückgaberegeln werden über händlerspezifische Beschaffungsprofile wiederverwendbar gepflegt.
- Einkaufspreise sind zeitlich gültig und historisiert.
- Separate Live-Verfügbarkeitsstatus werden im MVP vermieden, soweit Beschaffungsprofile dieselbe Aussage abdecken.
- Pfand, Lieferung, Fremdmiete und ähnliche Kosten können getrennt modelliert werden; im MVP bleiben kombinierte freie Kostenpositionen möglich.
- Arbeitszeit wird geplant und tatsächlich mit den Kategorien Organisation und Durchführung erfasst.
- Angebotsgültigkeit beträgt standardmäßig 14 Tage und ist pro Angebot änderbar.
- Bezugsquellen werden bei bestätigtem Auftrag vor der Beschaffung verbindlich ausgewählt; das System darf die beste passende Option vorschlagen.
- Beschaffungsstatus starten mit geplant, angefragt, bestätigt und erledigt.
- Lieferantenangebote werden zunächst als Anlage oder Notiz dokumentiert.
- Ressourcen sind konkrete Einheiten und werden kalenderbasiert reserviert; automatische Pufferzeiten entfallen zunächst.
- Aufgaben beschreiben das Was, Checklisten das Wie; Checklistenpunkte können Anleitungen und Medien verlinken.
- Veranstaltungsvorlagen sind je Reihe konfigurierbar.
- Ein expliziter Gesamtindikator „organisatorisch vorbereitet“ wird im MVP nicht gebaut.
- Im Alltag wird archiviert statt gelöscht; eine DSGVO-Lösch- und Anonymisierungsstrategie bleibt erforderlich.
- Zeitzone ist `Europe/Berlin`.
- Eine allgemeine CSV-Exportfunktion ist kein MVP-Ziel; eine belastbare Backup- und Restore-Strategie ist trotzdem erforderlich.


## 7. Roadmap

## Phase 0 – Bestandsanalyse und Architektur-Baseline

**Ziel:** Die beschlossenen fachlichen Entscheidungen werden gegen den tatsächlichen Hauptbranch geprüft und in ein tragfähiges Rails-Datenmodell übersetzt.

### Bereits fachlich entschieden

- [x] Drei persönliche Startkonten: Leopold Schmid, Dennis Bühler und Johannes Wiese.
- [x] Alle drei Start-Admins sind gleichberechtigt und dürfen interne Konten verwalten.
- [x] Neue Anfragen werden nicht automatisch verteilt; unzugewiesene Vorgänge sind prominent sichtbar.
- [x] Anfrage- und Auftragsstatus sind für das MVP festgelegt.
- [x] Produkt, Produktvariante, Händlerangebot und händlerspezifisches Beschaffungsprofil werden getrennt.
- [x] Interne Preise werden netto gepflegt.
- [x] Aufgaben und Checklisten sind getrennte Konzepte.
- [x] Ressourcen werden als konkrete Einheiten kalenderbasiert reserviert.
- [x] Zeitzone ist `Europe/Berlin`.
- [x] Keine allgemeine CSV-Exportfunktion im MVP; Backup und Restore werden separat gelöst.

### Technische Analyse- und Vorbereitungsaufgaben

- [ ] Hauptbranch lokal aktualisieren und vollständige Test-Suite ausführen.
- [ ] Bestehenden Anfrage- und Kalkulatorfluss bis zur gespeicherten `Inquiry` dokumentieren.
- [ ] Bestehendes `AdminUser`-Modell, Login, Passwort-Reset, Session und Seeds gegen den Mehrbenutzerbetrieb prüfen.
- [ ] Minimalen Konten-Lifecycle entwerfen: anlegen, bearbeiten, deaktivieren, reaktivieren und Schutz des letzten aktiven Admins.
- [ ] Technische Enum-Werte für die beschlossenen deutschen Anfrage- und Auftragsstatus festlegen.
- [ ] `Orders::CreateFromInquiry` einschließlich vollständiger Datenübernahme und Idempotenz skizzieren.
- [ ] Aktuelles Datenmodell als kleines Diagramm dokumentieren.
- [ ] Vorhandene Produktfelder, Adminformulare und reale Getränkedaten auf Nutzung, Redundanz und Migrationsbedarf prüfen.
- [ ] Kanonische Identität von `Product` und `ProductVariant` festlegen; händlerinterne SKUs separat behandeln.
- [ ] Modelle für `Supplier`, `ProcurementProfile`, `SupplierOffering` und Einkaufspreishistorie skizzieren.
- [ ] Prüfen, wie flexible Kostenpositionen für Pfand, Lieferung, Fremdmiete und kombinierte Miet-/Lieferleistungen abgebildet werden.
- [ ] Netto-, Rundungs- und Steuersatzkonvention zentral dokumentieren.
- [ ] Leichtgewichtigen Systemeinstellungsbereich für Steuersatz, Nummernkreise, Standardtexte, Arbeitskostensatz und Firmendaten konzipieren.
- [ ] Angebots-PDF-Erzeugung mit einem kleinen realen Beispiel testen.
- [ ] Bestehende Angebotsvorlage einsammeln und als fachliche Ausgangsbasis prüfen.
- [ ] XRechnungs-Ansatz als späteren Spike vorbereiten, ohne Phase 1–3 damit zu blockieren.
- [ ] Active-Storage-Regeln für PDF/Bilder bis 25 MB, Berechtigungen und sichere Löschung festlegen.
- [ ] Archivierungs-, DSGVO-Lösch- und Anonymisierungsstrategie je Datentyp entwerfen.
- [ ] Backup- und Restore-Konzept für Datenbank und Active Storage dokumentieren.
- [ ] Kommunikations- und Aktivitätsmodell einschließlich der festgelegten Ereignisse skizzieren.
- [x] Modelle für Aufgaben, relative Fälligkeiten, Checklisten und Anleitungshilfen entwerfen.
- [ ] Minimalmodell für `Resource` und `Reservation` ohne automatische Pufferzeiten entwerfen.
- [ ] Entscheidungen als ADRs oder im Entscheidungsprotokoll dieses Dokuments festhalten.

### Exit-Kriterien

- [ ] Keine zentrale Modellfrage blockiert Phase 1.
- [ ] Für den Produktkatalog liegt eine Feld- und Datenqualitätsanalyse vor.
- [ ] Die Migration vom aktuellen Produktmodell zum Varianten-/Lieferantenmodell ist skizziert.
- [ ] PDF-Ansatz, Anlagenkonzept und Backup-Strategie sind technisch plausibel.
- [ ] Aktuelle Tests laufen grün oder bekannte Abweichungen sind dokumentiert.

## Phase 1 – Anfrage- und Auftragskern

**Ziel:** Anfragen werden bewusst übernommen und können ohne Informationsverlust in eine interne Auftragsakte für genau eine Veranstaltung umgewandelt werden.

### Interne Admins

- [x] `AdminUser` um Name, Aktivstatus, optionale Telefonnummer, E-Mail-Signatur und Benachrichtigungseinstellungen ergänzen.
- [~] Persönliche Konten für Leopold Schmid, Dennis Bühler und Johannes Wiese anlegen beziehungsweise bestehende Konten zuordnen. (Seed ist vorbereitet; produktive Zugangsdaten müssen je Umgebung gesetzt werden.)
- [x] Alle drei Start-Admins dürfen interne Konten anlegen, bearbeiten, deaktivieren und reaktivieren.
- [x] Deaktivierte Konten dürfen sich nicht anmelden; historische Aktivitäten und Zuweisungen bleiben erhalten.
- [x] Schutz vor dem Deaktivieren des letzten aktiven Admin-Kontos umsetzen.
- [x] Keine Kundenkonten und keine öffentliche Registrierung über diesen Bereich einführen.

### Anfrage

- [x] `Inquiry` um Verantwortlichen, Bearbeitungsstatus, nächsten Schritt, optionale Fälligkeit und Abschlussgrund ergänzen.
- [x] Neue Anfragen zunächst unzugewiesen speichern.
- [x] Unzugewiesene offene Anfragen in Liste und Dashboard unübersehbar hervorheben.
- [x] Bewusste manuelle Übernahme durch einen Admin ermöglichen.
- [x] Filter nach Verantwortlichem, Status, Fälligkeit und unzugewiesen bereitstellen.
- [x] Folgende Anfrage-Status einführen:

```text
new                → Neu
clarifying         → In Klärung
waiting_customer   → Wartet auf Kunde
waiting_external   → Wartet extern
closed             → Abgeschlossen
discarded          → Verworfen
```

### Auftrag

- [x] `Order` inklusive Migration, Validierungen und Tests anlegen.
- [x] Auftrag optional, aber eindeutig mit seiner Ursprungsanfrage verknüpfen.
- [x] Aktion „In Auftrag umwandeln“ unabhängig vom aktuellen Anfrage-Status anbieten.
- [x] Mehrfache Umwandlung derselben Anfrage technisch verhindern.
- [x] Vorhandene Kontakt-, Veranstaltungs-, Verantwortungs-, Notiz- und Anlagendaten übernehmen beziehungsweise ohne Informationsverlust weiter zugänglich machen.
- [x] Manuelles Anlegen eines Auftrags ohne Anfrage ermöglichen.
- [x] Folgende Auftrags-Status einführen:

```text
preparing          → In Vorbereitung
offered            → Angeboten
confirmed          → Beauftragt
in_progress        → In Durchführung
completed          → Abgeschlossen
cancelled          → Storniert
```

- [x] Ein Auftrag repräsentiert genau eine Veranstaltung.
- [x] Pflichtfelder beim Auftrag bewusst minimal halten: Name oder Firma, Veranstaltungsort und verantwortlicher Admin. Das Veranstaltungsdatum darf in der Klärung noch offen sein.
- [x] E-Mail und Telefonnummer optional halten.
- [x] Rechnungsadresse und steuerrelevante Empfängerdaten erst vor Rechnungsfinalisierung verpflichtend prüfen.
- [x] „Nächster Schritt“ und optionale Fälligkeit pflegen.
- [x] Auftragsliste und mobile Detailansicht in den bestehenden Adminbereich integrieren.

### Chronik und Anlagen

- [x] Chronologische Notizen mit Autor und Zeitstempel für Anfrage und Auftrag umsetzen.
- [~] Aktivitätshistorie mindestens für Statuswechsel, Verantwortungswechsel, Angebotsfinalisierung/-versand, Rechnungserstellung/-versand und Zahlungseingang umsetzen. (Status- und Verantwortungswechsel sind umgesetzt; übrige Ereignisse folgen mit den jeweiligen Fachmodulen.)
- [x] PDF und gängige Bildformate bis 25 MB pro Datei über Active Storage anhängen.
- [x] Anlagen ausschließlich über die Berechtigung des zugehörigen Vorgangs zugänglich machen.
- [x] Alltagshandlung „archivieren“ statt physischem Löschen vorsehen.
- [ ] DSGVO-konforme Löschung oder Anonymisierung als getrennten administrativen Prozess vorbereiten.

### Dashboard

- [x] Anstehende Veranstaltungen anzeigen.
- [x] Unzugewiesene Anfragen anzeigen.
- [x] Überfällige und bald fällige nächste Schritte anzeigen.
- [x] Wartestatus „Kunde“ und „extern“ sichtbar machen.
- [x] Keinen künstlichen Gesamtindikator „organisatorisch vollständig“ im MVP berechnen.

### Exit-Kriterien

- [~] Alle drei Startpersonen können mit persönlichen, gleichberechtigten Admin-Konten arbeiten. (Nach dem Setzen der produktiven Seed-Zugangsdaten abnehmen.)
- [x] Eine unzugewiesene Anfrage kann nicht unbemerkt bleiben und wird bewusst übernommen.
- [x] Anfrage- und Auftragsstatus entsprechen den vereinbarten deutschen Bezeichnungen.
- [x] Eine Anfrage kann ohne doppelte Anlage und ohne Informationsverlust in einen Auftrag umgewandelt werden.
- [x] Jeder aktive Auftrag zeigt Veranstaltung, Status, Verantwortlichen und nächsten Schritt.
- [~] Chronik und Anlagen sind sicher, mobil nutzbar und nachvollziehbar. (Automatisiert geprüft; manuellen Mobil-/Browser-Abnahmelauf durchführen.)
- [x] Model-, Controller- und mindestens ein durchgängiger Browsertest sind vorhanden.

## Phase 2 – Kalkulation, Bezugsquellen, Szenarien und Angebotsdokumente

**Ziel:** Angebote werden intern netto kalkuliert, mit mehreren Beschaffungsoptionen verglichen, versioniert und als belastbares Kundendokument erzeugt.

### Produkt- und Lieferantenstamm

- [ ] Bestehende Produktfelder nach der Phase-0-Analyse bereinigen und migrieren.
- [ ] `Product` als kanonische Getränkesorte und `ProductVariant` als konkretes Gebinde modellieren.
- [ ] Varianten wie 20, 30 und 50 Liter ohne Händlerduplikate pflegen.
- [x] `Supplier` mit Südstar als konfigurierbarem Standard und Getränke Beck als zweiter Quelle anlegen.
- [x] Händlerspezifische `ProcurementProfile`s anlegen, beispielsweise Lagerware, Bestellware und Sonderbestellung.
- [x] Profile mindestens mit Vorlaufzeit, Rückgaberegel und optionalen Liefer-/Stornohinweisen pflegen.
- [x] `SupplierOffering` zwischen Händler und Produktvariante anlegen; Händler-SKU und Profil zuordnen.
- [x] Angebotsbezogene Sonderfälle durch Overrides ermöglichen, ohne die Profilvorteile zu verlieren.
- [x] Einkaufspreise mit `valid_from` historisieren; Preisänderungen erzeugen einen neuen Stand.
- [x] Im MVP keine zusätzliche parallele Live-Verfügbarkeitslogik erzwingen.
- [ ] Standardlieferant in der einfachen Ansicht vorauswählen, Alternativen und Vergleich in einer erweiterten Ansicht anbieten.

### Kalkulation

- [x] `Offer` und `OfferLineItem` anlegen.
- [x] Freie Positionen für Miete, Lieferung, Pfand, Fremdmiete und sonstige Leistungen unterstützen.
- [x] Preise intern grundsätzlich netto pflegen.
- [x] Im MVP einen zentral konfigurierbaren Standardsteuersatz verwenden; Sonderfälle erst nach realem Bedarf ergänzen.
- [x] Menge, Einheit, Beschreibung, Netto-Einzelpreis, Rabatt und Steuersatz erfassen.
- [x] Pro Position passende `SupplierOffering`s vergleichen.
- [x] Voraussichtlich günstigste beziehungsweise organisatorisch passende Quelle vorschlagen, aber nicht automatisch verbindlich auswählen. (Preis, Vorlaufzeit und Rückgaberegel bestimmen die Vorschlagsreihenfolge; verbindlich wählt das Team.)
- [ ] Einkaufspreis, Profil, Vorlauf, Rückgaberegel und direkte Zusatzkosten in die interne Kalkulation übernehmen.
- [x] Miet- und Lieferleistung im MVP weiterhin als kombinierte freie Position erfassen können.
- [ ] Pfand technisch als optionalen Kosten-/Zahlungsbaustein vorbereiten, aber nicht automatisch im Kundendokument ausweisen.
- [ ] Mindestbestellwerte als Hinweis beziehungsweise Warnung abbilden.
- [x] Geplante Arbeitszeit in den Kategorien `Organisation` und `Durchführung` erfassen.
- [~] Einen zentral konfigurierbaren internen Standardkostensatz verwenden; konkreten Startwert vor Produktivbetrieb eintragen. (Einstellung ist vorhanden; produktiven Startwert festlegen.)
- [x] Nettoumsatz, Steuer, Brutto, direkte Kosten, Deckungsbeitrag und Marge mit `BigDecimal` berechnen.
- [x] Gesamt- und Positionsrabatte unterstützen.
- [x] Kundensichtbare Rabattbegründung und getrennte interne Notiz ermöglichen.

### Szenarien, Nummerierung und Versionen

- [x] Angebotsentwurf duplizieren und mehrere Kundenszenarien vergleichen können.
- [ ] Beschaffungsvarianten je Szenario vergleichen.
- [ ] Warnen, wenn die Vorlaufzeit eines Beschaffungsprofils nicht zum Veranstaltungstermin passt.
- [ ] Nicht rückgabefähige Positionen klar kennzeichnen.
- [x] Separate automatische Angebotsnummern verwenden, initial beispielsweise `A-YYYY-000001`.
- [x] Angebotsversionen fortlaufend führen.
- [x] Standardgültigkeit auf 14 Tage setzen und pro Angebot änderbar machen.
- [~] Beim Finalisieren Empfänger, Positionen, Netto-/Bruttowerte, Rabatte, Einkaufspreise, Profile und Kostenannahmen einfrieren. (Empfänger, Positionen, Preise, Rabatte und direkte Kosten sind eingefroren; Profil- und Einkaufsquellen-Snapshots folgen mit der Beschaffungswahl.)
- [x] Finalisierte beziehungsweise versandte Versionen gegen Änderungen schützen.

### Angebotsdokument und Versand

- [ ] Bestehendes Zapfe-Template als Ausgangspunkt übernehmen und fachlich/gestalterisch prüfen.
- [~] Angebots-PDF mindestens mit Absender- und Empfängerdaten, Angebotsnummer, Datum, Gültigkeit, Veranstaltungsbezug, Positionen, Mengen, Einheiten, Netto-Preisen, Rabattbegründungen, Steueraufschlüsselung, Gesamtbetrag, Zahlungsbedingungen und Kontaktinformation erzeugen. (PDF-Entwurf aus dem Snapshot erzeugt; vollständige Zahlungsbedingungen und Angebotsinhalte werden noch an der geprüften Vorlage geschärft.)
- [ ] Leistungsumfang, Ausschlüsse, Rückgabe-/Pfandhinweise und Annahmemöglichkeit dort ausgeben, wo sie für den konkreten Auftrag relevant sind.
- [ ] Vor Produktivstart eine rechtliche und steuerliche Prüfung der Vorlage einplanen; die technische Checkliste ersetzt keine Fachprüfung.
- [x] PDF über Active Storage an der konkreten Angebotsversion speichern.
- [x] Vorschau und Versand über Action Mailer/Resend umsetzen.
- [x] Versand mit Absender, Empfänger, Betreff, Zeitpunkt und Dokumentversion protokollieren.
- [x] Angebot manuell als angenommen, abgelehnt oder abgelaufen markieren.
- [x] Angenommene Version als operative Grundlage kennzeichnen.

### Exit-Kriterien

- [ ] Ein reales Angebot kann ohne externe Tabelle vollständig erstellt werden.
- [ ] Dieselbe Produktvariante kann bei Südstar und Beck mit unterschiedlichen Preisen und Profilen geführt werden.
- [ ] Einkaufspreishistorie verändert keine alten Angebote.
- [ ] Interne Kosten sind nie im Kundendokument sichtbar.
- [ ] Ein versandtes Angebot bleibt unverändert reproduzierbar.
- [ ] Angebotsgültigkeit, Rabattgründe und Beschaffungsannahmen sind nachvollziehbar.
- [ ] PDF-Erzeugung, Berechnung, Versionierung und Versand sind getestet.

### MVP-Meilenstein

Mit Abschluss von Phase 2 ist die erste praktisch nutzbare Zapfe-Auftragszentrale erreicht.

## Phase 3 – Beschaffung, operative Durchführung, Checklisten und Ressourcen

**Ziel:** Nach der Bestätigung wird aus der Kalkulation eine verbindliche Beschaffungs-, Aufgaben- und Ressourcenplanung.

### Beschaffungsplanung

- [x] `ProcurementPlan` oder gleichwertige Auftragsstruktur einführen.
- [~] Passende Quellen anhand von Preis, Vorlauf, Rückgaberegeln und Zusatzleistungen vergleichen. (Preis, Vorlauf und Rückgabe sind sichtbar; Zusatzleistungen folgen.)
- [x] Bezugsquelle erst nach Auftragsbestätigung und unmittelbar vor der konkreten Beschaffung verbindlich auswählen.
- [x] Automatischen Vorschlag erlauben; finale Auswahl bleibt beim Team. (Auswahloptionen werden nach Preis, Vorlaufzeit und Rückgaberegel empfohlen; verbindlich wählt weiterhin das Team.)
- [ ] Beschaffungsstatus zunächst auf vier Werte begrenzen:

```text
planned     → Geplant
requested   → Angefragt
confirmed   → Bestätigt
done        → Erledigt
```

- [x] Gewählte Konditionen als Auftragssnapshot sichern.
- [x] Aufgaben aus Vorlaufzeiten und Bestellfristen erzeugen. (Beim Erstellen eines Beschaffungsplans wird eine relative Bestellaufgabe angelegt.)
- [x] Lieferantenangebote und Bestellbestätigungen im MVP als PDF/Bild oder Notiz anhängen, nicht als eigenes strukturiertes Objekt.
- [x] Externe Mietartikel und kombinierte Liefer-/Mietleistungen als Beschaffungsposition dokumentieren.
- [x] Nicht rückgabefähige Positionen erfordern vor dem Status „Bestätigt“ eine bewusste Bestätigung; Zeitpunkt und handelnder Admin werden protokolliert.

### Aufgaben und Checklisten

- [x] `Task` mit Verantwortlichem, Status und Fälligkeit einführen.
- [x] Manuelle und aus Vorlagen erzeugte Aufgaben unterstützen.
- [x] Im MVP das Veranstaltungsdatum als ersten relativen Anker verwenden.
- [x] Konfigurierbare Abstände in Tagen vor oder nach der Veranstaltung unterstützen.
- [x] Bei Terminänderung nicht fixierte Fälligkeiten neu berechnen.
- [~] Erinnerungsjobs vorbereiten; Push folgt in Phase 5. (Offene Aufgaben und Fristen sind im Dashboard sichtbar; asynchrone Erinnerungen folgen mit Push in Phase 5.)
- [x] Aufgaben als fachliches **Was** und Checklisten als operatives **Wie** modellieren.
- [x] Erste Checklisten-Vorlagen für Ape und Kegerator in den Bereichen Packen, Aufbauen und Reinigen anlegen. (Als pflegbare Seed-Vorlagen.)
- [~] Inhalte der Checklisten später mit dem Team detailliert ausarbeiten. (Startpunkte sind vorhanden; konkrete Handgriffe werden gemeinsam ergänzt.)
- [x] Pro Checklistenpunkt optional Anleitungstext, Bild/Datei, Link, Video-Link und Hinweis erlauben.
- [x] Schäden, Fehlteile und besondere Vorkommnisse als Notiz oder Aufgabe erfassen.

### Ressourcen und Kalender

- [x] `Resource` mit Name, Typ, aktiv/inaktiv und optionaler Konfigurationsnotiz anlegen.
- [x] Ape und Kegerator als konkrete Einheiten führen.
- [x] Ressourcen einem Angebot beziehungsweise Auftrag zuordnen können.
- [x] `Reservation` mit konkreter Ressource, Start und Ende anlegen.
- [x] Im MVP keine automatischen Reinigungs-, Transport- oder Wartungspuffer anwenden.
- [x] Doppelbuchungen blockieren oder unübersehbar warnen.
- [x] Ressourcen-Kalender mit Belegungs- und Verfügbarkeitsanzeige bereitstellen.
- [ ] Google-Kalender-Synchronisation als getrennten Integrationsschritt analysieren.

### Wiederkehrende Veranstaltungen

- [x] Freie Tags unterstützen.
- [x] Konfigurierbare `OrderTemplate`s je Veranstaltungsreihe anlegen.
- [x] Pro Vorlage frei festlegen können, welche Felder, Produkte, Ressourcen, Aufgaben und Checklisten vorausgefüllt werden.
- [~] Pro Vorlage Prozessschritte überspringen können, beispielsweise die Angebotsphase bei einer Eigenveranstaltung. (Die Einstellung ist erfasst; die konkrete Prozessautomatisierung folgt erst bei einem definierten Eigenveranstaltungsablauf.)
- [x] Jede Durchführung weiterhin als eigenen Auftrag mit eigenem Datum erzeugen.

### Arbeitszeit

- [x] Geplante und tatsächliche Zeiten getrennt erfassen.
- [x] Kategorien `Organisation` und `Durchführung` verwenden.
- [x] Zeiten einem internen Admin oder später einer Aushilfe zuordnen.
- [x] Plan-/Ist-Vergleich im Auftrag anzeigen.

### Exit-Kriterien

- [x] Für einen bestätigten Auftrag kann die beste passende Bezugsquelle vorgeschlagen und bewusst ausgewählt werden.
- [x] Beschaffungsstatus und Bestellfristen sind nachvollziehbar.
- [x] Aufgaben und relative Fälligkeiten funktionieren bei Terminverschiebungen.
- [~] Checklisten führen bei Packen, Aufbau und Reinigung durch konkrete Handgriffe und können Hilfen verlinken. (Technik und Startvorlagen sind umgesetzt; detaillierte Arbeitsinhalte werden noch gemeinsam gepflegt.)
- [x] Ape und Kegerator lassen sich nicht doppelt verbindlich reservieren.
- [x] Wiederkehrende Veranstaltungen können aus konfigurierbaren Vorlagen erzeugt werden.
- [x] Geplante und tatsächliche Arbeitszeit können verglichen werden.

## Phase 4 – Rechnung, XRechnung und Zahlungsabschluss

**Ziel:** Aus dem tatsächlich ausgeführten Auftrag entsteht eine korrekte, unveränderbare Rechnung.

**Entscheidungsstand:** Zentrale Firmendaten und das Rechnungsnummernformat sind festgelegt. Anzahlungen, Pfand, Gutschrift/Storno, XRechnungs-Syntax, Empfängerfelder und externe Fachprüfung werden im nächsten Entscheidungsblock geklärt.

### Rechnungsgrundlage

- [ ] Zentrale Systemeinstellungen für offizielle Firmendaten, Bankverbindung, Steuernummer/USt-ID und Zahlungsbedingungen bereitstellen.
- [ ] `Invoice` und `InvoiceLineItem` anlegen.
- [ ] Rechnung aus angenommenem Angebot beziehungsweise finalem Auftrag vorbereiten.
- [ ] Übernommene Gesamt- und Positionsrabatte einschließlich kundensichtbarer Begründung als Rechnungs-Snapshot sichern.
- [ ] Nachträgliche Mehr- oder Minderleistungen und begründete Rabattänderungen nachvollziehbar erfassen.
- [ ] Kundensichtbare Rabattbezeichnungen bei Bedarf auch im Rechnungs-PDF und in den strukturierten Rechnungsdaten korrekt ausgeben.
- [ ] Rechnungsadresse und steuerrelevante Kundendaten prüfen.
- [ ] Entwurf, finalisiert, versandt, bezahlt, storniert und überfällig abbilden.

### Nummerierung und Unveränderbarkeit

- [ ] Fortlaufendes, kollisionssicheres Rechnungsnummernformat `R-YYYY-000001` umsetzen; Startwert zentral konfigurierbar halten.
- [ ] Rechnungsnummer erst bei Finalisierung vergeben.
- [ ] Finalisierte Rechnung gegen Änderungen schützen.
- [ ] Korrektur-/Stornoprozess definieren und umsetzen.
- [ ] Erzeugte Dokumente und fachliche Snapshots dauerhaft speichern.

### Ausgabeformate

- [ ] Menschenlesbares Rechnungs-PDF erstellen.
- [ ] XRechnungs-XML aus demselben Rechnungsmodell erzeugen.
- [ ] Zielsyntax verbindlich wählen, voraussichtlich UBL oder CII.
- [ ] XML gegen die aktuelle KoSIT-XRechnung-Konfiguration validieren.
- [ ] Ungültige XRechnung darf nicht als final versandt werden.
- [ ] Validierungsbericht intern speichern oder nachvollziehbar protokollieren.
- [ ] Versand und Download im Adminbereich ermöglichen.
- [ ] Rechnungsversand als Kommunikationseintrag mit Absender, Empfänger, Zeitpunkt und Dokumentversion protokollieren.

### Zahlung und Abschluss

- [ ] Fälligkeitsdatum und Zahlungsstatus erfassen.
- [ ] Zahlung manuell verbuchen können.
- [ ] Auftrag nach Zahlung beziehungsweise bewusster Freigabe abschließen.
- [ ] Offene und überfällige Rechnungen im Dashboard anzeigen.

### Technische Leitlinie für XRechnung

Es wird nicht vorausgesetzt, dass eine einzelne Ruby-Gem den vollständigen Standard zuverlässig abdeckt. Die Umsetzung soll deshalb aus klar getrennten Teilen bestehen:

1. kanonisches internes Rechnungsmodell,
2. XML-Builder,
3. Schema-/Regelvalidierung mit offizieller Konfiguration,
4. automatisierte Testbeispiele,
5. versionierbare Standardkonfiguration.

Offizielle technische Referenzen für die Analyse:

- KoSIT Validator: `https://github.com/itplr-kosit/validator`
- XRechnung-Validierungskonfiguration: `https://github.com/itplr-kosit/validator-configuration-xrechnung`

### Exit-Kriterien

- [ ] Eine Rechnung kann aus einem echten Auftrag erstellt, finalisiert und versandt werden.
- [ ] PDF und XRechnungs-XML stimmen fachlich überein.
- [ ] Jede erzeugte XRechnung wird automatisiert validiert.
- [ ] Finalisierte Rechnungen sind unveränderbar und reproduzierbar.
- [ ] Zahlungsstatus und Auftragsabschluss funktionieren.

---

## Phase 5 – Interne PWA und Push-Nachrichten

**Ziel:** Der Adminbereich lässt sich auf Smartphones wie eine App installieren und kann gezielte Benachrichtigungen senden.

### PWA-Grundlage

- [ ] Vorhandenes Rails-PWA-Gerüst analysieren und aktivieren.
- [ ] Eigenes internes Manifest mit Zapfe-Branding erstellen.
- [ ] Start-URL und Scope sinnvoll auf den Adminbereich ausrichten.
- [ ] App-Icons, Theme-Farben und Standalone-Darstellung fertigstellen.
- [ ] Service Worker registrieren.
- [ ] Installationsfluss auf aktuellem Android und mindestens einem weiteren Browser testen.

### Push

- [ ] `PushSubscription` pro Admin-Benutzer und Gerät speichern.
- [ ] Berechtigungsabfrage bewusst und nicht beim ersten Seitenaufruf anzeigen.
- [ ] Web-Push-Versand über einen Job umsetzen.
- [ ] Klick auf eine Benachrichtigung öffnet direkt den relevanten Auftrag.
- [ ] Ungültige Abonnements automatisch entfernen.

### Erste sinnvolle Benachrichtigungen

- [ ] Nächster Schritt oder automatisch erzeugte Standardaufgabe ist fällig beziehungsweise überfällig.
- [ ] Beschaffungs- oder Vorbereitungsfrist nähert sich, zum Beispiel Getränke 14 Tage vor Veranstaltung bestellen.
- [ ] Nachgelagerte Aufgabe wird fällig, zum Beispiel Rechnung einige Tage nach Rückgabe erstellen.
- [ ] Veranstaltung beginnt in einem konfigurierbaren Zeitraum.
- [ ] Auftrag ist bestätigt und benötigt Vorbereitung.
- [ ] Rechnung ist überfällig.
- [ ] Ein Teammitglied weist eine Aufgabe zu.

### Exit-Kriterien

- [ ] Zapfe Intern kann als PWA installiert werden.
- [ ] Push ist pro Gerät aktivierbar und deaktivierbar.
- [ ] Benachrichtigungen werden nicht doppelt versendet.
- [ ] Kritische Prozesse funktionieren weiterhin vollständig ohne Push.

---

## Phase 6 – Spätere Erweiterungen

Diese Punkte werden erst priorisiert, wenn der Kernprozess im realen Betrieb funktioniert.

### Kommunikation und Kontakte

- [ ] Eingehende E-Mails providerunabhängig aus dem IONOS-Postfach beziehungsweise einer Weiterleitungs-/Inbound-Lösung übernehmen
- [ ] Eingehende Antworten anhand einer stabilen Vorgangskennung automatisch einer Anfrage oder einem Auftrag zuordnen
- [ ] Anhänge eingehender E-Mails sicher in Active Storage übernehmen
- [ ] Mehrere Ansprechpartner mit Rollen wie Veranstaltung, Aufbau und Buchhaltung unterstützen
- [ ] Digitale Angebotsannahme über sicheren Kundenlink
- [ ] Kundenbereich für Angebote, Dokumente und Anleitungen
- [ ] Automatisierte Erinnerungen an Kunden

### Financial Cockpit

- [ ] Separates Financial Cockpit für Umsatz, direkte Kosten, Fixkosten und Ergebnis aufbauen
- [ ] FINOM-Export als erste mögliche Datenquelle analysieren und importieren
- [ ] Transaktionen kategorisieren und wiederkehrende Fixkosten wie Versicherung oder Stellplatz sichtbar machen
- [ ] Auswertungen nach Monat, Quartal und Jahr bereitstellen
- [ ] Auftragsumsätze und direkte Auftragskosten mit Bankdaten abgleichen, ohne eine vollständige Buchhaltung nachzubauen
- [ ] Buchhaltungs- oder Steuerberater-Export

### Wiederkehrende Abläufe, Ressourcen und Wartung

- [ ] Vorlagen um komplexere Serienregeln und wiederkehrende Termine erweitern
- [ ] Wartungs-, Reinigungs- und Reparaturhistorie je Ressource führen
- [ ] Erweiterte Ressourcenzustände wie verfügbar, Reinigung, Wartung und defekt einführen
- [ ] Auswertungen zu geschätzter und tatsächlicher Arbeitszeit sowie Personalkostenszenarien ergänzen

### Lieferanten, Zahlung und weitere Automatisierung

- [ ] Import von Händlerpreislisten oder strukturierten Lieferantenangeboten
- [ ] Automatisierte Verfügbarkeitsabfrage nur für Händler mit belastbarer Schnittstelle
- [ ] Angebotsanfragen an mehrere Lieferanten und Vergleich eingehender Händlerangebote
- [ ] Auswertung von Preisentwicklung, Lieferzuverlässigkeit und bevorzugten Bezugsquellen
- [ ] ZUGFeRD zusätzlich oder alternativ zur reinen XRechnung
- [ ] Onlinezahlung und Anzahlung
- [ ] Verfügbarkeitsanzeige auf der öffentlichen Website
- [ ] Kundenfeedback nach Veranstaltung
- [ ] Kennzahlen zu Anfragen, Abschlussquote, Umsatz und Deckungsbeitrag
- [ ] Automatisierte Vorschläge oder KI-Unterstützung

---

## 8. Übergreifende Anforderungen

### Sicherheit und Berechtigungen

- Alle internen Funktionen bleiben unter dem Admin-Namespace geschützt.
- Jede intern arbeitende Person verwendet ein persönliches Admin-Konto; gemeinsame Logins werden nicht als regulärer Arbeitsweg vorgesehen.
- Deaktivierte Admin-Konten verlieren den Zugriff, historische Zuweisungen und Aktivitäten bleiben jedoch erhalten.
- Administrative Änderungen wie Statuswechsel, Verantwortungswechsel, Angebotsfinalisierung/-versand, Rechnungserstellung/-versand und Zahlungseingang werden der handelnden Person zugeordnet.
- Die Historie soll fachlich verständlich zeigen, wer wann welche wesentliche Änderung vorgenommen hat; sie ersetzt nicht zwingend ein technisches Audit jedes einzelnen Datenbankfeldes.
- Kunden und externe Ansprechpartner werden nicht als `AdminUser` modelliert.
- Dokumentlinks dürfen nicht versehentlich öffentlich erratbar sein.
- Anlagen und Kommunikationseinträge unterliegen derselben serverseitigen Autorisierung wie der zugehörige Vorgang.
- Eine spätere Eingangsmail-Integration speichert nur die für den Geschäftsprozess notwendigen Inhalte und Anhänge.
- Sensible Aktionen benötigen serverseitige Autorisierung.
- Push-Abonnements und Kundendaten werden nur zweckgebunden gespeichert.

### Datenintegrität

- Migrationen enthalten passende Indizes und Constraints.
- Konvertierung von Anfrage zu Auftrag ist idempotent.
- Nummernvergabe ist transaktionssicher.
- Geldbeträge werden nicht mit binären Fließkommazahlen berechnet.
- Dokument-Snapshots bleiben von späteren Katalogänderungen unberührt.
- Einkaufspreise besitzen nachvollziehbare Gültigkeitszeiträume; Vorlauf- und Rückgaberegeln werden über händlerspezifische Beschaffungsprofile gepflegt.
- Eine Produktvariante kann mehreren Lieferanten zugeordnet werden, ohne duplizierte Produktstammdaten zu erzeugen.
- Ausgewählte Beschaffungskonditionen werden im Auftrag als Snapshot gesichert und nicht rückwirkend durch spätere Preisänderungen verändert.
- Geld- und Datumslogik verwendet die Zeitzone `Europe/Berlin`.
- Nummernkreise für Angebote und Rechnungen sind getrennt und transaktionssicher.

### Bedienbarkeit

- Neue Felder werden nur verpflichtend, wenn sie für den aktuellen Schritt notwendig sind.
- Jede Anfrage- und Auftragsseite zeigt auf einen Blick Status, Verantwortlichen und nächsten Schritt.
- Chronik und Dateien sind direkt am Vorgang erreichbar, ohne die operative Hauptansicht zu überladen.
- Das Dashboard priorisiert Termine und Handlungsbedarf statt dekorativer Kennzahlen.
- Wartestatus machen klar sichtbar, ob Zapfe, der Kunde oder eine externe Stelle handeln muss.
- Die wichtigsten Aktionen funktionieren mobil.
- Komplexe Einstellungen bleiben aus dem täglichen Arbeitsfluss heraus.

### Beobachtbarkeit und Fehlerbehandlung

- Fehler bei E-Mail-, PDF-, XML- oder Push-Erzeugung sind im Adminbereich erkennbar.
- Jobs müssen sinnvoll wiederholbar sein.
- Kritische Zustandswechsel werden protokolliert.
- Fehlgeschlagene externe Integrationen dürfen den Auftrag nicht beschädigen.

### Backup und Betrieb

Vor produktiver Nutzung von Rechnungen und zentraler Auftragsverwaltung werden automatisierte Backup-, Restore- und Aufbewahrungsprozesse für Datenbank und Active Storage geprüft und dokumentiert. Backups müssen außerhalb des eigentlichen Produktivsystems liegen. Eine allgemeine CSV-Exportfunktion für Anfragen und Aufträge ist im MVP nicht vorgesehen.

Im Alltag werden Vorgänge archiviert statt physisch gelöscht. Daneben wird je Datentyp eine dokumentierte DSGVO-Lösch- beziehungsweise Anonymisierungsstrategie benötigt.

---

## 9. Fachliche Entscheidungen und verbleibende Fragen

Die Entscheidungsblöcke vor Phase 1 bis Phase 3 wurden weitgehend geklärt. `[~]` kennzeichnet einen Punkt, dessen Architektur entschieden ist, bei dem aber noch ein konkreter Wert, Inhalt oder technischer Spike fehlt.

### Vor Phase 1

- [x] Start-Admins: Leopold Schmid, Dennis Bühler und Johannes Wiese.
- [x] Admin-Stammdaten: Name, E-Mail, aktiv/inaktiv, persönliche E-Mail-Signatur, Benachrichtigungseinstellungen, spätere Push-Geräte und optionale Telefonnummer.
- [x] Alle drei Start-Admins sind zunächst gleichberechtigt.
- [x] Alle drei dürfen weitere interne Admin-Konten anlegen, deaktivieren und reaktivieren.
- [x] Neue Anfragen werden nicht automatisch zugewiesen; die Übernahme erfolgt bewusst manuell.
- [x] Unzugewiesene offene Anfragen werden prominent dargestellt und dürfen nicht unbemerkt bleiben.
- [x] Anfrage und Auftrag sind getrennte Phasen; nicht jede Anfrage wird zum Auftrag.
- [x] Anfrage-Status: Neu, In Klärung, Wartet auf Kunde, Wartet extern, Abgeschlossen, Verworfen.
- [x] Auftrags-Status: In Vorbereitung, Angeboten, Beauftragt, In Durchführung, Abgeschlossen, Storniert.
- [x] Die Umwandlung in einen Auftrag erfolgt manuell und ohne festen Trigger.
- [x] Ein Auftrag entspricht genau einer Veranstaltung.
- [x] Aktivitätshistorie im MVP: Statuswechsel, Verantwortungswechsel, Angebotsfinalisierung/-versand, Rechnungserstellung/-versand und Zahlungseingang.
- [x] Im MVP gibt es einen primären Ansprechpartner; mehrere Kontaktrollen folgen bei Bedarf.
- [x] Kundendaten am Auftrag: Name oder Firma verpflichtend; E-Mail und Telefon optional.
- [x] Veranstaltungsort und verantwortlicher Admin gehören zu den minimalen Auftrags-Pflichtfeldern; das Veranstaltungsdatum darf zunächst offen bleiben.
- [x] Rechnungsadresse und steuerrelevante Empfängerdaten werden erst vor Rechnungsfinalisierung zwingend geprüft.
- [x] Beim Umwandeln werden alle vorhandenen Kontakt-, Veranstaltungs-, Verantwortungs-, Notiz- und Anlagendaten übernommen beziehungsweise weiter verknüpft.
- [x] Notizen sind einzelne chronologische Einträge mit Autor und Zeitstempel.
- [x] Anlagen im MVP: PDF und gängige Bildformate, maximal 25 MB pro Datei.
- [x] Aufbewahrung folgt dem Vorgang; Archivierung wird durch eine DSGVO-Lösch-/Anonymisierungsstrategie ergänzt.
- [x] Kein Gesamtindikator „organisatorisch vollständig vorbereitet“ im MVP; konkrete Aufgaben und Fristen sind aussagekräftiger.
- [x] Zeitzone: `Europe/Berlin`.
- [x] Keine allgemeine CSV-Exportfunktion im MVP.
- [~] Backup- und Restore-Strategie außerhalb des Produktivsystems technisch ausarbeiten.

### Vor Phase 2

- [x] Preise werden intern grundsätzlich netto gepflegt.
- [x] Im MVP wird nur der zentral konfigurierbare Standardsatz verwendet; steuerliche Sonderfälle folgen bei realem Bedarf.
- [x] Produkt und Gebindevariante werden getrennt; 20-, 30- und 50-Liter-Fässer sind Varianten desselben Produkts.
- [x] Dieselbe Produktvariante wird über ihre kanonische `ProductVariant`-ID mehreren Händlern zugeordnet; Händler-SKUs liegen an `SupplierOffering`.
- [x] Erste Händler: Getränkemarkt Südstar als konfigurierbarer Standard und Getränke Beck als zweite Quelle.
- [x] Lieferbedingungen werden über wiederverwendbare, händlerspezifische Beschaffungsprofile gepflegt.
- [x] Beschaffungsprofile enthalten mindestens Name, Vorlaufzeit und Rückgaberegel; Liefer-/Stornohinweise sind optional.
- [x] Einzelne Händler-Produktvarianten können Profilwerte für echte Sonderfälle überschreiben.
- [x] Eine zusätzliche parallele Statuspflege für „aktuell verfügbar“ wird im MVP vermieden; Angebot und Beschaffungsprofil bilden die bekannte Situation ab.
- [x] Eine konkrete Lieferzusage kann später am Beschaffungsvorgang beziehungsweise als Anlage dokumentiert werden.
- [x] Einkaufspreise sind zeitlich gültig; eine Änderung erzeugt einen neuen Stand mit `valid_from`.
- [x] Pfand, Lieferung, Fremdmiete und Mindestbestellwert können getrennt abgebildet werden.
- [x] Im MVP dürfen Miet- und Lieferkosten weiterhin als kombinierte freie Position erfasst werden.
- [x] Pfand wird technisch vorbereitet, aber nicht automatisch im Kundendokument ausgewiesen.
- [x] Direkte Kosten einschließlich Arbeitszeit fließen in die Kalkulation; Fixkosten nicht.
- [x] Arbeitszeitkategorien: Organisation und Durchführung.
- [~] Ein gemeinsamer interner Arbeitskostensatz ist konfigurierbar; der konkrete Startwert muss vor Produktivbetrieb eingetragen werden.
- [x] Gesamt- und Positionsrabatte werden unterstützt.
- [x] Rabatte besitzen kundensichtbare Begründung und getrennte interne Notiz.
- [x] Angebotsversionen und preisrelevante Werte werden beim Finalisieren eingefroren.
- [x] Lieferantenmodell unterstützt mehrere Quellen; die einfache UI darf einen Standard vorauswählen.
- [x] Standardgültigkeit eines Angebots: 14 Tage, pro Angebot änderbar.
- [~] Bestehende Produktfelder werden in Phase 0 technisch analysiert und anschließend behalten, umbenannt oder migriert.
- [~] Bestehendes Angebots-Template dient als Ausgangspunkt und wird anhand einer Inhaltscheckliste sowie vor Produktivstart fachlich/rechtlich geprüft.

### Vor Phase 3

- [x] Eine Bezugsquelle wird erst nach Bestätigung des Auftrags und vor der konkreten Beschaffung verbindlich gewählt.
- [x] Das System darf anhand von Preis, Vorlauf und Bedingungen die beste passende Quelle vorschlagen; ein Mensch bestätigt die Wahl.
- [x] Genaue Bestätigungslogik für nicht rückgabefähige Bestellungen: Pflicht-Haken vor Status „Bestätigt“, mit Admin und Zeitpunkt.
- [x] Beschaffungsstatus im MVP: Geplant, Angefragt, Bestätigt, Erledigt.
- [x] Konkrete Lieferantenangebote werden zunächst als Anlage oder Notiz dokumentiert, nicht als eigenes Objekt.
- [x] Vermietbare Geräte sind einzelne physische Ressourcen.
- [x] Ressourcen-Stammdaten im MVP: Name, Typ, aktiv/inaktiv und optionale Konfigurationsnotiz.
- [x] Ressourcen können Angebot/Auftrag zugeordnet und in einem Kalender reserviert werden.
- [x] Im Ressourcen-MVP reicht die zeitliche Reservierung einer konkreten Einheit.
- [x] Zunächst keine automatischen Pufferzeiten für Reinigung, Transport oder Wartung.
- [x] Aufgaben entstehen aus Vorlagen oder manuell.
- [x] Aufgaben unterstützen relative Fälligkeiten und spätere Erinnerungen.
- [x] Erster relativer Anker ist das Veranstaltungsdatum; Abstände in Tagen vor oder nach dem Termin sind konfigurierbar.
- [x] Aufgaben beschreiben das Was, Checklisten das Wie.
- [x] Erste Checklistenbereiche: Packen, Aufbauen und Reinigen für Ape und Kegerator.
- [x] Checklistenpunkte können Anleitungstext, Bilder/Dateien, Links und Video-Links enthalten.
- [x] Wiederkehrende Veranstaltungen nutzen Tags und frei konfigurierbare Vorlagen.
- [x] Welche Felder und Schritte vorausgefüllt oder übersprungen werden, wird je Veranstaltungsreihe konfiguriert.
- [x] Jede Durchführung bleibt ein eigener Auftrag.
- [x] Arbeitszeit wird geplant und tatsächlich erfasst.

### Vor Phase 4 – nächster Entscheidungsblock

- [x] Offizielle Firmendaten, Bankverbindung, Steuernummer/USt-ID und Zahlungsbedingungen werden zentral in Systemeinstellungen gepflegt.
- [x] Angebote und Rechnungen verwenden getrennte automatische Nummernkreise.
- [x] Initiales Rechnungsformat: `R-YYYY-000001`, Startwert konfigurierbar.
- [x] Finalisierte und versandte Dokumente bleiben unveränderbar.
- [ ] Umgang mit Anzahlungen, Pfand, Gutschriften und Storno.
- [ ] Bevorzugte XRechnungs-Syntax und erforderliche Empfängerfelder.
- [ ] Wer steuerliche und rechtliche Anforderungen vor Produktivstart prüft.
- [ ] Finales Angebotsnummernformat bestätigen; vorläufig `A-YYYY-000001`.

### Vor Phase 5 – nächster Entscheidungsblock

- [ ] Soll die PWA nur den Adminbereich oder auch öffentliche Funktionen umfassen?
- [ ] Welche Benachrichtigungen sind wirklich nützlich und welche störend?
- [ ] Wer darf Benachrichtigungen an wen auslösen?
- [ ] Verwaltet jeder Admin seine Push-Einstellungen ausschließlich selbst?

### Vor späterer E-Mail-Integration und Financial Cockpit

- [x] Eingangsmail-Integration providerunabhängig; IONOS hostet, Gmail ist nur Client.
- [ ] Eingangsmail-Anbindung per IMAP, Weiterleitung/Inbound-Parser oder anderem Dienst.
- [ ] Robuste Zuordnung einer Antwort zu Anfrage oder Auftrag.
- [x] Fixkosten und Unternehmensprofit gehören in ein separates Financial Cockpit.
- [ ] Verfügbare FINOM-Exportformate und Importhäufigkeit.
- [ ] Kategorien für Fixkosten, variable Kosten und Erlöse.


## 10. Arbeitsweise für jede Phase

Jede Phase wird in kleine, überprüfbare Arbeitspakete zerlegt. Für jedes Paket gilt:

1. **Bestand analysieren**  
   Betroffene Models, Controller, Views, Jobs, Tests und Daten prüfen.

2. **Offene Fragen festhalten**  
   Nur Entscheidungen klären, die für dieses Arbeitspaket notwendig sind.

3. **Kleine technische Lösung beschreiben**  
   Bei relevanten Architekturentscheidungen ADR oder Entscheidungsnotiz ergänzen.

4. **Vertikalen Schnitt implementieren**  
   Datenbank, Businesslogik, Adminoberfläche und Tests möglichst gemeinsam liefern.

5. **Mit realistischem Beispiel prüfen**  
   Nach Möglichkeit mit einem echten oder anonymisierten Zapfe-Auftrag testen.

6. **Dokument aktualisieren**  
   Checkboxen, offene Fragen, neue Erkenntnisse und Entscheidungen pflegen.

7. **Erst danach nächsten Schnitt beginnen**

Große Phasen sollen nicht als ein einzelner unübersichtlicher Change umgesetzt werden.

---

## 11. Definition of Done für ein Arbeitspaket

Ein Arbeitspaket gilt als abgeschlossen, wenn:

- [ ] die fachliche Anforderung erfüllt ist,
- [ ] die Lösung in die bestehende Rails-Architektur passt,
- [ ] Berechtigungen, Mehrbenutzerbetrieb und Fehlerfälle berücksichtigt sind,
- [ ] relevante automatisierte Tests vorhanden und grün sind,
- [ ] die mobile Adminansicht geprüft wurde,
- [ ] Migrationen vorwärts und bei Bedarf rückwärts getestet wurden,
- [ ] neue Konfiguration dokumentiert ist,
- [ ] dieses Roadmap-Dokument aktualisiert wurde.

---

## 12. Entscheidungsprotokoll

| Datum | Entscheidung | Begründung | Phase |
|---|---|---|---|
| 2026-07-14 | Umsetzung im bestehenden Rails-Monolith und Hotwire-first | Bestehenden Stack nutzen und Betriebskomplexität gering halten | alle |
| 2026-07-14 | Anfrage und Auftrag sind getrennte Phasen | Nicht jede Anfrage wird zum Auftrag; die Auftragsübersicht bleibt sauber | 1 |
| 2026-07-14 | Neue Anfragen werden bewusst manuell übernommen | Keine scheinbare Zuständigkeit durch automatische Zuweisung; unzugewiesene Vorgänge werden prominent angezeigt | 1 |
| 2026-07-14 | Start-Admins sind Leopold Schmid, Dennis Bühler und Johannes Wiese | Persönliche Zugänge und klare Nachvollziehbarkeit im Dreierteam | 0, 1 |
| 2026-07-14 | Alle drei Start-Admins sind gleichberechtigt und verwalten interne Konten | Zunächst keine unnötige Rollenmatrix | 0, 1 |
| 2026-07-14 | Feste schlanke Anfrage- und Auftragsstatus | Klare Arbeitslage ohne überkomplexe State Machine | 1 |
| 2026-07-14 | Umwandlung Anfrage → Auftrag erfolgt manuell und übernimmt vorhandene Daten | Der passende Zeitpunkt variiert; Informationen dürfen nicht verloren gehen | 1 |
| 2026-07-14 | Ein Auftrag entspricht genau einer Veranstaltung | Entspricht dem aktuellen Geschäftsfall | 1–4 |
| 2026-07-14 | Kundendaten bewusst minimal | Name/Firma reicht; E-Mail und Telefon sind je Kommunikationsweg optional | 1 |
| 2026-07-14 | Notizen chronologisch, Anlagen zunächst PDF/Bild bis 25 MB | Gespräche und Unterlagen bleiben nachvollziehbar, ohne beliebige Dateikomplexität | 1 |
| 2026-07-14 | Im Alltag archivieren; DSGVO-Löschung/Anonymisierung getrennt | Historie schützen und rechtliche Löschpflichten dennoch erfüllen | alle |
| 2026-07-14 | Aktivitätshistorie protokolliert zentrale fachliche Ereignisse | Mehrbenutzerbetrieb benötigt Autor und Zeitpunkt wichtiger Änderungen | 1–4 |
| 2026-07-14 | Kein zusammengesetzter Vorbereitungsindikator im MVP | Konkrete offene Aufgaben und Fristen sind zunächst verständlicher | 1, 3 |
| 2026-07-14 | Interne Preise netto, Standardsatz zentral konfigurierbar | Saubere Kalkulation und Dokumentableitung | 2, 4 |
| 2026-07-14 | Produkt und Gebindevariante getrennt | 20/30/50 Liter gehören zum selben Produkt, bleiben aber eigene Varianten | 0, 2 |
| 2026-07-14 | Produktvariante wird nicht je Händler dupliziert | Händlerpreise und SKUs gehören in `SupplierOffering` | 0, 2 |
| 2026-07-14 | Südstar Standard, Getränke Beck zweite Quelle | Aktueller Praxisfall mit Erweiterungsmöglichkeit | 2 |
| 2026-07-14 | Beschaffungsprofile werden pro Händler konfiguriert | Vorlauf- und Rückgaberegeln lassen sich effizient wiederverwenden | 2, 3 |
| 2026-07-14 | Einkaufspreise erhalten Gültigkeit ab Datum | Preisänderungen bleiben historisch nachvollziehbar | 2 |
| 2026-07-14 | Keine doppelte Verfügbarkeitslogik im MVP | SupplierOffering und Beschaffungsprofil decken die bekannte Beschaffungslage ab | 2 |
| 2026-07-14 | Miet-/Lieferkosten dürfen im MVP kombiniert bleiben; Pfand optional vorbereiten | Bestehenden Ablauf unterstützen, ohne spätere Trennung zu verhindern | 2, 4 |
| 2026-07-14 | Arbeitszeitkategorien starten mit Organisation und Durchführung | Genügend Aussagekraft bei niedriger Pflegekomplexität | 2, 3 |
| 2026-07-14 | Angebotsgültigkeit standardmäßig 14 Tage | Einfacher editierbarer Standard | 2 |
| 2026-07-14 | Angebote versionieren und finalisierte Werte einfrieren | Verhandlungsstände bleiben reproduzierbar | 2 |
| 2026-07-14 | Beschaffungsquelle erst nach Bestätigung verbindlich auswählen | Preise und organisatorische Eignung können bis dahin verglichen werden | 3 |
| 2026-07-14 | Beschaffungsstatus: geplant, angefragt, bestätigt, erledigt | Schlanker Startworkflow | 3 |
| 2026-07-14 | Lieferantenangebote zunächst als Anlage oder Notiz | Kein eigenes Objekt ohne realen Bedarf | 3 |
| 2026-07-14 | Ressourcen sind konkrete Einheiten mit Kalenderreservierung | Ape und Kegerator müssen eindeutig und ohne Doppelbuchung planbar sein | 3 |
| 2026-07-14 | Zunächst keine automatischen Ressourcen-Puffer | Erfahrungen sammeln, bevor Zeiträume künstlich blockiert werden | 3 |
| 2026-07-14 | Aufgabe ist das Was, Checkliste das Wie | Organisation und operative Handgriffe bleiben sauber getrennt | 3 |
| 2026-07-14 | Checklistenpunkte dürfen Anleitungen und Medien verlinken | Packen, Aufbau und Reinigung werden praktisch nutzbar | 3 |
| 2026-07-14 | Veranstaltungsvorlagen sind je Reihe konfigurierbar | Golfplatz und andere Serien können unterschiedliche Felder und Prozessabkürzungen nutzen | 3 |
| 2026-07-14 | Offizielle Firmendaten zentral pflegen | Angebote und Rechnungen ziehen konsistente Stammdaten | 4 |
| 2026-07-14 | Getrennte Nummernkreise; Rechnung vorläufig `R-YYYY-000001` | Eindeutige, automatische und transaktionssichere Nummerierung | 2, 4 |
| 2026-07-14 | Zeitzone `Europe/Berlin` | Geschäftsprozesse finden lokal statt | alle |
| 2026-07-14 | Keine allgemeine CSV-Exportfunktion im MVP | Kein aktueller Nutzerbedarf; Backup/Restore bleibt separates Muss | Betrieb |
| 2026-07-14 | E-Mail-Eingang später providerunabhängig; Financial Cockpit separat | Kernprozess nicht mit späteren Integrationen überladen | 6 |

Weitere Entscheidungen zu Phase 4, Phase 5 und späteren Integrationen werden im nächsten Dialog ergänzt.

## 13. Empfohlener unmittelbar nächster Arbeitsschritt

### Arbeitspaket 0.1 – Architektur-Baseline gegen den aktuellen Hauptbranch

Die fachliche Richtung für Phase 1 bis Phase 3 ist weitgehend entschieden. Der nächste Schritt ist deshalb keine weitere allgemeine Ideensammlung, sondern eine kurze technische Bestandsanalyse mit konkretem Umsetzungsvorschlag.

- [ ] Hauptbranch aktualisieren und alle Tests ausführen.
- [ ] Aktuelles `AdminUser`-, `Inquiry`-, Produkt- und Variantenmodell dokumentieren.
- [ ] Migrationen für persönliche Admin-Profile, Aktivstatus und Mehrbenutzerverwaltung skizzieren.
- [ ] Anfrage-Status, manuelle Übernahme und unzugewiesene Dashboard-Warnung technisch entwerfen.
- [ ] `Order` und `Orders::CreateFromInquiry` einschließlich Datenübernahme und Idempotenz skizzieren.
- [ ] Produktdaten analysieren und Migrationsvorschlag für `Product`/`ProductVariant` erstellen.
- [ ] Datenmodell für `Supplier`, `ProcurementProfile`, `SupplierOffering` und Preisverlauf zeichnen.
- [ ] Datenmodell für `Offer`, Versionierung, Netto-Kalkulation und Nummernkreis zeichnen.
- [ ] Modelle für `Task`, `ChecklistTemplate`, Hilfen sowie `Resource`/`Reservation` skizzieren.
- [ ] Anlagen-, Archivierungs-, DSGVO- und Backup-Konzept kurz dokumentieren.
- [ ] Bestehendes Angebots-Template im Repository oder als Beispieldokument bereitstellen und technisch prüfen.
- [ ] Ergebnis als kleines Architektur-Kapitel beziehungsweise ADR in diesem Dokument ergänzen.

Danach kann Phase 1 mit einem ersten vertikalen Schnitt beginnen: **Admin-Mehrbenutzerverwaltung plus manuell übernommene Anfrage mit Status und Chronik**.
