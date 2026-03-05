# UI- und Inhaltsreview der neuen Seiten (2026-02-27)

## Kurzfazit

Die neuen Seiten sind technisch funktionsfaehig, aber inhaltlich und gestalterisch noch nicht auf Produktionsniveau. Das groesste Problem ist nicht "zu wenig Design", sondern fehlende Informationsarchitektur: mehrere Seiten sind in sich korrekt gebaut, wirken aber austauschbar, wiederholen dieselben Aussagen und fuehren Nutzer nicht klar zur naechsten passenden Entscheidung.

## Hauptprobleme

### 1. Neue Landingpages sind stark templatisiert und dadurch austauschbar

Dateien:

- [app/views/pages/solutions.html.erb](/home/leo/dev/projects/zapfe-rails/app/views/pages/solutions.html.erb)
- [app/views/pages/zapfanlage_freiburg.html.erb](/home/leo/dev/projects/zapfe-rails/app/views/pages/zapfanlage_freiburg.html.erb)
- [app/views/pages/firmenveranstaltungen.html.erb](/home/leo/dev/projects/zapfe-rails/app/views/pages/firmenveranstaltungen.html.erb)
- [app/views/pages/hochzeiten.html.erb](/home/leo/dev/projects/zapfe-rails/app/views/pages/hochzeiten.html.erb)

- Fast alle neuen Seiten folgen demselben Muster: dunkler Hero, 2-3 Kartenraster, generische CTA-Kachel.
- Dadurch entstehen kaum echte inhaltliche Unterschiede zwischen B2B, Hochzeit, Freiburg und Solutions.
- Aus Nutzersicht fuehlt sich das wie SEO-Landingpage-Varianten an, nicht wie sauber differenzierte Angebote.

Konsequenz:

- Wenig inhaltliche Schaerfe.
- Schwaches Vertrauen, weil kaum konkrete Belege, Beispiele, Preise, Referenzen oder visuelle Unterschiede vorkommen.

### 2. Die Nutzerfuehrung zu den neuen Unterseiten ist schwach

Dateien:

- [app/views/shared/_navbar.html.erb](/home/leo/dev/projects/zapfe-rails/app/views/shared/_navbar.html.erb)
- [app/views/pages/home.html.erb](/home/leo/dev/projects/zapfe-rails/app/views/pages/home.html.erb)

- Die Navigation verlinkt nur auf `Solutions`, aber nicht auf die neuen Spezialisierungsseiten ([app/views/shared/_navbar.html.erb](/home/leo/dev/projects/zapfe-rails/app/views/shared/_navbar.html.erb#L9)).
- Auf der Startseite gibt es im Abschnitt "Perfekt fuer jeden Anlass" visuell starke Kacheln, aber sie sind keine Links ([app/views/pages/home.html.erb](/home/leo/dev/projects/zapfe-rails/app/views/pages/home.html.erb#L126)).
- Damit bleiben die neuen Seiten fuer echte Nutzer fast unsichtbar und leben praktisch nur ueber direkte Links/Sitemap.

Empfehlung:

- Home-Kacheln klickbar machen.
- Unterseiten gezielt in Navigations- oder Zwischenstufen verlinken.
- `Solutions` als Hub-Seite nutzen, die sauber in konkrete Anwendungsfaelle verzweigt.

### 3. Firmenveranstaltungen startet ohne Primary CTA im Hero

Datei: [app/views/pages/firmenveranstaltungen.html.erb](/home/leo/dev/projects/zapfe-rails/app/views/pages/firmenveranstaltungen.html.erb)

- Im Hero fehlen direkte Handlungsoptionen; es gibt nur Copy und ein kleines "Kurz gesagt"-Aside ([app/views/pages/firmenveranstaltungen.html.erb](/home/leo/dev/projects/zapfe-rails/app/views/pages/firmenveranstaltungen.html.erb#L4)).
- Andere Landingpages haben im Hero sofort Buttons, diese Seite nicht.

Konsequenz:

- Inkonsistente Conversion-Fuehrung.
- Gerade auf Mobilgeraeten ist der erste sichtbare Block inhaltlich korrekt, aber nicht handlungsorientiert.

### 4. Tonalitaet ist inkonsistent (Du/Sie gemischt)

Dateien:

- [app/views/pages/contact.html.erb](/home/leo/dev/projects/zapfe-rails/app/views/pages/contact.html.erb)
- [app/views/pages/home.html.erb](/home/leo/dev/projects/zapfe-rails/app/views/pages/home.html.erb)
- [app/views/pages/hochzeiten.html.erb](/home/leo/dev/projects/zapfe-rails/app/views/pages/hochzeiten.html.erb)

- Startseite und Landingpages sprechen meist per `du` an.
- Die Kontaktseite verwendet konsequent `Sie` ("Kontaktieren Sie uns", "Wie Sie uns buchen koennen") ([app/views/pages/contact.html.erb](/home/leo/dev/projects/zapfe-rails/app/views/pages/contact.html.erb#L4), [app/views/pages/contact.html.erb](/home/leo/dev/projects/zapfe-rails/app/views/pages/contact.html.erb#L41)).

Konsequenz:

- Markenstimme wirkt nicht bewusst gefuehrt.
- Das liest sich wie zusammenkopierte Textbausteine statt wie ein konsistenter Auftritt.

Empfehlung:

- Eine Ansprache definieren und durchziehen.
- Fuer dieses Produkt wirkt `du` aktuell stimmiger, weil es schon auf den Kernseiten dominiert.

### 5. Inhaltlich fehlen belastbare Vertrauenselemente

Dateien:

- [app/views/pages/solutions.html.erb](/home/leo/dev/projects/zapfe-rails/app/views/pages/solutions.html.erb)
- [app/views/pages/zapfanlage_freiburg.html.erb](/home/leo/dev/projects/zapfe-rails/app/views/pages/zapfanlage_freiburg.html.erb)
- [app/views/pages/firmenveranstaltungen.html.erb](/home/leo/dev/projects/zapfe-rails/app/views/pages/firmenveranstaltungen.html.erb)
- [app/views/pages/hochzeiten.html.erb](/home/leo/dev/projects/zapfe-rails/app/views/pages/hochzeiten.html.erb)

- Kaum echte Referenzen, keine Zahlen, keine Kundenbeispiele, keine Fotos der konkreten Einsatzform pro Zielseite.
- Viele Aussagen bleiben abstrakt: "planbarer Ablauf", "weniger Reibung", "klarer Flow", "stilvoll", "sauberer Ausschank".

Konsequenz:

- SEO-Text ist vorhanden, aber Conversion-Qualitaet bleibt begrenzt.
- Die Seiten erklaeren Behauptungen, belegen sie aber nicht.

Empfehlung:

- Pro Landingpage mindestens ein konkretes Beispiel integrieren.
- Kurze Referenz- oder Use-Case-Boxen statt weiterer generischer Karten.
- Bilder pro Zielsegment differenzieren, nicht nur Layout variieren.

### 6. `Solutions` wirkt begrifflich breiter als der aktuelle Inhalt

Datei: [app/views/pages/solutions.html.erb](/home/leo/dev/projects/zapfe-rails/app/views/pages/solutions.html.erb)

- Die Seite positioniert "Self-Service Loesungen fuer Ausschank, Verkauf und digitale Ausgabe" sehr breit ([app/views/pages/solutions.html.erb](/home/leo/dev/projects/zapfe-rails/app/views/pages/solutions.html.erb#L6)).
- Der konkrete Inhalt bleibt aber im Kern bei Boltbar + lokaler Integration und wirkt eher wie ein Partner-Intro als wie ein echtes Produktportfolio.

Konsequenz:

- Erwartung und Substanz passen noch nicht zusammen.
- Nutzer koennen nach dem Hero nicht klar erkennen, was tatsaechlich kaufbar ist.

Empfehlung:

- Entweder enger positionieren ("Boltbar-gestuetzte Self-Service-Setups in der Region") oder die Leistungsbausteine viel konkreter machen.

## Design-Einschaetzung

### Was funktioniert

- Farbwelt und Grundkomponenten sind konsistent.
- Die neuen Utility-Klassen in [app/assets/tailwind/application.css](/home/leo/dev/projects/zapfe-rails/app/assets/tailwind/application.css) sorgen fuer visuelle Einheit.
- Die Seiten brechen mobil voraussichtlich nicht auseinander; das Layout ist robust und relativ sauber.

### Was nicht gut funktioniert

- Zu viele Bereiche bestehen aus gleichen "Card Soft"-Rastermustern; dadurch wirkt alles gleich wichtig.
- Es fehlt visuelle Hierarchie zwischen Beweis, Erklaerung, Conversion und Nebenaspekten.
- Das Design ist ordentlich, aber nicht besonders ueberzeugend, weil die Seiten eher "Layout gefuellt" als "gezielt komponiert" wirken.

## Priorisierte Maßnahmen

### P1

- Home-Kacheln im Anlass-Bereich klickbar machen und auf die jeweiligen Landingpages verlinken.
- Firmenveranstaltungen-Hero um klare CTA-Buttons erweitern.
- Ansprache (du/Sie) vereinheitlichen.

### P2

- `Solutions` als echte Hub-Seite aufbauen: konkrete Unterangebote, klare Abgrenzung, interne Links.
- Jede Landingpage um mindestens ein konkretes Proof-Element erweitern (Beispiel-Setup, Referenz, Kennzahl, Foto, Kurzfall).

### P3

- Wiederholte Card-Abschnitte reduzieren.
- Mehr visuelle Differenzierung pro Zielseite einbauen (eigene Hero-Motive, andere Section-Reihenfolge, segment-spezifische Inhalte).

## Empfohlene Zielstruktur pro Landingpage

- Hero mit eindeutiger Zielgruppe, Nutzenversprechen und 1-2 CTAs.
- Konkreter Einsatzfall statt abstrakter Benefits.
- Beweisblock (Referenz, Zahl, Ablaufbeispiel oder echte Veranstaltung).
- Nur danach allgemeine Vorteile und CTA.

So werden die Seiten nicht nur "vorhanden", sondern auch unterscheidbar und glaubwuerdig.
