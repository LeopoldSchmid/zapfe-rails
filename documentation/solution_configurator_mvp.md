# Solution Configurator MVP

## Ziel

Zapfe bekommt einen oeffentlich erreichbaren 3D-Konfigurator fuer kundenseitige Lead-Anfragen.
Der erste Einstiegspunkt ist:

`/solutions/configurator`

Der MVP soll keine voll generische SaaS-Plattform sein. Er soll aber so aufgebaut werden, dass spaeter weitere Solutions, Szenen, Regeln und Angebotsfunktionen ohne grundlegenden Umbau ergaenzt werden koennen.

## Leitprinzipien

- Die Domäne heisst `Solution`, nicht `Product`.
- Der Konfigurator ist Zapfe-nah, aber nicht hart auf Kegerator oder Ape verdrahtet.
- Rails bleibt das fuehrende System fuer Daten, Preise, Leads und gespeicherte Konfigurationen.
- Stimulus steuert die UI und kapselt die Three.js-Integration.
- Three.js rendert echte `.glb`/`.gltf`-Modelle im Browser.
- Fotorealismus ist ein Kernziel. Asset-Qualitaet, Licht, Schatten, Materialien und Szenen sind deshalb Teil des MVP, kein spaeteres Nice-to-have.
- Der bestehende Produkt-/Getraenkekatalog bleibt getrennt von der neuen Konfigurator-Domaene.

## MVP-Scope

### Start-Solutions

#### 1. Kegerator

Prioritaet: zuerst umsetzen.

Varianten:

- 1 Zapfhahn
- 2 Zapfhaehne

Konfigurierbare Optionen im MVP:

- Rahmen-/Gehaeusefarbe
- Logo auf festen Brandingflaechen
- Anzahl Zapfhaehne: 1 oder 2
- Tablet-Platzierung
- Bezahlfunktion ja/nein

Fachliche Regeln:

- Kegerator nutzt im MVP nur Passivkuehlung, also Kuehlschrank/Innenkuehlung.
- Bezahlfunktion erfordert Tablet.
- Ohne Bezahlfunktion sind Tablets optional.

#### 2. Ape

Variante:

- Ape 50 mit originalem Kofferaufbau

Konfigurierbare Optionen im MVP:

- Aussenfarbe
- Branding auf festen Brandingflaechen
- Anzahl Zapfanlagen
- Batterie/Strom
- Bezahlfunktion ja/nein
- Tablet ja/nein

Fachliche Regeln:

- Ape nutzt im MVP nur Durchlaufkuehler.
- Bezahlfunktion erfordert Tablet.
- Ohne Bezahlfunktion sind Tablets optional.

### Preise

- Alle Optionen koennen den Preis beeinflussen.
- Der MVP soll einen indikativen Preis bilden.
- Preise muessen fuer individuelle Angebote spaeter admin-/salesseitig ueberschreibbar sein.
- Vollstaendige Angebots-PDFs werden im MVP nur vorbereitet, nicht final umgesetzt.

### Lead-Ziel

Der MVP ist fuer Kunden erreichbar und erzeugt Lead-Anfragen.

Ein Kunde soll:

1. Kegerator oder Ape waehlen.
2. Eine Variante auswaehlen.
3. Farben, Branding, technische Optionen und Szene konfigurieren.
4. Sein Logo hochladen.
5. Das Ergebnis in 3D ansehen.
6. Einen indikativen Preis sehen.
7. Die Konfiguration mit Kontaktdaten als Anfrage absenden.

### Gespeicherte Konfigurationen

Konfigurationen muessen gespeichert werden koennen.

Gespeichert werden mindestens:

- Solution
- Solution-Variante
- gewaehlte Optionen
- Regel-/Preis-Snapshot
- Szene
- Logo-Upload
- Vorschaubild/Screenshot, sofern technisch im MVP sinnvoll
- Kundendaten der Anfrage
- oeffentlicher Share-/Resume-Key fuer Kunden
- Admin-/Sales-Zugriff auf die gespeicherte Konfiguration

## Nicht im MVP

- Eigene Hintergrundbilder von Kunden hochladen.
- Vollstaendiger No-Code-Regelbuilder im Admin.
- Vollstaendiger PDF-Angebotsprozess.
- CRM-Integration.
- Mehrmandanten-/White-Label-SaaS.
- AR/WebXR.
- Freie Logo-Transformation wie in professioneller Designsoftware.
- Serverseitiges 3D-Rendering.

## Vordenken fuer spaeter

### Hintergrundbild-Upload

Der Upload eigener Bilder wird nicht im MVP umgesetzt. Das Datenmodell soll aber so vorbereitet werden, dass spaeter eigene Szenen ergaenzt werden koennen.

Empfohlene Struktur:

- `Scene` fuer kuratierte Szenen
- spaeter optional `CustomSceneUpload`
- `LightingPreset`
- `CameraPreset`
- `ShadowPreset`

Im MVP werden nur feste Szenen verwendet.

### PDF-Angebote

PDF-Angebote werden im MVP nicht final konzipiert. Die gespeicherte Konfiguration soll aber alle Daten enthalten, die spaeter fuer ein PDF benoetigt werden:

- Kundendaten
- Solution und Variante
- gewaehlte Optionen
- Preisindikation
- Logo
- Szene
- Vorschaubild
- Zeitpunkt und Version des Preis-/Options-Snapshots

## Szenen

Der MVP enthaelt feste Szenen:

- Studio
- Vereinsheim
- Outdoor-Event
- Messe
- Hochzeit
- Geschäftsfeier

Anforderung:

- Das konfigurierte Objekt steht glaubwuerdig auf einem Boden.
- Es gibt realistische Schatten.
- Szene, Licht und Kamera sollen pro Szene definierbar sein.
- Die Szene soll nicht nur dekorativer Hintergrund sein, sondern helfen, Groesse, Wirkung und Branding besser einzuschaetzen.

## 3D-Anforderungen

### Modellformat

- Primaer `.glb`
- Optional `.gltf` mit externen Texturen, falls fuer die Asset-Pipeline noetig

### Three.js

Die Three.js-Schicht soll als eigener Stimulus-Controller oder als kleines Modul unterhalb eines Stimulus-Controllers aufgebaut werden.

Sie darf fachlich nicht wissen, was ein Kegerator oder eine Ape ist. Sie erhaelt nur strukturierte Daten:

- Modell-URL
- Mesh-/Material-Bindings
- sichtbare/unsichtbare Komponenten
- Materialwerte
- Logo-Zonen
- Kamera-/Licht-/Szenenparameter

### Fotorealismus

Der MVP muss auf hochwertige Echtzeitdarstellung ausgelegt sein:

- PBR-Materialien
- saubere Roughness-/Metalness-Werte
- Normal Maps, falls verfuegbar
- Ambient Occlusion, falls verfuegbar
- realistische Beleuchtung
- Schatten
- gute Default-Kamera
- responsive Darstellung auf Desktop und Mobile
- Ladezustand und Fallback bei WebGL-Problemen

### Veraenderbare Modellteile im MVP

Mindestens:

- Farbe/Material
- Logo auf festen Brandingflaechen
- Zapfhahn-Anzahl
- Tablet sichtbar/unsichtbar
- sichtbare technische Module, sofern im Modell vorhanden

## Logo-Upload

MVP-Verhalten:

- Kunde laedt Logo hoch.
- Erlaubte Formate: PNG und SVG, optional JPG/WebP falls sinnvoll.
- Logo wird automatisch auf definierte Brandingflaechen gesetzt.
- Freies Verschieben ist nicht erforderlich.
- Skalierung/Positionierung darf als einfache Preset-Auswahl umgesetzt werden, falls noetig.
- Upload wird serverseitig gespeichert.
- Die Konfiguration speichert, welches Logo auf welcher Brandingflaeche verwendet wurde.

Sicherheitsanforderung:

- SVG-Uploads muessen sanitisiert oder im MVP deaktiviert werden, falls keine sichere Sanitization vorhanden ist.
- Dateigroessenlimit definieren.
- Content-Type validieren.

## Datenmodell-Vorschlag

Die konkrete Rails-Implementierung kann angepasst werden, soll aber diese Konzepte abbilden.

### `Solution`

Repraesentiert Kegerator oder Ape.

Felder:

- `name`
- `slug`
- `description`
- `active`
- `position`

### `SolutionVariant`

Repraesentiert z. B. Kegerator 1 Hahn, Kegerator 2 Haehne oder Ape 50.

Felder:

- `solution_id`
- `name`
- `slug`
- `base_price_cents`
- `active`
- `position`

### `SolutionAsset`

3D-Modell pro Variante.

Felder:

- `solution_variant_id`
- `asset_type`
- `file` via Active Storage
- `metadata_json`

### `ConfigurationStep`

UI-Schritte pro Solution.

Felder:

- `solution_id`
- `name`
- `slug`
- `position`
- `required`

### `ConfigurationOption`

Waehltbare Option.

Felder:

- `configuration_step_id`
- `name`
- `slug`
- `price_delta_cents`
- `metadata_json`
- `active`
- `position`

### `ConfigurationRule`

Regeln im MVP koennen aus YAML geladen werden. Eine Datenbanktabelle ist optional.

Regeltypen:

- `requires`
- `excludes`
- `auto_selects`

MVP-Regeln:

- `payment_function` requires `tablet`
- `kegerator` allows only `passive_cooling`
- `ape` allows only `flow_cooler`

### `Scene`

Feste Szene/Hintergrund.

Felder:

- `name`
- `slug`
- `active`
- `position`
- `metadata_json`
- optional Active-Storage-Dateien fuer Background/HDRI/Texturen

### `ConfigurationSession`

Gespeicherte Kundenkonfiguration.

Felder:

- `solution_id`
- `solution_variant_id`
- `scene_id`
- `public_token`
- `selected_options_json`
- `price_snapshot_json`
- `visual_snapshot_json`
- `customer_snapshot_json`
- `status`
- `submitted_at`

### `SolutionInquiry`

Optional eigene Inquiry-Domaene fuer den Konfigurator. Alternativ kann `Inquiry` erweitert werden. Empfohlen ist eine eigene Tabelle oder eine klar strukturierte Erweiterung, damit der bestehende Anfragefluss nicht unuebersichtlich wird.

## YAML-Konfiguration

Fuer den MVP reicht YAML fuer Options-, Preis- und Regeldefinitionen.

Ziel:

- schnelle Iteration ohne Admin-UI
- Versionierung in Git
- klare Reviewbarkeit

Moegliche Datei:

`config/solution_configurator.yml`

Die YAML-Datei soll mindestens abbilden:

- Solutions
- Varianten
- Schritte
- Optionen
- Preis-Deltas
- Regeln
- Mesh-/Material-Bindings
- Branding-Zonen
- Szenen-Presets

## UI-Anforderungen

Route:

`GET /solutions/configurator`

Der erste Screen ist der Konfigurator, keine Landingpage.

Erwartete Bereiche:

- 3D-Viewport
- Solution-/Variantenwahl
- Schrittweise Optionen
- Logo-Upload
- Szenenwahl
- Preisindikation
- Anfrageformular

UX:

- Desktop und Mobile nutzbar.
- 3D-Viewport bleibt prominent.
- Optionen sind klar und scanbar.
- Unzulaessige Optionen werden deaktiviert und kurz begruendet.
- Bei automatischer Auswahl durch Regeln wird der Nutzer sichtbar informiert.
- Ladezustand fuer Modell und Texturen.
- Fallback-Hinweis, falls WebGL nicht verfuegbar ist.

## Lokale Entwicklungsumgebung

Der MVP muss lokal startbar sein.

Erwartung:

- `bin/dev` startet die App.
- `/solutions/configurator` ist lokal erreichbar.
- Seed-/YAML-Daten erzeugen mindestens Kegerator und Ape.
- Es gibt einen dokumentierten Weg, 3D-Testassets lokal einzubinden.
- Falls echte Modelle noch fehlen, gibt es Platzhalter-GLB-Dateien oder klare Fallbacks, ohne die UI zu blockieren.

## Abnahmekriterien

### Routing und Einstieg

- `/solutions/configurator` ist lokal erreichbar.
- Die Seite zeigt direkt den Konfigurator.
- Kegerator und Ape sind als Solutions auswählbar.
- Kegerator ist initial priorisiert oder als erstes auswählbar.

### Kegerator-Konfiguration

- Ein Kunde kann Kegerator auswaehlen.
- Ein Kunde kann zwischen 1 und 2 Zapfhaehnen waehlen.
- Rahmen-/Gehaeusefarbe kann geaendert werden.
- Ein Logo kann hochgeladen und auf einer festen Brandingflaeche angezeigt werden.
- Tablet kann optional aktiviert werden.
- Bezahlfunktion kann aktiviert werden.
- Bei aktivierter Bezahlfunktion wird Tablet automatisch erzwungen oder die Auswahl ohne Tablet verhindert.
- Kegerator bietet im MVP keine andere Kuehlung als Passivkuehlung an.

### Ape-Konfiguration

- Ein Kunde kann Ape 50 mit originalem Kofferaufbau auswaehlen.
- Aussenfarbe kann geaendert werden.
- Ein Logo kann hochgeladen und auf einer festen Brandingflaeche angezeigt werden.
- Anzahl/Option der Zapfanlage kann konfiguriert werden.
- Batterie/Strom kann konfiguriert werden.
- Bezahlfunktion kann aktiviert/deaktiviert werden.
- Bei aktivierter Bezahlfunktion wird Tablet automatisch erzwungen oder die Auswahl ohne Tablet verhindert.
- Ape bietet im MVP keine andere Kuehlung als Durchlaufkuehler an.

### 3D-Darstellung

- Das Modell wird als echtes 3D-Modell im Browser gerendert.
- Der Nutzer kann drehen und zoomen.
- Farbwechsel sind ohne Seitenreload sichtbar.
- Sichtbare Komponenten wie Zapfhaehne oder Tablet reagieren auf Optionen.
- Das Logo erscheint auf der definierten Brandingflaeche.
- Das Objekt steht in der gewaehlten Szene auf einem Boden und wirft einen Schatten.
- Die Darstellung funktioniert auf Desktop und Mobile.
- Es gibt einen Ladezustand.
- Es gibt einen WebGL-Fallback.

### Szenen

- Studio, Vereinsheim, Outdoor-Event, Messe und Hochzeit sind auswählbar.
- Szenenwechsel aktualisiert Hintergrund/Licht/Kamera oder mindestens den visuellen Kontext.
- Das konfigurierte Objekt bleibt in jeder Szene plausibel platziert.

### Preisindikation

- Jede relevante Option beeinflusst den Preis-Snapshot.
- Der Nutzer sieht eine Preisindikation.
- Der gespeicherte Snapshot enthaelt Basispreis, Optionspreise und Gesamtindikation.
- Preislogik ist reproduzierbar aus YAML/Seed-Daten.

### Lead-Anfrage

- Kunde kann Kontaktdaten eingeben und Anfrage absenden.
- Anfrage speichert die Konfiguration strukturiert.
- Logo und gewaehlte Optionen bleiben der Anfrage zugeordnet.
- Admin/Sales kann die gespeicherte Konfiguration wiederfinden.
- Kunde kann die Konfiguration ueber einen oeffentlichen Token/Link erneut oeffnen, sofern fuer MVP umgesetzt.

### Admin/Sales

- Admin/Sales kann gespeicherte Konfigurationen einsehen.
- Preise fuer individuelle Angebote koennen spaeter ueberschrieben werden; im MVP muss die Datenstruktur das vorbereiten.
- Regeln muessen nicht im Admin gepflegt werden.
- YAML reicht fuer MVP-Konfiguration.

### Technische Qualitaet

- Konfigurator-Code ist vom bestehenden Produktkatalog getrennt.
- Three.js-Code ist gekapselt und nicht in grosse Inline-Skripte eingebettet.
- Fachliche IDs, Mesh-Namen und Material-Bindings kommen aus Daten/YAML, nicht aus hart codierten Ape-/Kegerator-Zweigen.
- Neue Modelle/Szenen/Optionen koennen durch Datenanpassung ergaenzt werden, solange die benoetigten Mesh-Bindings vorhanden sind.
- Automatisierte Tests decken mindestens Preis-/Regellogik und Anfragepersistenz ab.
- Ein manueller Testpfad fuer die 3D-Darstellung ist dokumentiert.

## Offene Punkte

- Exakte Preisstruktur je Option.
- Exakte erlaubte Zapfanlagen-Optionen bei der Ape.
- Weitere fachliche `requires`-/`excludes`-Regeln.
- Finale 3D-Modelle und Mesh-Namenskonvention.
- Entscheidung, ob SVG-Logo-Uploads im MVP sicher unterstuetzt oder zuerst deaktiviert werden.
- Spaetere PDF-Konzeption.
