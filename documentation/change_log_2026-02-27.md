# Change Log (2026-02-27)

## Architektur

- Frontend-Logik von einer monolithischen `application.js` in Stimulus-Controller und gemeinsame JS-Module aufgeteilt.
- Cart-Rendering auf sichere DOM-Erzeugung umgestellt; das bisherige `innerHTML`-Risiko ist entfernt.
- `Inquiry` um strukturierte Felder für Preisrechner-Daten erweitert (Mietmodus, Zeitraum, Uhrzeit, Lieferadresse, Optionen).
- SEO-Metadaten aus `ApplicationHelper` in `PageMetaCatalog` ausgelagert.
- Katalog- und Event-Listings stärker in Model-Scopes verschoben.

## Öffentliche Seiten

- Neue Landingpages miteinander vernetzt und stärker differenziert.
- Home-Kacheln verlinken jetzt in echte Unterseiten.
- `Solutions` ist jetzt ein Hub statt nur eine generische Textseite.
- `contact`, `events`, `drinks`, `calculator`, `impressum`, `datenschutz` an die neue Struktur angepasst.
- Tonalität auf den öffentlichen Seiten auf eine konsistentere `du`-Ansprache ausgerichtet.

## Admin

- Admin-Layouts visuell vereinheitlicht.
- Dashboard, Listen- und Formularseiten haben jetzt konsistente Toolbar-/Panel-Struktur.
- Primäre Admin-Aktionen nutzen gemeinsame Styling-Bausteine statt verstreuter Einzellösungen.

## Entwicklung

- Das Development-Asset-Manifest unter `public/assets/.manifest.json` wurde entfernt, damit lokale Asset-Änderungen wieder direkt sichtbar sind.
- Teststand nach den Änderungen: `bin/rails test` läuft grün.
