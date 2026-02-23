# UI-/Animations-Unterschiede zum Altprojekt

Stand: 2026-02-23

## Bewusst anders in der Rails-Version
- Framer-Motion wurde entfernt.
- Seitenübergänge sind derzeit ohne Crossfade/AnimatePresence.
- Scroll-basierte Reveal-Animationen sind derzeit nicht implementiert.
- Drinks-Filter/Cart sind aktuell clientseitig leichtgewichtig umgesetzt (kein React State-Management).

## Was bereits nah am Altprojekt umgesetzt ist
- Farbwelt (Navy/Amber/Cream) und grundlegende Seitenstruktur.
- Logo-/Bildwelt aus dem alten `public`-Ordner wurde übernommen.
- Kernseiten vorhanden: Start, Events, Drinks, Calculator, Contact, Impressum, Datenschutz.
- Admin-Bereich zur inhaltlichen Pflege (Produkte/Kategorien/Events).
- Mobile Navbar inkl. Fullscreen-Menü deutlich näher an der alten Website.
- Scroll-Reveal Animationen via Stimulus + CSS (ohne Framer Motion).

## Geplante Nachrüstungen (optional)
- CSS-only Fade-In für Sektionen beim Scrollen (IntersectionObserver + Utility-Klassen).
- Leichte Page-Transition via Turbo/Stimulus.
- Feineres Motion-Tuning für Hover, Card-Reveal und CTA-Interaktionen.
- Mobile Menü-Icons (Home/Rechner/Events/Drinks/Kontakt) analog Altprojekt.
