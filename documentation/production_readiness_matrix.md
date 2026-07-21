# Produktionsreife: 60-Finding-Abschlussmatrix

Stand: 17. Juli 2026. `TECHNISCH GESCHLOSSEN` bedeutet: lokal implementiert und
durch den angegebenen Gate belegt. `EXTERNES NO-GO` bedeutet: alle sichere
lokale Vorarbeit ist vorhanden, aber ein realer Betreiber-, Provider-, Rechts-,
Steuer- oder Infrastrukturnachweis fehlt. Ein externes NO-GO ist nicht erledigt
und darf für eine Produktionsfreigabe nicht als grün gewertet werden.

## Security

| ID | Status | Abschlussbeleg |
| --- | --- | --- |
| SEC-001 | TECHNISCH GESCHLOSSEN | Bundler Audit ohne bekannte Advisories |
| SEC-002 | TECHNISCH GESCHLOSSEN | Rollen-/Policy-Negativtests |
| SEC-003 | TECHNISCH GESCHLOSSEN | Passwortstandard, TOTP-MFA, Recovery-Tests |
| SEC-004 | TECHNISCH GESCHLOSSEN | Sessionrotation und -widerruf getestet |
| SEC-005 | TECHNISCH GESCHLOSSEN | Reset-Rate-Limits/Cooldowns getestet |
| SEC-006 | TECHNISCH GESCHLOSSEN | zentrale Größen-, Typ- und Magic-Byte-Prüfung |
| SEC-007 | TECHNISCH GESCHLOSSEN | Monitoringtoken ausschließlich im Header |
| SEC-008 | TECHNISCH GESCHLOSSEN | restriktive CSP und Originprüfung |
| SEC-009 | TECHNISCH GESCHLOSSEN | keine direkte PII im Spam-/Securitylog |
| SEC-010 | TECHNISCH GESCHLOSSEN | persistente Security-Auditspur |
| SEC-011 | TECHNISCH GESCHLOSSEN | Host-Allowlist und Permissions Policy |
| SEC-012 | TECHNISCH GESCHLOSSEN | Service Worker auf `/admin/` begrenzt |

## Datenschutz

| ID | Status | Abschlussbeleg / fehlender Nachweis |
| --- | --- | --- |
| PRIV-001 | EXTERNES NO-GO | technische Art.-13-Basis vorhanden; Verantwortlichen-/Provider-/Rechtsfreigabe fehlt |
| PRIV-002 | EXTERNES NO-GO | Lifecycle, Holds, Tombstones vorhanden; Fristmatrix nicht freigegeben |
| PRIV-003 | TECHNISCH GESCHLOSSEN | Browser-Smoke beweist Entfernung alter Kontakt-PII |
| PRIV-004 | TECHNISCH GESCHLOSSEN | versionierte Kenntnisnahme statt Einwilligungsfiktion |
| PRIV-005 | EXTERNES NO-GO | öffentliche Hetzner-/Resend-DPA-Basis geprüft; Accountverträge, Resend-TIA und übrige Providertransfers fehlen |
| PRIV-006 | EXTERNES NO-GO | Export-/Löschprozess vorhanden; Owner, Kanal und Übung fehlen |
| PRIV-007 | EXTERNES NO-GO | VVT-/TOM-/Breach-Vorlagen vorhanden; Freigaben/DPIA-Screening fehlen |
| PRIV-008 | EXTERNES NO-GO | Umami fail-closed deaktiviert; Live-/§25-/Art.-6-Freigabe fehlt |
| PRIV-009 | TECHNISCH GESCHLOSSEN | Pushpayload ohne Kunden-/Aufgabendetails |
| PRIV-010 | TECHNISCH GESCHLOSSEN | Telefon freiwillig, Datenminimierung/Negativtests |

## Legalität und Rechnungen

| ID | Status | Abschlussbeleg / fehlender Nachweis |
| --- | --- | --- |
| LEG-001 | EXTERNES NO-GO | RStV auf MStV korrigiert; Repositoryangaben sind nicht amtlich corroboriert, aktueller Register-/Steuerbeleg und Betreiberbestätigung fehlen |
| LEG-002 | EXTERNES NO-GO | Beschäftigtenzahl und VSBG-Teilnahmeentscheidung fehlen |
| LEG-003 | EXTERNES NO-GO | axe-Baseline grün; BFSG-Scope und manuelles Audit fehlen |
| LEG-004 | TECHNISCH GESCHLOSSEN | Mischsteuer-Golden-Tests in PDF/XML |
| LEG-005 | EXTERNES NO-GO | atomare Nummern/Korrekturen technisch grün; Steuerfreigabe fehlt |
| LEG-006 | EXTERNES NO-GO | KoSIT-valide XRechnung/CreditNote; Kundenmix, Empfang und Archiv fehlen |
| LEG-007 | EXTERNES NO-GO | realer B2C-Vertragsschluss-/Widerrufspfad nicht freigegeben |
| LEG-008 | EXTERNES NO-GO | Preis als unverbindliche Indikation bezeichnet; vollständige Claim-/PAngV-Prüfung fehlt |

## Betrieb

| ID | Status | Abschlussbeleg / fehlender Nachweis |
| --- | --- | --- |
| OPS-001 | EXTERNES NO-GO | sichere Tools grün; echter verschlüsselter Offsite-Full-Restore fehlt |
| OPS-002 | TECHNISCH GESCHLOSSEN | destruktives Staging-zu-Prod-Skript fail-closed gesperrt |
| OPS-003 | TECHNISCH GESCHLOSSEN | persistente Dokument-Outbox und Failure-/Replaytests |
| OPS-004 | TECHNISCH GESCHLOSSEN | Jobretry, Dead State und idempotente Push-Outbox |
| OPS-005 | EXTERNES NO-GO | Deep Health vorhanden; echter externer Alarmtest fehlt |
| OPS-006 | EXTERNES NO-GO | Runbooks vorhanden; Rufbereitschaft/Incidentübung fehlt |
| OPS-007 | TECHNISCH GESCHLOSSEN | Migration getrennt, Webstart fail-closed, Schema-Neuaufbau grün |
| OPS-008 | EXTERNES NO-GO | getrennte Web-/Jobrollen; Single-Node-RTO-Akzeptanz fehlt |
| OPS-009 | EXTERNES NO-GO | SQLite-Tasks/Backup konsistent; Live-Disk-/Wartungs-/Restorebeleg fehlt |
| OPS-010 | EXTERNES NO-GO | Digest, Trivy und SBOM vorhanden; Registry-Signatur/Provenance fehlt |
| OPS-011 | EXTERNES NO-GO | Deploykonfiguration vorbereitet; echter Host-/User-/Firewallnachweis fehlt |
| OPS-012 | EXTERNES NO-GO | Startbudgets definiert; repräsentativer Lasttest und Betreiber-SLO fehlen |

## Architektur und Qualität

| ID | Status | Abschlussbeleg / fehlender Nachweis |
| --- | --- | --- |
| ARCH-001 | TECHNISCH GESCHLOSSEN | idempotente Rekonstruktionsmigration und leerer Schemaaufbau |
| ARCH-002 | TECHNISCH GESCHLOSSEN | transaktionale Auftragserstellung samt Rollbacktest |
| ARCH-003 | TECHNISCH GESCHLOSSEN | zentrale Transition Policies und Contract-Tests |
| ARCH-004 | TECHNISCH GESCHLOSSEN | Use-Case-/Query-Grenzen ohne Verhaltensänderung |
| ARCH-005 | EXTERNES NO-GO | atomare Rechnungsfinalisierung technisch grün; fachliche Steuerfreigabe fehlt |
| QUAL-001 | EXTERNES NO-GO | alle lokalen/CI-Gates grün; verpflichtende Branch Protection muss extern aktiviert werden |
| QUAL-002 | TECHNISCH GESCHLOSSEN | Failure-/Concurrency-/Recovery-Suite und Coverage 88,19/63,54 % |
| QUAL-003 | TECHNISCH GESCHLOSSEN | Playwright-, axe-, PWA-, Auth- und Keyboard-Gates in CI |
| QUAL-004 | TECHNISCH GESCHLOSSEN | tote View entfernt, Testdokumentation aktualisiert |
| PERF-001 | TECHNISCH GESCHLOSSEN | Pagination, Vorindexierung und Query-Budgettest |
| PERF-002 | TECHNISCH GESCHLOSSEN | 4,21-MB-Docker-Kontext; Quellen nicht im Runtime-Image |

## Accessibility und PWA

| ID | Status | Abschlussbeleg / fehlender Nachweis |
| --- | --- | --- |
| A11Y-001 | EXTERNES NO-GO | öffentliche/Admin-axe-WCAG-2.2-AA-Smokes grün; manueller AT-/Zoom-/BFSG-Nachweis fehlt |
| A11Y-002 | TECHNISCH GESCHLOSSEN | Menü-ARIA, Fokustrap, Escape und Rückgabe im Browsertest |
| A11Y-003 | TECHNISCH GESCHLOSSEN | Skiplinks, Fokusziel und `aria-current` |
| A11Y-004 | TECHNISCH GESCHLOSSEN | Pause-Steuerung und Reduced-Motion-Smoke |
| A11Y-005 | TECHNISCH GESCHLOSSEN | Live-Region, Fehlerfokus und `aria-invalid` |
| PWA-001 | TECHNISCH GESCHLOSSEN | Admin-Scope und Online-only-Cachetest |
| PWA-002 | TECHNISCH GESCHLOSSEN | explizites Update, Fehlerfallback und Browser-Smoke |

## Ergebnis

- 60 von 60 Finding-IDs sind abgebildet.
- 36 Findings sind technisch geschlossen.
- 24 Findings bleiben als externe NO-GO-Gates offen.
- Es gibt kein stillschweigend als erledigt behandeltes Betreiber-, Vertrags-,
  Rechts-, Steuer- oder Infrastrukturrisiko.
- Der lokale Release-Gate `script/release_check` ist vollständig grün; das
  Produktions-GO bleibt bis zur Abarbeitung des Betreiberpakets gesperrt.
