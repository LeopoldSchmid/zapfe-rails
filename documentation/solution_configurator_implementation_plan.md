# Solution Configurator Umsetzungsplan

Dieser Plan zerlegt den MVP in kleine, nacheinander abarbeitbare Schritte. Jeder Schritt soll einen pruefbaren Zwischenstand erzeugen.

## Phase 0: Vorarbeit und Entscheidungen

### Schritt 0.1: Asset-Konvention festlegen

Ziel:

- Einheitliche Namenskonvention fuer 3D-Modelle, Meshes, Materialien und Branding-Flaechen definieren.

Aufgaben:

- Mesh-Namen fuer Kegerator und Ape festlegen.
- Material-Slots benennen, z. B. `body`, `frame`, `tap_1`, `tap_2`, `tablet`, `branding_front`.
- Branding-Zonen festlegen.
- Entscheiden, ob SVG-Logo-Uploads im MVP erlaubt sind oder erst nur PNG/WebP.

Ergebnis:

- Kurzes Dokument oder Abschnitt in der MVP-Doku mit Namenskonvention.
- Erste Liste der benoetigten Mesh-/Material-Bindings.

Abnahme:

- Es ist klar, welche Mesh-Namen das GLB-Modell liefern muss.
- Es ist klar, welche Modellteile ein-/ausblendbar oder faerbbar sein muessen.

### Schritt 0.2: Platzhalter-Assets vorbereiten

Ziel:

- Der Konfigurator kann gebaut werden, bevor finale fotorealistische Modelle fertig sind.

Aufgaben:

- Ein einfaches Kegerator-GLB vorbereiten.
- Ein einfaches Ape-GLB vorbereiten oder zuerst mit Kegerator starten.
- Test-Texturen/HDRI/Hintergruende fuer die festen Szenen sammeln oder Platzhalter definieren.

Ergebnis:

- Lokale Testassets fuer Entwicklung.

Abnahme:

- Ein GLB kann lokal im Browser geladen werden.
- Die relevanten Meshes sind eindeutig benannt.

## Phase 1: Rails-Domaene und Datenbasis

### Schritt 1.1: Basis-Routing anlegen

Ziel:

- `/solutions/configurator` existiert und zeigt eine erste Konfigurator-Seite.

Aufgaben:

- Route anlegen.
- Controller fuer den Konfigurator anlegen.
- View mit Grundlayout anlegen.
- Bestehende `solutions`-Seite nicht brechen.

Ergebnis:

- Leere oder einfache Konfigurator-Seite ist lokal erreichbar.

Abnahme:

- `bin/dev` startet die App.
- `http://localhost:3000/solutions/configurator` ist erreichbar.
- Es gibt keine Regression auf bestehenden Seiten.

### Schritt 1.2: Datenmodell fuer Solutions anlegen

Ziel:

- Kegerator und Ape koennen als eigene Konfigurator-Domaene verwaltet werden.

Aufgaben:

- Models/Migrations fuer `Solution`, `SolutionVariant`, `ConfigurationSession` anlegen.
- Optional direkt `Scene` anlegen.
- Active Storage fuer Logo-Uploads/Snapshots nutzen.
- Validierungen und Associations definieren.

Ergebnis:

- Grunddatenmodell existiert.

Abnahme:

- Rails-Model-Tests fuer Associations und Validierungen bestehen.
- Kegerator und Ape koennen per Seed/YAML angelegt werden.

### Schritt 1.3: YAML-Konfiguration einfuehren

Ziel:

- Optionen, Preise, Regeln und 3D-Bindings koennen datengetrieben geladen werden.

Aufgaben:

- `config/solution_configurator.yml` anlegen.
- Loader-Service bauen, z. B. `SolutionConfigurator::Config`.
- YAML-Struktur fuer Kegerator und Ape definieren.
- Erste Optionen und Preis-Deltas erfassen.

Ergebnis:

- App kann die Konfigurator-Daten aus YAML lesen.

Abnahme:

- Test prueft, dass YAML valide geladen wird.
- Kegerator hat Varianten 1 Hahn und 2 Haehne.
- Ape hat Variante Ape 50.
- Optionen und Preise sind aus YAML abrufbar.

## Phase 2: Regel- und Preislogik

### Schritt 2.1: Preisberechnung bauen

Ziel:

- Aus einer Auswahl entsteht eine nachvollziehbare Preisindikation.

Aufgaben:

- Pricing-Service bauen.
- Basispreis + Optionspreise berechnen.
- Preis-Snapshot strukturieren.
- Fehlerfaelle behandeln, z. B. unbekannte Option.

Ergebnis:

- Preisindikation kann serverseitig berechnet werden.

Abnahme:

- Test: Basispreis + ausgewaehlte Optionen ergeben korrekten Gesamtpreis.
- Snapshot enthaelt Basispreis, Optionspositionen und Gesamtpreis.

### Schritt 2.2: Regel-Engine MVP bauen

Ziel:

- Einfache `requires`- und `excludes`-Regeln werden korrekt angewendet.

Aufgaben:

- Rule-Service bauen.
- `requires`, `excludes`, `auto_selects` unterstuetzen.
- Regeln aus YAML laden.
- Rueckgabe fuer UI definieren: deaktivierte Optionen, erzwungene Optionen, Hinweise.

Ergebnis:

- Bezahlfunktion erzwingt Tablet.
- Kegerator hat nur Passivkuehlung.
- Ape hat nur Durchlaufkuehler.

Abnahme:

- Test: Bezahlfunktion ohne Tablet ist ungueltig oder Tablet wird automatisch gesetzt.
- Test: Kegerator kann keine Durchlaufkuehler-Option waehlen.
- Test: Ape kann keine Passivkuehlung waehlen.

## Phase 3: Frontend-Grundgeruest

### Schritt 3.1: Konfigurator-UI ohne 3D bauen

Ziel:

- Nutzer kann Solutions, Varianten und Optionen auswaehlen, noch ohne echte 3D-Darstellung.

Aufgaben:

- Stimulus-Controller fuer Konfigurator-State anlegen.
- Solution-/Variantenwahl bauen.
- Schrittweise Optionen darstellen.
- Regelhinweise und deaktivierte Optionen anzeigen.
- Preisindikation aktualisieren.

Ergebnis:

- Funktionaler Formular-/State-Prototyp.

Abnahme:

- Kegerator und Ape sind auswählbar.
- Optionen wechseln je Solution.
- Bezahlfunktion erzwingt oder sperrt Tablet korrekt.
- Preisindikation aktualisiert sich sichtbar.

### Schritt 3.2: Konfiguration speichern

Ziel:

- Ausgewaehlte Konfiguration kann persistiert werden.

Aufgaben:

- Create/Update-Endpunkt fuer `ConfigurationSession`.
- Public Token generieren.
- Selected Options, Preis-Snapshot und Scene speichern.
- Resume-Route vorbereiten.

Ergebnis:

- Konfiguration wird in der Datenbank gespeichert.

Abnahme:

- Nutzer kann eine Konfiguration speichern.
- Gespeicherte Konfiguration kann per Token wieder geladen werden.
- Preis-/Optionssnapshot bleibt stabil.

## Phase 4: Three.js-Integration

### Schritt 4.1: Three.js lokal einbinden

Ziel:

- Three.js ist im Rails-/Importmap-Setup nutzbar.

Aufgaben:

- Entscheiden, ob Three.js per Importmap, vendored JS oder npm/esbuild eingebunden wird.
- Minimalen Three.js-Controller bauen.
- Canvas/Viewport mit Ladezustand rendern.

Ergebnis:

- Eine einfache Szene rendert lokal.

Abnahme:

- Canvas ist sichtbar.
- Kamera, Licht und Orbit-Steuerung funktionieren.
- Kein schweres SPA-Framework wurde eingefuehrt.

### Schritt 4.2: GLB-Modell laden

Ziel:

- Kegerator-Modell wird als echtes 3D-Modell geladen.

Aufgaben:

- GLTFLoader integrieren.
- Modell-URL aus Konfigurator-Daten lesen.
- Loading-/Error-State bauen.
- Kamera automatisch auf Modell ausrichten.

Ergebnis:

- Kegerator-GLB erscheint im Viewport.

Abnahme:

- Nutzer kann drehen und zoomen.
- Modell laedt ohne Seitenreload.
- Fehler bei fehlendem Asset wird verstaendlich angezeigt.

### Schritt 4.3: Modell-Bindings anwenden

Ziel:

- Optionen beeinflussen sichtbare 3D-Modellteile.

Aufgaben:

- Mesh-/Material-Bindings aus YAML an Three.js uebergeben.
- Farbe/Material aendern.
- Zapfhahn 1/2 anzeigen.
- Tablet sichtbar/unsichtbar schalten.
- Logo-Textur auf Brandingflaeche anwenden.

Ergebnis:

- Kegerator-Konfiguration veraendert das 3D-Modell sichtbar.

Abnahme:

- Farbwechsel funktioniert.
- 1/2 Zapfhaehne sind sichtbar korrekt.
- Tablet reagiert auf Auswahl und Regeln.
- Logo erscheint auf der definierten Flaeche.

### Schritt 4.4: Ape-Modell anschliessen

Ziel:

- Zweite Solution nutzt dieselbe Rendering-Engine.

Aufgaben:

- Ape-GLB einbinden.
- Ape-Bindings in YAML ergaenzen.
- Ape-spezifische Optionen an Modellteile binden.

Ergebnis:

- Ape wird ueber dieselbe Engine gerendert.

Abnahme:

- Wechsel Kegerator/Ape tauscht Modell und Optionen.
- Ape-Farbe, Branding, Tablet und relevante Module reagieren sichtbar.
- Keine Ape-spezifische Logik ist hart im Three.js-Code verdrahtet.

## Phase 5: Szenen und Fotorealismus

### Schritt 5.1: Szenenmodell und Auswahl bauen

Ziel:

- Nutzer kann zwischen festen Szenen wechseln.

Aufgaben:

- Szenen in YAML oder DB definieren.
- Studio, Vereinsheim, Outdoor-Event, Messe, Hochzeit erfassen.
- Szenenauswahl in UI bauen.
- Szenenparameter an Renderer uebergeben.

Ergebnis:

- Szene kann gewechselt werden.

Abnahme:

- Alle fuenf Szenen sind auswählbar.
- Szene wird in der gespeicherten Konfiguration persistiert.

### Schritt 5.2: Licht, Boden und Schatten umsetzen

Ziel:

- Das Objekt steht glaubwuerdig im Raum.

Aufgaben:

- Boden/Shadow-Catcher umsetzen.
- Schatten aktivieren.
- Licht-Presets pro Szene definieren.
- Kamera-Presets pro Szene definieren.
- HDRI/Environment-Maps testen, sofern vorhanden.

Ergebnis:

- Die Darstellung wirkt nicht wie ein freigestelltes Objekt vor einem Bild.

Abnahme:

- Objekt wirft sichtbaren Schatten.
- Objekt steht plausibel auf dem Boden.
- Szenenwechsel veraendert Kontext und Licht plausibel.
- Desktop und Mobile bleiben performant.

### Schritt 5.3: Fotorealismus-Review

Ziel:

- Qualitaetsluecken der 3D-Darstellung frueh erkennen.

Aufgaben:

- Screenshots von Kegerator und Ape in allen Szenen erstellen.
- Materialqualitaet pruefen.
- Licht, Schatten, Kamera und Massstab bewerten.
- Asset-Optimierungen dokumentieren.

Ergebnis:

- Liste konkreter Verbesserungen an Modellen, Texturen und Szenen.

Abnahme:

- Mindestens ein Kegerator-Screenshot wirkt fuer eine Kundenpraesentation ausreichend glaubwuerdig.
- Bekannte Darstellungsprobleme sind dokumentiert.

## Phase 6: Logo-Upload und Branding

### Schritt 6.1: Upload technisch absichern

Ziel:

- Logo-Uploads sind sicher und begrenzt.

Aufgaben:

- Erlaubte Dateitypen definieren.
- Dateigroessenlimit setzen.
- Content-Type pruefen.
- Entscheidung SVG ja/nein umsetzen.
- Upload an `ConfigurationSession` oder eigenes Attachment haengen.

Ergebnis:

- Kunde kann Logo hochladen.

Abnahme:

- Gueltiges PNG/WebP wird akzeptiert.
- Zu grosse oder falsche Dateien werden abgelehnt.
- Upload bleibt der Konfiguration zugeordnet.

### Schritt 6.2: Logo im 3D-Modell anzeigen

Ziel:

- Hochgeladenes Logo wird auf festen Flaechen sichtbar.

Aufgaben:

- Logo als Textur fuer Three.js bereitstellen.
- Brandingflaechen pro Solution definieren.
- Seitenverhaeltnis erhalten.
- Optional einfache Groessen-Presets anbieten.

Ergebnis:

- Kunde sieht sein Branding im Modell.

Abnahme:

- Logo erscheint beim Kegerator auf der definierten Flaeche.
- Logo erscheint bei der Ape auf der definierten Flaeche.
- Logo wird beim Speichern und erneuten Laden wieder angezeigt.

## Phase 7: Lead-Anfrage

### Schritt 7.1: Anfrageformular anbinden

Ziel:

- Aus einer Konfiguration entsteht eine Lead-Anfrage.

Aufgaben:

- Formularfelder definieren: Name, Firma optional, E-Mail, Telefon, Nachricht, Datenschutz.
- Absenden mit gespeicherter `ConfigurationSession` verbinden.
- Bestehenden Inquiry-Flow pruefen oder eigene `SolutionInquiry` bauen.

Ergebnis:

- Kundenanfrage wird gespeichert.

Abnahme:

- Kunde kann Anfrage absenden.
- Anfrage enthaelt Kontaktdaten und Konfigurationsreferenz.
- Validierungen greifen.

### Schritt 7.2: Admin-/Sales-Ansicht

Ziel:

- Zapfe kann eingegangene Konfigurationen ansehen.

Aufgaben:

- Admin-Liste fuer Solution-Konfigurationen/Anfragen bauen.
- Detailansicht mit Kundendaten, Optionen, Preisindikation, Logo und Szene bauen.
- Link zum erneuten Oeffnen der Konfiguration anzeigen.

Ergebnis:

- Sales kann Leads weiterbearbeiten.

Abnahme:

- Admin sieht neue Anfrage.
- Admin sieht strukturierte Optionen und Preis-Snapshot.
- Admin kann die Konfiguration erneut oeffnen.

## Phase 8: Vorschau und spaetere Angebote vorbereiten

### Schritt 8.1: Preview-Snapshot speichern

Ziel:

- Fuer spaetere Angebote existiert ein Vorschaubild.

Aufgaben:

- Clientseitig Canvas-Screenshot erzeugen.
- Screenshot beim Speichern oder Absenden mitsenden.
- Preview an Konfiguration haengen.

Ergebnis:

- Gespeicherte Konfiguration hat ein Vorschaubild.

Abnahme:

- Preview zeigt die konfigurierte Solution in der gewaehlten Szene.
- Preview ist in Admin/Sales sichtbar.

### Schritt 8.2: PDF-Datenstruktur vorbereiten

Ziel:

- Spaetere PDF-Angebote koennen ohne Datenmodell-Umbau gebaut werden.

Aufgaben:

- Preis-/Optionssnapshot final strukturieren.
- Angebotsnotizen/Interne Preisueberschreibung als spaeteres Feld vorbereiten.
- Noch kein finales PDF bauen.

Ergebnis:

- Datenbasis fuer Angebots-PDF ist vorhanden.

Abnahme:

- Snapshot enthaelt alle Daten fuer ein spaeteres PDF: Kunde, Solution, Optionen, Preis, Szene, Preview.

## Phase 9: Tests, Performance und lokaler Deploy

### Schritt 9.1: Backend-Tests

Ziel:

- Kritische Geschaeftslogik ist abgesichert.

Aufgaben:

- Tests fuer YAML-Loader.
- Tests fuer Preisberechnung.
- Tests fuer Regeln.
- Tests fuer Konfiguration speichern.
- Tests fuer Anfragepersistenz.

Ergebnis:

- Backend-Testabdeckung fuer MVP-Kern.

Abnahme:

- `bin/rails test` laeuft erfolgreich.

### Schritt 9.2: System-/E2E-Testpfad

Ziel:

- Der wichtigste Kundenpfad ist automatisiert oder mindestens klar dokumentiert.

Aufgaben:

- Playwright-Test fuer `/solutions/configurator` anlegen.
- Kegerator auswaehlen.
- Farbe/Optionen setzen.
- Preisindikation pruefen.
- Anfrage absenden.
- 3D-Canvas auf nicht-leeren Render pruefen, soweit praktikabel.

Ergebnis:

- Grundlegender Smoke-Test fuer den Konfigurator.

Abnahme:

- Playwright-Test laeuft lokal.
- Canvas ist nicht leer.
- Anfrage wird erfolgreich gespeichert.

### Schritt 9.3: Lokale Startdokumentation

Ziel:

- Der MVP kann lokal reproduzierbar gestartet werden.

Aufgaben:

- README-Abschnitt oder eigene Doku ergaenzen.
- Assets und YAML-Konfiguration beschreiben.
- Startbefehl dokumentieren.
- Bekannte Einschraenkungen dokumentieren.

Ergebnis:

- Lokaler Test ist nachvollziehbar.

Abnahme:

- Frische lokale Umgebung kann den Konfigurator starten.
- `/solutions/configurator` funktioniert mit Seed-/YAML-Daten.

## Empfohlene Reihenfolge fuer die erste Iteration

1. Asset-Konvention fuer Kegerator definieren.
2. Route und leere Konfigurator-Seite bauen.
3. YAML fuer Kegerator + Ape anlegen.
4. Preis- und Regelservices bauen.
5. UI ohne 3D fertigstellen.
6. Kegerator-GLB in Three.js laden.
7. Farbe, Zapfhaehne, Tablet und Logo beim Kegerator anbinden.
8. Szenen und Schatten fuer Kegerator umsetzen.
9. Konfiguration speichern und Lead absenden.
10. Ape an dieselbe Engine anschliessen.

## Erste lauffaehige Zwischenversion

Die erste sinnvolle Demo ist erreicht, wenn:

- `/solutions/configurator` lokal laeuft.
- Kegerator gewaehlt werden kann.
- 1/2 Zapfhaehne, Farbe, Tablet und Bezahlfunktion funktionieren.
- Preisindikation sichtbar ist.
- ein GLB-Modell angezeigt und gedreht werden kann.
- mindestens eine Studio-Szene mit Boden und Schatten existiert.
- eine Konfiguration gespeichert werden kann.

Diese Zwischenversion sollte vor der Ape-Integration stabilisiert werden.
