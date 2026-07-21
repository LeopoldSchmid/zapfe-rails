# Desktop Review 2026-03-17

## Anlass

In den letzten Iterationen wurden `drinks` und `calculator` stark fuer Mobile verbessert. Auf Desktop ist die Funktionalitaet vorhanden, die Flaechen nutzen den verfuegbaren Raum aber noch nicht konsequent. Mehrere Bereiche wirken wie hochskalierte Mobile-Layouts statt wie bewusst gesetzte Desktop-Interfaces.

Basis dieses Reviews:
- aktuelle Public-Views im Repo
- bestehende globale Styles in `app/assets/tailwind/application.css`
- Stand nach den Mobile-Optimierungen vom 2026-03-17

Wichtig:
- Fokus dieses Dokuments ist Layout, Informationshierarchie und Interaktionsdesign auf Desktop.
- Es ist keine Textfreigabe. Copy-Aenderungen sind hier nicht implizit mitgemeint.

## Kurzfazit

Die Seite ist auf Desktop nicht kaputt, aber in mehreren Kernflows noch zu schmal, zu gestapelt und zu sehr auf mobile Muster ausgerichtet:
- zu viele Bereiche bleiben einspaltig, obwohl mehr Raum verfuegbar ist
- Utility-Controls sind auf grossen Screens zu klein und zu stark verdichtet
- mobile FAB- und Drawer-Muster bleiben auf Desktop aktiv, obwohl dort inline oder seitliche Loesungen ruhiger waeren
- wichtige Beziehungen zwischen Navigation, Inhalt, Filtern und Zusammenfassungen werden auf Desktop nicht stark genug ausgespielt

Der groesste Hebel ist nicht "mehr Deko", sondern ein klarer Desktop-Modus fuer die Hauptflows:
- mehr Zwei-Spalten- und Drei-Spalten-Logik
- staerkere Seitengelaender fuer Filter und Zusammenfassungen
- weniger mobile Floating-Pattern auf grossen Screens
- klarere Breitenfuehrung und Section-Rhythmik

## Seite-uebergreifende Findings

### 1. Der Desktop-Modus ist visuell noch zu sehr ein hochskaliertes Mobile

Aktuell:
- viele Komponenten behalten auf Desktop nahezu dieselbe innere Dichte wie auf Mobile
- Controls bleiben kompakt, obwohl mehr Raum da ist
- vertikale Schrittfolge dominiert auch dort, wo parallele Information sinnvoll waere

Folge:
- grosse Screens fuehlen sich weniger praezise und hochwertig an
- wichtige Steuerung und Ruhemomente konkurrieren auf derselben vertikalen Achse

Empfehlung:
- fuer `lg` und `xl` gezielt andere Kompositionsregeln einfuehren
- nicht nur Spaltenzahl erhoehen, sondern echte Desktop-Hierarchien bauen

### 2. Sticky-Elemente sind noch mobil gedacht

Aktuell:
- auf `drinks` ist die obere Leiste sticky
- FABs bleiben auch auf Desktop voll aktiv
- Drawer/Sheets sind mobile-first geloest

Risiko:
- auf Desktop entstehen mehrere schwebende Ebenen mit unterschiedlicher Logik
- Header, Sticky-Bar, FAB und Side-Panels koennen visuell gegeneinander arbeiten

Empfehlung:
- pro Seite definieren, welches Sticky-Element die primaere Rolle hat
- FABs auf Desktop nur behalten, wenn sie wirklich Mehrwert bringen
- ansonsten in die normale Seitenstruktur integrieren

### 3. Breitenfuehrung ist inkonsistent

Aktuell:
- `page-wrap` geht bis `max-w-7xl`
- `calculator` begrenzt sich auf `max-w-5xl`
- einzelne Inhaltsbloecke sind sehr breit, andere sehr schmal

Folge:
- Desktop wirkt je nach Seite unterschiedlich dicht
- Conversion-relevante Bereiche sind teilweise zu schmal, visuelle Seiten dagegen teilweise zu breit

Empfehlung:
- pro Seitentyp feste Breitenstrategie definieren:
  - Marketing/Page Story: `max-w-6xl` bis `max-w-7xl`
  - Tool/Calculator: aeussere Shell breit, inhaltlich in Hauptspalte + Rail gliedern
  - Katalog/Drinks: volle Breite fuer Steuerung und Raster, nicht fuer Fliesstext

### 4. Desktop braucht staerkere Sekundaer-Rails

Aktuell:
- Filter, Hinweise, Count, Warenkorb und Hilfen liegen oft im Hauptfluss

Folge:
- zu viele Aufgaben finden in derselben Spalte statt
- Desktop-Vorteil "gleichzeitig sehen und handeln" wird verschenkt

Empfehlung:
- gezielt mit rechter Rail oder linker Filterspalte arbeiten
- alles, was nicht Kerninhalt ist, aus der Hauptspalte herausziehen

## Seitenanalyse

## 1. `/drinks`

Relevante Datei:
- `app/views/pages/drinks.html.erb`

### Ist-Zustand

Positiv:
- Suche ist prominent
- Filter sind funktional vorhanden
- Produktkarten und Featured-Stil funktionieren
- Sticky-Suche hilft im langen Katalog

Desktop-Probleme:
- die Suchleiste ist im Kern immer noch ein Mobile-Control-Cluster
- Filter liegen hinter einem Toggle, obwohl auf Desktop genug Platz waere
- der Warenkorb bleibt ein rechter Drawer wie auf Mobile
- der FAB zum Preisrechner wirkt auf Desktop weniger elegant als eine feste Inline-/Rail-Loesung
- das Grid mit `lg:grid-cols-3` ist fuer breite Screens eher defensiv

### Zielbild Desktop

Desktop sollte hier wie ein echter Katalog wirken:
- links oder oben klarer Steuerbereich
- Produkte sofort sichtbar
- Filter permanent sichtbar
- Warenkorb als ruhige rechte Rail oder breiteres Desktop-Sidepanel
- vier Karten pro Reihe auf `xl`, wenn Bildmaterial und Kartenbreite es tragen

### Konkrete Umsetzungsvorschlaege

#### Variante A: Linke Filterspalte, rechte Produktflaeche

Empfohlen fuer `lg+`.

Layout:
- linke Spalte: Suche, Kategorien, Marken, weitere Filter, Reset
- rechte Hauptspalte: Count, Hilfe-Info, Produkte

Vorteile:
- bester Desktop-Mehrwert
- Filter bleiben sichtbar
- Produktflaeche wirkt wie echter Katalog

Nachteile:
- groesserer Umbau als reine Responsive-Nachjustierung

#### Variante B: Topbar + zweite feste Filterzeile

Weniger invasiv.

Layout:
- erste Zeile sticky: Suche, Cart, ggf. CTA
- zweite Zeile sichtbar: Kategorien/Marke/weitere Filter in kompakter Desktop-Toolbar

Vorteile:
- geringer Eingriff
- nah am aktuellen Mobile-Modell

Nachteile:
- auf sehr breiten Screens weniger sauber als Variante A

### Konkrete Empfehlungen fuer `/drinks`

- `#toggle-drinks-filters` auf Desktop ausblenden und das Panel standardmaessig sichtbar machen.
- Das Filterpanel fuer `lg+` als feste Spalte oder als permanent sichtbare Toolbar rendern.
- Den Warenkorb auf Desktop nicht nur als schmalen Drawer behalten.
  - Option 1: rechte sticky Rail mit Zwischensumme und Positionen
  - Option 2: breiteres Panel mit mehr Abstand zum Header und klarerem Schliessen
- Das Produktgrid auf `xl:grid-cols-4` pruefen.
- Den FAB `Zum Preisrechner` auf Desktop eher in die Seitenstruktur integrieren:
  - als rechte Rail-CTA
  - oder als fester Button im oberen Steuerbereich
- Die Hilfe `Was laesst sich zapfen?` auf Desktop eher als kleines Popover oder Inline-Help im Count-/Toolbar-Bereich halten, nicht als mobileartige Vollbreiten-Komponente.

### Implementierungsreihenfolge fuer `/drinks`

1. Desktop: Filterpanel dauerhaft sichtbar machen.
2. Desktop: Produktgrid auf 4 Spalten pruefen.
3. Desktop: Warenkorb als Rail oder Desktop-Panel neu setzen.
4. Desktop: FAB in festen CTA-Bereich ueberfuehren.

## 2. `/calculator`

Relevante Datei:
- `app/views/pages/calculator.html.erb`

### Ist-Zustand

Positiv:
- Mobile ist deutlich klarer geworden
- Schritte sind lesbar
- Featured-Getraenke und Suchlogik sind vorhanden
- Warenkorb/Preissumme existieren

Desktop-Probleme:
- der Rechner bleibt weitgehend ein langer Einspalten-Flow
- `max-w-5xl` ist fuer diesen Flow eher zu vorsichtig
- die Preis-/Warenkorb-Sichtbarkeit koennte auf Desktop deutlich staerker sein
- der Featured-Getraenkebereich bleibt als horizontaler Track mobile-first
- wichtige Entscheidungen koennten auf Desktop enger nebeneinander stehen

### Zielbild Desktop

Der Rechner sollte sich auf Desktop wie ein Arbeitsbereich anfuehlen:
- linke Hauptspalte fuer Konfiguration
- rechte sticky Rail fuer Preis, Auswahl, Status und CTA
- Getraenkeauswahl nicht als Mobile-Karussell, sondern als visuell gefuehrter Auswahlbereich

### Konkrete Empfehlungen fuer `/calculator`

- Aeussere Shell auf Desktop in zwei Spalten aufbauen:
  - links: Schritte 1 bis 4 + Kontakt
  - rechts: sticky Preiszusammenfassung/Warenkorb
- `max-w-5xl` fuer Desktop pruefen; wahrscheinlich ist `max-w-6xl` oder eine volle `page-wrap`-Shell stimmiger.
- Die Produktwahl in Schritt 1 auf Desktop optisch gleichwertiger verteilen.
  - aktuell ist der Mittel-Case gut akzentuiert, die deaktivierten Optionen wirken jedoch eher wie mobile Karten im Desktop-Raster
- Schritt 2 und Schritt 3 koennen auf Desktop perspektivisch in einem gemeinsamen Zweispalten-Block stehen.
- Schritt 4 braucht fuer Desktop einen echten Auswahlmodus:
  - Karussell auf Mobile behalten
  - auf Desktop lieber Grid oder mehrspaltigen Track mit sichtbarerem Vergleich
- Die interne CTA `-> zu allen Getränken` sollte auf Desktop nicht wie ein isolierter Mobile-Button im Tool wirken, sondern als Sekundaeraktion im Steuerkopf des Getraenkeblocks.
- Der aktuelle Warenkorbblock in der Hauptspalte sollte auf Desktop in die rechte Rail wandern.

### Implementierungsreihenfolge fuer `/calculator`

1. Sticky Summary-Rail auf Desktop.
2. Schritt 4 auf Desktop von Karussell zu Grid/Hybrid umbauen.
3. Rechnerbreite und Schrittkomposition auf `lg+` neu setzen.
4. CTA- und Utility-Elemente fuer Desktop entkoppeln von Mobile-Mustern.

## 3. `/events`

Relevante Datei:
- `app/views/pages/events.html.erb`

### Ist-Zustand

Positiv:
- Hero und Medien sind bereits deutlich desktoptauglicher als die Tool-Seiten
- grosse Medienflaechen funktionieren
- Sektionen haben brauchbare Rhythmen

Desktop-Probleme:
- einige Slider-/Scrollmuster bleiben als mobile Herkunft sichtbar
- die Page ist stark zentriert und teilweise vorsichtig gesetzt
- FABs koennen auf Desktop den ruhigen Lesefluss stoeren

### Konkrete Empfehlungen fuer `/events`

- Die Systemkarten im Mietoptionen-Bereich auf Desktop noch klarer als gleichwertiges 3er-Raster inszenieren.
- Horizontale Mobile-Hinweise und Verlaufskanten auf Desktop komplett vermeiden, sobald Grid aktiv ist.
- Einzelne Abschnitte duerfen auf Desktop asymmetrischer werden:
  - Text links, Medien rechts, dann bewusst wechseln
- FABs auf Desktop evaluieren:
  - Back-FAB ist mobil sinnvoll
  - auf Desktop ist eine normale Section-Navigation oder Inline-Back-Loesung oft ruhiger

## 4. `/solutions`

Relevante Datei:
- `app/views/pages/solutions.html.erb`

### Desktop-Hebel

Die Seite ist schon naeher am Marketing-Desktop-Niveau als `drinks` und `calculator`. Der naechste Schritt ist weniger "responsive fixen" und mehr "Komposition schaerfen":
- mehr asymmetrische Spannungen zwischen Medien und Text
- staerkere Nutzung grosser Bildflaechen
- FABs auf Desktop hinterfragen
- vergleichende Loesungsbloecke noch klarer als Desktop-Raster ausspielen

## 5. `/`

Relevante Datei:
- `app/views/pages/home.html.erb`

### Desktop-Hebel

Die Startseite ist nicht der akuteste Schmerzpunkt, aber fuer Konsistenz relevant:
- Hero koennte auf Desktop noch mutiger gesetzt werden
- CTA-Hierarchie darf auf grossem Screen staerker gefuehrt werden
- Beweis-/Proof-Bloecke sollten sich klar von Utility- und CTA-Zonen unterscheiden

## Priorisierung

### Prioritaet A

Sofort sinnvoll, direkt conversion-relevant:
- `/drinks`: permanente Desktop-Filter
- `/drinks`: Desktop-Warenkorb neu loesen
- `/calculator`: sticky Summary-Rail
- `/calculator`: Desktop-Auswahl fuer Getraenke neu setzen

### Prioritaet B

Sichtbar wertvoll, mittlerer Aufwand:
- `/drinks`: FAB auf Desktop in Inline-CTA ueberfuehren
- `/calculator`: Rechnerbreite und Schrittgruppierung optimieren
- `/events` und `/solutions`: FAB-Verhalten auf Desktop bereinigen

### Prioritaet C

Qualitaets- und Markenhebel:
- Startseite asymmetrischer und mutiger setzen
- globale Desktop-Regeln fuer Rails-Komponenten festziehen

## Empfohlener Umsetzungsplan

## Phase 1: Tools desktoptauglich machen

Ziel:
- `drinks` und `calculator` als echte Desktop-Arbeitsflaechen

Massnahmen:
- Desktop-Filterstrategie fuer `drinks`
- Desktop-Warenkorb fuer `drinks`
- Sticky Summary-Rail fuer `calculator`
- Desktop-Grid fuer Featured-/Schnellauswahl im Rechner

## Phase 2: Floating-Muster bereinigen

Ziel:
- mobile FAB- und Drawer-Pattern auf Desktop zuruecknehmen

Massnahmen:
- FAB-Regeln pro Breakpoint definieren
- Desktop-spezifische CTA-Platzierungen festlegen
- Drawer vs. Rail pro Seite entscheiden

## Phase 3: Marketingseiten kompositorisch schaerfen

Ziel:
- `events`, `solutions`, `home` auf grossen Screens hochwertiger und entschlossener wirken lassen

Massnahmen:
- asymmetrischere Layouts
- klarere Medien-/Text-Kontraste
- bewusstere Section-Breiten und Rhythmen

## Technische Hinweise

Die meisten Verbesserungen brauchen keine neuen Datenmodelle. Es geht primaer um:
- Breakpoint-spezifische Layoutregeln in `app/assets/tailwind/application.css`
- Umstrukturierung einzelner View-Container in:
  - `app/views/pages/drinks.html.erb`
  - `app/views/pages/calculator.html.erb`
  - optional spaeter `app/views/pages/events.html.erb`
  - optional spaeter `app/views/pages/solutions.html.erb`
  - optional spaeter `app/views/pages/home.html.erb`

Sinnvoll waere, fuer diese Phase ein kleines Set an Desktop-Helferklassen einzufuehren, statt jede Seite nur inline mit Tailwind-Utility-Ketten zu loesen. Kandidaten:
- Desktop-Rail-Layout fuer Tool-Seiten
- Desktop-Filterpanel-Stil
- Desktop-Toolbar-Stil
- Desktop-CTA-Slot

## Klare Empfehlung

Wenn nur ein Bereich als naechstes umgesetzt wird, dann:

1. `drinks` auf Desktop zu einem echten Katalog mit sichtbaren Filtern und klarer Cart-Logik machen.
2. `calculator` auf Desktop mit rechter sticky Preis-/Warenkorb-Rail nachziehen.

Das sind die zwei Seiten, auf denen Desktop aktuell am staerksten nach "mobile first, aber noch nicht mobile and desktop equally intentional" aussieht.
