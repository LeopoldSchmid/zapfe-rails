# Produktionsreife-Remediation

## Objective

Alle 60 Findings aus `docs/architecture-review-2026-07-16.md` nachvollziehbar beheben, verifizieren und bis zu einer belastbaren erneuten Go/No-Go-Entscheidung weiterarbeiten.

## Original Request

„Kannst du mir alle deiner Findings korrigieren?“

## Intake Summary

- Input shape: `existing_plan`
- Audience: Betreiber und Entwicklungsteam von Zapfe!
- Authority: `requested`
- Proof type: `test`
- Completion proof: Jedes Finding besitzt einen belegten Abschlussstatus; alle lokalen technischen Gates sind grün, Restore-/Security-/Privacy-/Rechnungs-/Accessibility-Flows sind verifiziert und eine finale erneute Produktionsfreigabeprüfung ist bestanden.
- Goal oracle: Eine maschinenprüfbare 60-ID-Remediation-Matrix plus grüne risikobasierte Test-, Security-, Browser-, Restore- und Release-Gates und ein finaler Judge-/PM-Audit mit `full_outcome_complete: true`.
- Likely misfire: Viele kosmetische Änderungen durchführen, aber kritische Betriebs-, Security- oder Rechtsrisiken offenlassen; organisatorische oder rechtliche Pflichten ohne echte Betreiberfakten nur als erledigt markieren; rote vorhandene Gates ignorieren.
- Blind spots considered: Providerzugänge, reale Backupziele, Betreiber-/Umsatz-/Mitarbeiterdaten, Verträge/AVV/TIA, Steuer- und Rechtsentscheidungen sowie echte Produktionsinfrastruktur sind nicht vollständig im Repository verfügbar. Abhängigkeitsupdates und Datenmigrationen können Verhaltensänderungen auslösen. Backups, Löschung und Rechnungsarchivierung müssen zusammenpassen.
- Existing plan facts: Der Review priorisiert Welle 0 bis Welle 3; drei kritische Blocker sind SEC-001, OPS-001 und OPS-002. Das Ergebnisdokument sowie die T001–T999-Auditreceipts bleiben die Evidenzbasis. Korrekturen erfolgen auf `architecture-review`. Die temporäre Review-Quest ist kein Produktionsfeature und die Review-Route bleibt in Produktion deaktiviert.

## Goal Oracle

The oracle for this goal is:

`Alle 60 Finding-IDs sind in einer Remediation-Matrix exakt einmal auf fixed+verified, rejected-with-proof oder operator-completed abgebildet; kein kritisches/hohes Finding ist offen, alle relevanten Rails-/Browser-/Lint-/Security-/Restore-Gates sind grün und der finale erneute Go/No-Go-Review bestätigt Produktionsfreigabefähigkeit.`

Der PM muss nach jedem Umsetzungspaket Befunde, Diff und Verifikation gegen dieses Oracle abgleichen. Planung, einzelne grüne Tests oder ein nur dokumentierter externer Prozess genügen nicht.

## Goal Kind

`existing_plan`

## Current Tranche

Kontinuierliche vollständige Remediation: Zuerst die 60 Findings und ihre Abhängigkeiten validieren, dann die größten sicheren vertikalen Pakete in der Reihenfolge Welle 0 bis Welle 3 implementieren und verifizieren. Lokale Arbeit wird fortgesetzt, auch wenn einzelne Provider-, Betreiber- oder Rechtsentscheidungen blockiert sind. Wenn ausschließlich externe Fakten oder Freigaben fehlen, wird eine exakte Betreiber-Checkliste mit benötigten Antworten erstellt und nur der davon abhängige Slice blockiert.

## Non-Negotiable Constraints

- Keine Behauptung von Rechts-, Steuer-, DSGVO-, BFSG- oder GoBD-Konformität ohne prüfbare Grundlage und gegebenenfalls externe Freigabe.
- Keine destruktive Produktions-, Datenbank-, Volume- oder Backup-Aktion ohne ausdrückliche Zustimmung und getesteten Rollback.
- Keine echten Kundendaten, Zugangsdaten oder Secrets in Logs, Tests, Fixtures, Receipts oder Dokumentation aufnehmen.
- Vorhandene Benutzeränderungen erhalten; jede Migration und Abhängigkeitsänderung muss rückwärts- beziehungsweise rollbackfähig bewertet werden.
- `script/replace_prod_storage_from_staging` darf bis zu einem fail-safe Ersatz nicht ausgeführt werden.
- Security-, Datenschutz-, Rechnungs-, Lösch-, Backup- und Accessibility-Verbesserungen müssen durch risikobasierte Negativ-, Failure- oder Browsertests belegt werden.
- Die Review-Quest bleibt temporär, `noindex` und außerhalb von Production geroutet.
- Ein Finding gilt nicht durch Dokumentation allein als behoben, wenn Code, Infrastruktur oder Betreiberprozess erforderlich ist.

## Stop Rule

Stop only when a final audit proves the full original outcome is complete.

Do not stop after planning, discovery, or a single implementation wave while weitere sichere lokale Remediation möglich ist. Bei fehlenden Credentials, Produktionszugängen oder Betreiberentscheidungen nur den exakten Slice blockieren und alle unabhängigen Arbeiten fortsetzen.

Wenn am Ende ausschließlich menschliche Freigaben oder Betreiberfakten fehlen, diese als konkrete Fragen mit erforderlichem Nachweis bündeln, den Zustand wahrheitsgemäß blockieren und keine Scheinlösung erzeugen.

## Slice Sizing

Jedes Worker-Paket soll einen kohärenten Risikobereich vollständig behandeln, einschließlich Code, Migrationen, Dokumentation und Verifikation. Wiederholte kleine Änderungen desselben Musters gehören in ein Paket. Phasenreviews erfolgen nach kritischen Blockern, vor riskanten Daten-/Auth-/Rechnungsänderungen und beim finalen Audit.

## Board Health

```bash
node /home/leo/.codex/plugins/cache/goalbuddy/goalbuddy/0.4.0/skills/goal-prep/scripts/check-goal-state.mjs docs/goals/production-readiness-remediation/state.yaml
```

## Canonical Board

Machine truth lives at:

`docs/goals/production-readiness-remediation/state.yaml`

## Run Command

```text
/goal Follow docs/goals/production-readiness-remediation/goal.md.
```

## PM Loop

1. Charter, `state.yaml` und GoalBuddy-Ausführungsvertrag lesen.
2. Ausschließlich den aktiven Task bearbeiten und danach ein Receipt schreiben.
3. Remediation-Matrix und Oracle nach jedem Worker-Paket aktualisieren.
4. Das nächste größte sichere Paket aktivieren, solange lokale Arbeit möglich ist.
5. Nur an Risiko-, Phasen-, Ambiguitäts- oder Finalgrenzen Judge/PM-Review durchführen.
6. Erst abschließen, wenn alle 60 IDs und alle geforderten Belege im finalen Audit abgedeckt sind.
