# T001 – Validierte 60-ID-Remediation-Matrix

## Judge-Entscheidung

`approved`, `full_outcome_complete: false`

Der Plan ist weiterhin sachlich gültig. Zwischen Audit-Commit `6941271` und
aktuellem Commit `3a55db9` wurden ausschließlich Review-Dokumentation und die
nicht-produktive Review-Quest ergänzt. Es gibt keine Produktänderung, die eines
der 60 Findings erledigt. Alle Findings bleiben daher offen; bedingte
Rechtsfindings bleiben offen-bedingt, bis reale Betreiberfakten vorliegen.

Der aktuelle Bundler-Audit gegen `ruby-advisory-db` vom 15.07.2026 bestätigt
SEC-001 und erweitert die konkrete Patchliste unter anderem um Rails 8.1.2.1,
Trix 2.1.18, Rack 3.2.6, rack-session 2.1.2, Puma 7.2.1, Nokogiri 1.19.4,
Loofah 2.25.1, sqlite3 2.9.5, websocket-driver 0.8.2, Addressable 2.9.0,
JSON 2.19.9 und weitere transitive Abhängigkeiten. Der Scan ist materiell rot.

## Matrix

Statuslegende: `open` = lokal bestätigt; `open/external` = technische Vorarbeit
möglich, endgültiger Abschluss benötigt Betreiber-, Provider-, Rechts- oder
Steuerevidenz.

| ID | Status | Primärpaket | Aktueller Beleg / Abschlussnachweis |
|---|---|---|---|
| SEC-001 | open | T002 | `Gemfile.lock` und aktueller Bundler-Audit rot; Audit plus gesamte Suite grün |
| SEC-002 | open | T003 | keine Adminrollen/Policies; negative Berechtigungsmatrix grün |
| SEC-003 | open | T003 | Ein-Zeichen-Passwort/keine MFA; Passwort-, MFA- und Recovery-Tests grün |
| SEC-004 | open | T003 | kein Session-Widerruf/keine sichere Rotation; alte Session nach Änderung abgelehnt |
| SEC-005 | open | T003 | Reset ohne Account-/IP-Cooldown; Burst-/Cooldown-Test grün |
| SEC-006 | open | T004 | uneinheitliche Attachmentregeln; zentrale Magic-Byte-/Größen-/Typ-Negativtests |
| SEC-007 | open | T003 | Monitoringtoken in Query; nur Headerauth und Log-Redaction nachgewiesen |
| SEC-008 | open | T003 | breite CSP; konkrete Origins/Nonce und Browser-Smoke grün |
| SEC-009 | open | T004 | direkte PII im Spamlog; Log-Test ohne E-Mail/volle IP/UA |
| SEC-010 | open | T003 | keine Security-Auditspur; Actor-/Request-/Alarm-Walkthrough |
| SEC-011 | open | T003 | Hosts/Permissions-Policy fehlen; Host- und Header-Negativtest |
| SEC-012 | open | T008 | globaler Worker-Scope; `/admin/`-Scope im Browser belegt |
| PRIV-001 | open/external | T004 | Art.-13-Text unvollständig; Datenflussinventar plus Betreiber-/Rechtsfreigabe |
| PRIV-002 | open/external | T004 | kein Retention-/Löschsystem; synthetischer Lifecycle-Test plus Fristfreigabe |
| PRIV-003 | open | T004 | dauerhafte PII in LocalStorage; Browserspeicher nach Submit/TTL leer |
| PRIV-004 | open | T004 | falsche Consent-Semantik; versionierte Kenntnisnahme/Consent-Tests |
| PRIV-005 | open/external | T004 | AVV/TIA/Transfers ungeklärt; Providerregister und echte Vertragsnachweise |
| PRIV-006 | open/external | T004 | Betroffenenrechteprozess fehlt; Export-/Berichtigung-/Lösch-Walkthrough |
| PRIV-007 | open/external | T004 | VVT/TOM/Breach/DPIA fehlen; freigegebene Artefakte und Incident-Probe |
| PRIV-008 | open/external | T004 | Umami-Livekonfiguration ungeprüft; Live-Netzwerk-/Retention-/Basisbeleg |
| PRIV-009 | open | T004 | PII in Pushpayload; generische Payload und Offboarding-Test |
| PRIV-010 | open | T004 | Pflichttelefon/Company/Freitext nicht minimiert; Form-/Log-Negativtests |
| LEG-001 | open/external | T009 | Impressum veraltet/Tatsachen offen; amtlicher Faktenabgleich und Freigabe |
| LEG-002 | open/external | T009 | VSBG-Status offen; Beschäftigten-/Teilnahmeentscheid und korrekter Hinweis |
| LEG-003 | open/external | T009 | BFSG-Scope offen; Beschäftigte/Umsatz/Bilanz/Vertragsschluss plus Rechtscheck |
| LEG-004 | open | T005 | Mischsteuersätze im PDF falsch; 7%+19%-Golden-/Texttest |
| LEG-005 | open/external | T005 | Nummern/Korrektur/Atomizität fragil; Concurrency-/Failure-Test plus Steuerfreigabe |
| LEG-006 | open/external | T005 | keine E-Rechnung; Schema-valides freigegebenes Format plus Betreiberstatus |
| LEG-007 | open/external | T009 | Fernabsatz-/Verbraucherpfad offen; reale Customer Journey plus Rechtsfreigabe |
| LEG-008 | open/external | T009 | PAngV-Einordnung offen; geprüfte Preisclaims plus Betreiber-/Rechtsfreigabe |
| OPS-001 | open/external | T002 | keine Backups/Restores; lokale sichere Tools plus echter Offsite-Full-Restore |
| OPS-002 | open | T002 | destruktives defektes Skript vorhanden; technisch gesperrt/ersetzt und Wegwerftest |
| OPS-003 | open | T006 | sent vor SMTP-Handoff; Outbox-/Failure-/Reconciliation-Test |
| OPS-004 | open | T006 | keine Jobfehlerstrategie; Retry-/Dead-/Replay-Test |
| OPS-005 | open/external | T006 | Healthcheck zu flach; DB/Queue/Storage-Matrix plus Live-Alarmprobe |
| OPS-006 | open/external | T006 | Monitoring/Incident/Breach nicht operationalisiert; Alarm-/Incident-Walkthrough |
| OPS-007 | open | T006 | Migration beim Webstart; separater Migrations-/Rollback-Smoke |
| OPS-008 | open/external | T006 | Single-node-Kopplung; Runbook/Ressourcenlimits plus akzeptiertes RTO |
| OPS-009 | open/external | T006 | SQLite-Wartung/Snapshot fehlt; Integrity-/WAL-/Disk-/Restore-Test |
| OPS-010 | open/external | T006 | keine SBOM/Signatur/Provenance; CI-Scan plus Registry-Signaturnachweis |
| OPS-011 | open/external | T006 | root/persönlicher Key; Least-Privilege-Konfig plus echter Hostnachweis |
| OPS-012 | open/external | T006 | keine SLO/Kapazität; Volumentest plus Betreiberziele |
| ARCH-001 | open/external | T007 | vier Tabellen ohne Migration/Code; leeres DB-Prepare plus Datenentscheidung |
| ARCH-002 | open | T007 | Teilauftrag bei Templatefehler; vollständiger Rollback-Test |
| ARCH-003 | open | T007 | Statuslogik verteilt; Transition-Contract-Tests |
| ARCH-004 | open | T007 | überladene Controller/Views; verhaltensgleiche Use-Case-Grenzen und Tests |
| ARCH-005 | open/external | T005 | mit LEG-005; atomare Finalisierung/Nummern plus fachliche Freigabe |
| QUAL-001 | open | T007 | mehrere Gates rot; sämtliche verpflichtenden Gates grün |
| QUAL-002 | open | T007 | Failure-/Concurrency-/Recovery-Lücken; risikobasierte Suite plus Coverage-Trend |
| QUAL-003 | open | T007 | wenig JS-/a11y-Automation; Component-/axe-/Browser-Smokes |
| QUAL-004 | open | T007 | tote Views/veraltete Doku; Inventar bereinigt und CI-Doku korrekt |
| PERF-001 | open | T008 | unpaginierte Listen/O(n×m)-Kalender; Query-/Volumenbudget grün |
| PERF-002 | open | T008 | 113 MB Bildquellen im Buildkontext; Runtime-/Buildgrößenbudget grün |
| A11Y-001 | open/external | T008 | kein WCAG/BFSG-Nachweis; axe plus manuelle Matrix und Scopeentscheidung |
| A11Y-002 | open | T008 | mobile Menüs ohne Fokus-/ARIA-Pattern; Keyboard-Browsertests |
| A11Y-003 | open | T008 | Skip-Link/`aria-current` fehlen; DOM-/Keyboardtest |
| A11Y-004 | open | T008 | Autoplay ohne Pause/reduced motion; Browser-/Mediaquery-Test |
| A11Y-005 | open | T008 | Flashes/Formfehler nicht assistiv; Live-/Fokus-/ARIA-Test |
| PWA-001 | open | T008 | mit SEC-012; Scope-/Cache-Browsertest |
| PWA-002 | open | T008 | keine Update-/Offline-/Failure-UX; PWA-Browsersuite |

## Paket- und Abhängigkeitsentscheid

1. **T002 / Welle 0:** SEC-001, OPS-001, OPS-002. Dependencies patchen,
   gefährliches Skript sofort fail-closed sperren, konsistente lokale
   Backup-/Restore-Artefakte und isolierten Restore-Test bauen. Der echte
   Offsite-/Produktionsnachweis bleibt explizit für T009 offen.
2. **T003:** Adminidentität, Autorisierung, Sessions, Reset, CSP/Hosts,
   Monitoringauth und Security-Audit als ein Security-Boundary-Paket.
3. **T004:** Uploads, Logs, Formulare, LocalStorage, Push und der gesamte
   Privacy-Datenlebenszyklus. Externe Provider-/Fristfreigaben werden als
   Abhängigkeiten erhalten.
4. **T005:** Rechnung/Steuer/Nummern/Korrektur/E-Rechnung zusammen behandeln;
   keine isolierte PDF-Kosmetik.
5. **T006:** Mail/Jobs/Monitoring/Deploy/SQLite/Supply-Chain als
   Reliability-Paket.
6. **T007:** Schema, Transaktionen, Zustandsarchitektur und Quality-Gates.
7. **T008:** Accessibility, PWA und Performance einschließlich Browserbelegen.
8. **T009:** echte Betreiber-/Provider-/Rechts-/Steuerbelege; keine erfundenen
   Fakten.

## Freigegebenes Worker-Paket T002

### Objective

Welle 0 lokal vollständig umsetzen: sämtliche aktuellen Runtime-Advisories
patchen, das destruktive Produktionsskript technisch fail-closed sperren und
ein konsistentes, verschlüsselbares Backup-/Restore-Verfahren mit sicherem
isoliertem Restore-Test und Runbook schaffen.

### Allowed files

- `Gemfile`
- `Gemfile.lock`
- `bin/brakeman`
- `script/replace_prod_storage_from_staging`
- `script/backup_storage`
- `script/restore_storage`
- `test/scripts/production_storage_safety_test.rb`
- `documentation/backup_restore.md`
- `documentation/testing.md`
- `.github/workflows/ci.yml`

### Verify

- `bin/bundler-audit check`
- `bundle exec brakeman --no-pager`
- `bin/rails test test/scripts/production_storage_safety_test.rb`
- `bin/rails test`
- isolierter Backup-/Restore-Test mit Wegwerfverzeichnissen, Checksummen und
  beschädigtem Archiv als Negativfall
- `git diff --check`

### Stop if

- Ein Test oder Skript berührt reale, nicht eindeutig temporäre Daten.
- Die verfügbaren gepatchten Gemversionen sind unter Ruby 3.4/Rails 8.1 nicht
  auflösbar oder verlangen eine fachliche Produktänderung.
- Verschlüsselung oder Offsite-Upload würde ohne gewähltes Tool/Ziel nur
  Scheinsicherheit erzeugen; dann lokal exportierbares verschlüsselbares
  Artefakt liefern und den echten Offsite-Schritt offen halten.

## Benötigte externe Evidenz

- Backupziel, Verschlüsselungs-/Key-Owner, Aufbewahrung, RPO/RTO und echter
  isolierter Produktionsrestore.
- Betreiber-/Register-/USt-/Beschäftigten-/Umsatz-/Bilanz-/B2C-B2B- und
  Vertragsschlussdaten.
- AVV/DPA, Subprozessoren, Regionen, SCC/TIA und Retention für alle Provider.
- Umami-/Resend-/Push-/Monitoring-Livekonfiguration.
- Steuerfreigabe für Fristen, Storno/Korrektur, Mischsteuer und E-Rechnung.
- Rechtsfreigabe für DDG/MStV/VSBG/BFSG/Fernabsatz/PAngV und Art.-13-Texte.
- Produktionshost-, Deployuser-, Firewall-, Patch-, Disk-, Alarm-, Registry-
  und Incident-Nachweise.
