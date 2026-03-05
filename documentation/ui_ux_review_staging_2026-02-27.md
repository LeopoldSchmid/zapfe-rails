# UI/UX Review Staging (`staging.zapfe.duzend.net`)

Stand: 2026-02-27

Basis dieses Reviews:
- Live-Staging (`/`, `/calculator`)
- aktuelle Rails-Templates im Repo
- visuelle Referenz von `https://www.boltbar.com/` als Partner-/Benchmark-Input fuer die geplante Seite `/customizing`

## Kurzfazit

Der aktuelle Auftritt ist funktional, klar und deutlich professioneller als ein typischer Rohbau. Farbwelt, Navigation und Hauptflows sind bereits konsistent. Die Seite verkauft heute aber vor allem "mobile Zapfanlage" und noch zu wenig den eigentlichen Mehrwert: schnellerer Ausschank, Self-Service, weniger Personalaufwand, skalierbare Setups und die besondere Kombination aus Hardware, Service und Bezahlfunktion.

Die groessten UX-Hebel liegen aktuell nicht in "mehr Design", sondern in:
- klarerer Positionierung oberhalb der Falz
- mehr Vertrauen/Beweis statt Platzhalter-Content
- weniger kognitive Last im Kalkulator
- sauberer Vorbereitung fuer ein zweites Produktversprechen: `Custom Solutions`

## Was schon gut ist

- Das Brand-Grundgeruest steht: Amber/Navy ist wiedererkennbar und passt zum Produkt.
- Die Informationsarchitektur ist fuer eine V1 nachvollziehbar: Startseite, Preisrechner, Veranstaltungen, Getraenke, Kontakt.
- Der Kalkulator ist als Conversion-Asset richtig priorisiert und direkt erreichbar.
- Die Produkt-/Getraenkeauswahl fuehlt sich grundsaetzlich nach echtem Tool an, nicht nur nach einer Marketingseite.
- Mobile Navigation ist einfach und funktional.

## Wichtigste Findings

### 1. Positionierung auf der Startseite ist noch zu generisch

Die Hero-Section sagt im Kern "frisch gezapfte Getraenke ueberall und jederzeit". Das ist verstaendlich, aber noch zu austauschbar. Der eigentliche Unterschied von Zapfe ist staerker:
- Self-Service
- optional kontaktloses Bezahlen
- autark/mobil
- weniger Schlange, weniger Personalbindung

Aktuell muss man erst weiter unten lesen, um das zu verstehen. Das kostet Conversion, weil die Differenzierung nicht sofort sitzt.

Empfehlung:
- Hero-Headline staerker auf Nutzen statt Produktform fokussieren.
- Direkt im sichtbaren Bereich 2 bis 3 harte Benefits als kurze Proof-Chips oder Kennzahlen zeigen.
- Neben dem primaeren CTA einen zweiten CTA anbieten: z. B. "So funktioniert's" oder "Loesungen ansehen".

### 2. Der Trust-Layer ist aktuell zu schwach

Die Sektion "Was unsere Kunden bald sagen werden" mit Platzhalter-Zitat ist im aktuellen Zustand eher schaedlich als neutral. Solange noch keine echten Stimmen vorliegen, signalisiert das "wir haben noch keine belastbaren Referenzen".

Empfehlung:
- Platzhalter-Testimonial vorerst entfernen oder durch echte Referenzbausteine ersetzen.
- Besser als Fake-Social-Proof:
  - reale Veranstaltungsarten
  - echte Bilder im Einsatz
  - konkrete Leistungsversprechen
  - kurze Betriebsfakten (z. B. Aufbau, Strombedarf, Zahlungsoption, Servicegebiet)

### 3. Die Seite zeigt zu wenig "Beweis", zu viel generische Marketingtexte

Mehrere Bereiche sind sauber aufgebaut, aber inhaltlich noch sehr allgemein. Vor allem die Startseite wiederholt Nutzen semantisch, statt konkrete Sicherheit zu geben.

Es fehlen derzeit:
- echte Einsatzbeispiele mit Outcome
- klare "fuer wen ist was?"-Unterscheidung
- technische oder operative Fakten
- sichtbare Hinweise auf reale Produktvarianten

Gerade fuer ein B2B/B2Event-Angebot ist das relevant: Besucher wollen schnell pruefen, ob das Setup zu ihrem Anlass, Standort und Budgetrahmen passt.

### 4. Der Reveal-Effekt ist visuell nett, aber als Standard riskant

Mehrere Sektionen werden initial mit `opacity: 0` versteckt und erst per `IntersectionObserver` eingeblendet. Das erzeugt Bewegung, macht den Content aber komplett von sauber laufendem JS abhaengig.

Risiko:
- Bei langsamer Initialisierung wirkt die Seite kurzfristig "leer".
- Bei JS-Fehlern oder Edge-Cases bleiben Inhalte unsichtbar.
- Fuer Marketingseiten ist "Content standardmaessig sichtbar" meist die robustere Wahl.

Empfehlung:
- Reveal nur als Enhancement nutzen, nicht als harte Sichtbarkeitsvoraussetzung.
- Default sichtbar, Animation nur zusaetzlich.

### 5. Die Startseite fuehlt sich noch zu vorsichtig an

Visuell ist alles ordentlich, aber aktuell noch sehr "safe". Das ist kein Designfehler, aber es verschenkt Marke. Fuer ein Produkt, das physisch auffaellt und Event-Charakter hat, darf die visuelle Sprache mutiger werden:
- markantere Typohierarchie
- klarere Section-Rhythmen
- staerkere Kontraste zwischen Verkaufsargumenten, Referenzen und CTA-Zonen

Wichtig: Nicht "mehr Effekte", sondern mehr gestalterische Entschlossenheit.

### 6. Der Kalkulator ist wertvoll, aber mental zu schwergewichtig

Der Preisrechner ist funktional stark, aber er verlangt sehr frueh viele Entscheidungen:
- Mietmodell
- Zeitraum
- Getraenke
- Zusatzoptionen
- Lieferung
- Kontaktdaten

Das ist fuer warme Leads okay, aber fuer Erstkontakt relativ viel in einem Rutsch. Besonders auf Mobile wirkt die Seite lang und transaktional, bevor genug Sicherheit aufgebaut wurde.

Empfehlung:
- den Flow klarer in 3 Schritte gliedern:
  - Setup waehlen
  - Getraenke konfigurieren
  - Anfrage absenden
- eine permanente oder sticky Preiszusammenfassung ergaenzen
- Zwischensummen und Fortschritt staerker kommunizieren
- die Kontaktsektion visuell als "letzter Schritt" inszenieren

### 7. Der Kalkulator kommuniziert Pflicht vs. Optional noch nicht sauber

Die Lieferung ist per Checkbox aktiv, textlich aber so formuliert, als sei sie faktisch Pflicht. Das fuehlt sich widerspruechlich an.

Aktueller Eindruck:
- UI suggeriert Wahlfreiheit
- Copy suggeriert Einschraenkung

Empfehlung:
- Wenn Lieferung aktuell Pflicht ist: nicht als optionaler Toggle darstellen.
- Stattdessen klarer Hinweis:
  - "Aktuell nur mit Lieferung"
  - Lieferadresse als normaler Pflichtblock
- Formulierung sprachlich straffen; die aktuelle Copy wirkt improvisiert.

### 8. Kontaktseite und Kalkulator konkurrieren leicht miteinander

Die Kontaktseite erklaert Buchung ueber den Preisrechner, bietet aber parallel noch ein vollwertiges Kontaktformular. Das ist nicht falsch, aber der Unterschied der beiden Einstiege ist noch nicht klar genug.

Empfehlung:
- Kontaktseite staerker als "Beratung / Sonderanfrage / Rueckruf" positionieren.
- Kalkulator klar als "konkrete Preisanfrage" labeln.
- So entstehen zwei erkennbare Intent-Pfade statt doppelte Formulare.

### 9. Veranstaltungen sind aktuell eher Galerie als Vertriebsargument

Die Event-Karten funktionieren, aber als naechster Reifegrad sollten sie weniger "Archiv" und mehr "Case Study light" sein.

Empfehlung:
- pro Karte moeglichst ein klarer Outcome
- z. B. Anlass, Groesse, Setup-Typ, Besonderheit
- mittelfristig Filter nach Anlass oder Aufbauform denkbar

## Priorisierte Empfehlungen (vor Umsetzung)

### Prioritaet A: sofort sinnvoll

- Platzhalter-Testimonial auf der Startseite entfernen oder ersetzen.
- Hero-Message schaerfen: Nutzen und Differenzierung frueher und konkreter.
- Kalkulator sprachlich bereinigen, vor allem bei Lieferung/Pflichtfeldern.
- Reveal-Verhalten robust machen, damit Content nicht von JS-Sichtbarkeit abhaengt.

### Prioritaet B: hoher Wirkungstreiber

- Startseite um echte Vertrauensbausteine erweitern:
  - reale Referenzen
  - klare Betriebsfakten
  - evtl. kleine Kennzahlen
- Kalkulator in deutlicher erkennbare Schritte gliedern.
- CTA-Hierarchie in Header und Hero schaerfen.

### Prioritaet C: naechster Marken- und Sales-Schritt

- `/events` zu staerkeren Referenzkarten ausbauen.
- neue Seite `/customizing` als zweites, deutlich unterscheidbares Angebotsversprechen einfuehren.

## Empfehlung fuer die neue Seite `/customizing`

Die neue Seite sollte nicht nur eine zusaetzliche Unterseite sein, sondern ein zweites klares Verkaufsnarrativ neben "mobile Vermietung":

- Vermietung fuer Events = schnell, mobil, unkompliziert
- Custom Solutions = dauerhaft, individuell, skalierbar, marken- oder standortbezogen

Wichtig ist, dass `/customizing` nicht wie ein Fremdkoerper wirkt. Sie sollte im Zapfe-Brand bleiben, aber in der Argumentation naeher an B2B-Investitionslogik sein.

## Inhaltliche Positionierung fuer `/customizing`

Empfohlene Botschaft:
- "Neben mobilen Event-Setups bauen wir auch individuelle Self-Service-Loesungen fuer feste oder wiederkehrende Einsatzorte."

Das sollte drei Ebenen sauber unterscheiden:
- `Ape`: ikonischer, mobiler Blickfang / Event-nahe Loesung
- `Custom Box`: konkretes Beispiel fuer ein individuelles, gebrandetes Modul
- `Boltbar`-Systeme: skalierbare Self-Service-Systeme fuer groessere oder dauerhafte Setups

So wirkt die Seite nicht wie "wir machen auch noch irgendwas", sondern wie ein sauber erweitertes Portfolio.

## Empfohlene Struktur fuer `/customizing`

### 1. Hero

Nicht zu verspielt. Klare Business-Aussage:
- individuelle Self-Service-Loesungen
- von kompakten Sonderbauten bis zu skalierbaren Ausschank-Systemen

CTA:
- "Projekt anfragen"
- optional: "Loesungsbeispiele ansehen"

### 2. Loesungsmatrix

Ein Vergleichsblock mit 3 Karten:
- Ape
- Custom Box
- Scalable Self-Service Systems

Jede Karte sollte beantworten:
- fuer wen?
- wo im Einsatz?
- mobil / semi-permanent / permanent?
- Branding / Integration / Payment?

Das hilft sofort bei Selbstselektion.

### 3. Beispiel "Custom Box"

Hier sollte die konkrete Box gross ausgespielt werden:
- Hero-Bild / Render / Foto
- 3 bis 5 Kerneigenschaften
- warum individuelle Bauform sinnvoll ist

Das ist der beste Beweis dafuer, dass "custom" wirklich gebaut wird und nicht nur ein Vertriebswort ist.

### 4. Partner-Block mit Boltbar

Boltbar sollte als Kompetenzverstaerker eingebunden werden, nicht als Dominator.

Empfehlung fuer die Erzaehlrichtung:
- Zapfe ist lokaler Ansprechpartner / Umsetzungspartner fuer Deutschland
- Boltbar liefert bewaehrte, skalierbare Systembasis
- gemeinsam entstehen passende Loesungen fuer Standort, Publikum und Durchsatz

Wichtig:
- nicht die komplette Boltbar-Seite nachbauen
- lieber deren Produktlogik in kuratierter, lokal relevanter Form uebersetzen

### 5. Prozess

Kurzer B2B-Prozess in 4 Schritten:
- Bedarf klaeren
- Konzept definieren
- System bauen / integrieren
- Inbetriebnahme und Rollout

Das nimmt Projektrisiko raus.

### 6. Abschluss-CTA

Zwei Intent-Pfade:
- "Projekt besprechen"
- "Mobile Loesung mieten"

So kann die Seite sowohl neue B2B-Anfragen erzeugen als auch Nutzer auffangen, die eigentlich nur eine Event-Loesung brauchen.

## Was wir uns von Boltbar abschauen sollten und was nicht

Sinnvoll von Boltbar:
- klare Produktsegmentierung
- staerkere Business-Sprache
- weniger "nice", mehr "Outcome"
- modulare Angebotslogik

Nicht 1:1 uebernehmen:
- die komplette visuelle Sprache
- zu viel englisch gepraegte SaaS-Tonalitaet
- zu breite Produktmasse ohne lokale Einordnung

Zapfe sollte nahbarer und greifbarer bleiben, aber in der Argumentation professioneller und belastbarer werden.

## Vorschlag fuer den naechsten Schritt

Sinnvolle Umsetzungsreihenfolge:
1. Startseite textlich/strukturell schaerfen
2. Kalkulator UX vereinfachen
3. Konzept und Wireframe fuer `/customizing` definieren
4. danach gezielt visuell veredeln

Damit optimieren wir erst Verstaendlichkeit und Conversion, bevor wir groessere Layout-Arbeit machen.
