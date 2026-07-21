# Zapfe! Website-Relaunch vollständig umsetzen

## Objective

Die öffentliche Zapfe!-Website auf Basis der verbindlichen Strategie vom
21.07.2026 grundlegend neu strukturieren, gestalten, texten und technisch
umsetzen. Der fertige lokale Branch soll feste Standorte strategisch
priorisieren, Veranstaltungen weiterhin überzeugend verkaufen, das gemeinsame
Zapfe!-System verständlich erklären und alle relevanten Anfrage-, Getränke- und
Preisorientierungswege technisch produktionsreif integrieren. Noch fehlende,
extern freizugebende Bildinhalte dürfen als bewusst gestaltete Platzhalter
stehen bleiben, wenn für jeden Platzhalter ein konkretes Bildbriefing vorliegt.

## Original Request

Ein Goal formulieren und anschließend vollständig umsetzen, das alles zur
langfristig tragfähigen Neukonzeption der Zapfe!-Website Besprochene realisiert.

## Intake Summary

- Input shape: `existing_plan`
- Audience: Betreiber regelmäßiger Ausschankorte sowie Veranstalter im Raum
  Freiburg und darüber hinaus auf Anfrage
- Authority: `requested`
- Proof type: `test`, `demo`, `artifact`, `review`
- Completion proof: Alle in `documentation/website_strategy_2026-07-21.md`
  vorgesehenen öffentlichen Seiten und Flows funktionieren lokal in
  responsiver, barrierearmer und produktionsreifer Form; automatisierte Rails-,
  Browser-, Security- und Asset-Gates sind grün; ein abschließender
  Anforderungs- und Browseraudit weist jede Strategieanforderung nach.
- Goal oracle: Eine wiederholbare Browser-Walkthrough-Matrix für Mobile,
  Tablet und Desktop plus grüne relevante Test-, Accessibility-, Security- und
  Asset-Gates sowie eine nachvollziehbare Platzhalter- und Bildbriefing-Liste.
- Likely misfire: Eine optisch neue Landingpage liefern, ohne die gesamte
  Informationsarchitektur, realen Leistungsgrenzen, Preisangaben, Formulare,
  Weiterleitungen, Getränkeintegration, Accessibility und Vertrauenslogik
  vollständig umzusetzen.
- Blind spots considered: fehlende Referenzfreigaben, noch fehlende
  Kegerator-/Teamfotos, ungeklärte Boltbar-/Merchant-of-Record-Verträge,
  Revenue-Share ohne veröffentlichte Prozentzahl, bestehende URLs und SEO-Wert,
  Kopplung der Getränkedaten an das Backoffice, mobile Formulare, Ladezeit,
  Datenschutz und vorhandene uncommittete Änderungen.
- Existing plan facts:
  - `documentation/website_strategy_2026-07-21.md` ist die verbindliche
    Produkt- und Seitenstrategie.
  - `documentation/voice_and_tone.md`,
    `documentation/frontend_content_guide_2026-02-27.md` und
    `documentation/design_language_2026-03-17.md` bleiben verbindlich.
  - Feste Standorte sind der strategische Schwerpunkt; Veranstaltungen bleiben
    sekundär, aber wirtschaftlich und visuell wichtig.
  - Kegerator, Ape und individuelle Einbauten sind Formfaktoren desselben
    Systems und keine getrennten Produktwelten.
  - Gastgeber-Modus und Bezahl-Modus werden situationsbezogen erklärt.
  - Für Standortprojekte sind Pilot, Miete und Kauf möglich; Konditionen bleiben
    individuell.
  - Betreiber führen den täglichen Betrieb, Fasswechsel und Reinigung selbst;
    Zapfe! plant, installiert, weist ein und bietet vereinbarten Remote-Support.
  - Veranstaltungsmiete: 300 EUR inklusive gesetzlicher Mehrwertsteuer für
    Freiburg und Umgebung, einschließlich Lieferung, Aufbau, Einweisung, Abbau
    und Reinigung; weitere Entfernung und Extras auf Anfrage.
  - Bei Bezahlfunktion wird ein Revenue-Share genannt, aber keine Prozentzahl.
  - Getränkepreise müssen eindeutig inklusive Mehrwertsteuer ausgewiesen sein.
  - Getränkesuche und gemeinsame Produktdatenbasis bleiben erhalten.
  - Referenzen dürfen ohne dokumentierte Freigabe nur anonymisiert und
    wahrheitsgemäß erscheinen.
  - Logo, Navy, Creme, Amber und dezentes Bubble-Motiv bleiben; Typografie,
    Komposition, Navigation, Interaktion und Bildführung dürfen grundlegend
    verbessert werden.
  - Kein Live-Board; die dateibasierte GoalBuddy-Steuerung genügt.

## Goal Oracle

The oracle for this goal is:

`Ein finaler lokaler Browser-Walkthrough bestätigt auf 390 px, 768 px und 1440 px alle kanonischen Seiten, Navigationen, Formulare und Kerninteraktionen in Chromium und mit einem WebKit-Kernflow ohne Layoutbruch oder Konsolenfehler; automatisierte Prüfungen enthalten keine kritischen oder schwerwiegenden Accessibility-Befunde, der Tastatur-Walkthrough ist vollständig, jeder verbleibende Bildplatzhalter besitzt ein konkretes Bildbriefing und Strategie-Mapping, Rails-Tests, System-/Playwright-Tests, RuboCop, Brakeman sowie Asset-Precompile sind grün.`

The PM must keep comparing task receipts to this oracle. Planning, discovery, a
passing tiny slice, or a clean-looking board is not enough. The goal finishes
only when a final Judge/PM audit maps receipts and verification back to this
oracle and records `full_outcome_complete: true`.

## Goal Kind

`existing_plan`

## Current Tranche

Kontinuierliche vollständige Umsetzung des öffentlichen Website-Relaunches auf
dem bestehenden Branch: zunächst Strategie und Bestand gegeneinander
validieren, dann die größten sicheren vertikalen Seiten- und Flow-Pakete
implementieren, nach jedem Paket gezielt verifizieren und ohne künstlichen Halt
bis zum vollständigen lokalen Abnahmenachweis fortfahren.

## Non-Negotiable Constraints

- Vor Website-Arbeit `AGENTS.md` und die dort genannten aktiven Dokumente
  vollständig lesen; `documentation/archive/` ist keine aktuelle Vorgabe.
- Für Gestaltung und Frontend-Umsetzung den installierten
  `frontend-design`-Skill befolgen.
- Bestehende Nutzeränderungen und nicht zum Relaunch gehörende Dirty-Worktree-
  Änderungen bewahren.
- Rails 8, serverseitige ERB-Views, Hotwire/Stimulus und vorhandene
  Rails-Konventionen beibehalten; keine unnötige SPA oder neue externe
  Laufzeitabhängigkeit einführen.
- Öffentliche Website und erforderliche öffentliche Inquiry-Flows sind Scope.
  Das interne Backoffice wird nur angepasst, wenn gemeinsame Produktdaten oder
  neue Inquiry-Felder dies zwingend erfordern.
- Getränkesuche, Produktdaten und Backoffice-Nutzung dürfen nicht regressieren.
- Keine erfundenen Kundenstimmen, Kennzahlen, Verfügbarkeitsgarantien,
  Referenzen oder Leistungsversprechen.
- Keine Namen, Logos, identifizierbaren Gästefotos oder Zitate ohne
  dokumentierte Freigabe veröffentlichen.
- Bewusst gestaltete Bildplatzhalter sind im lokalen Endstand zulässig. Jeder
  Platzhalter benötigt spätestens im Abschluss-Receipt ein konkretes Briefing
  mit Motiv, Aussage, Bildaufbau, gewünschtem Format/Seitenverhältnis,
  relevantem Zuschnitt, benötigter Freigabe und vorgesehenem Dateipfad.
- Keine generischen Stockbilder oder erfundenen fotorealistischen Belege als
  Ersatz für reale Einsätze, Team- oder Produktfotos verwenden.
- Boltbar, Stripe, Merchant of Record und Zahlungsflüsse nicht spekulativ in
  Marketingtexten erklären. Vertrags- und Checkoutklarheit bleibt ein
  separates Freigabegate.
- Keine öffentliche Revenue-Share-Prozentzahl nennen.
- Alle öffentlichen B2C-Preise eindeutig inklusive gesetzlicher
  Mehrwertsteuer ausweisen.
- Bestehende Datenschutz-, Security-, Spam-Schutz-, CSP- und
  Anfragevalidierungsmaßnahmen erhalten.
- Bestehende indexierte URLs nur mit geeigneten permanenten Weiterleitungen
  ersetzen; Canonicals, Metadaten, strukturierte Daten und Sitemap gemeinsam
  aktualisieren.
- Responsive Design, Tastaturbedienung, sichtbare Fokuszustände, ausreichende
  Kontraste, semantische Struktur und `prefers-reduced-motion` sind Teil der
  Definition of Done.
- Das Goal autorisiert kein Produktionsdeployment, keine externen Nachrichten,
  keine Verträge und keine Veröffentlichung nicht freigegebener Inhalte.
- Keine Subagents starten, solange der Nutzer dies nicht ausdrücklich
  autorisiert; der PM führt die role-shaped Tasks selbst aus.

## Stop Rule

Stop only when a final audit proves the full original outcome is complete.

Do not stop after planning, discovery, or selection if safe local implementation
work remains. Do not stop after one page or one passing test. If eine konkrete
Referenzfreigabe oder ein finales Foto fehlt, implementiere die sichere
anonymisierte beziehungsweise austauschbare Struktur, gestalte einen bewussten
Platzhalter, dokumentiere das genaue Bildbriefing und setze die übrige lokale
Arbeit fort.

Only an exact approval, unavailable external asset, legally unsafe claim or
destructive/external action may remain blocked. Record the exact gate and keep
advancing every independent local slice.

## Slice Sizing

Safe means bounded, explicit, verified, and reversible. It does not mean tiny.
Each implementation task should deliver a coherent usable milestone such as the
complete shared public shell, the complete Standort journey, or the complete
Event journey including tests.

## Board Health

Machine truth lives at `docs/goals/website-relaunch/state.yaml`. If needed, run:

```bash
node /home/leo/.codex/plugins/cache/goalbuddy/goalbuddy/0.4.1/skills/goal-prep/scripts/check-goal-state.mjs docs/goals/website-relaunch/state.yaml
```

## Canonical Board

`docs/goals/website-relaunch/state.yaml`

## Run Command

```text
/goal Follow docs/goals/website-relaunch/goal.md.
```

## PM Loop

On every `/goal` continuation:

1. Read this charter and the GoalBuddy execution contract.
2. Confirm that the active goal path is `docs/goals/website-relaunch/goal.md`
   and do not accidentally continue the older blocked production-readiness goal.
3. Read `state.yaml` and work only on its active task.
4. Preserve the existing strategy and validate it against repository reality.
5. Write a compact receipt and update the board after each task.
6. Continue immediately to the next largest safe useful package.
7. Re-run the oracle after each implementation phase and at final audit.
8. Finish only when the final audit records `full_outcome_complete: true`.
