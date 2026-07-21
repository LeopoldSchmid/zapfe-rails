# Auftragsverarbeiter- und Transferregister

Stand: 16. Juli 2026. Ein Eintrag ist erst produktionsfreigegeben, wenn Vertrag, Unterauftragnehmer, Region, Löschung und Transfergrundlage durch den Betreiber belegt wurden.

| Anbieter/Dienst | Zweck/Daten | im Code belegte Konfiguration | erforderlicher Betreiberbeleg | Status |
|---|---|---|---|---|
| Hetzner Online GmbH | Hosting, Datenbank, Dateien, Logs, Backups je Ziel | Kamal/Host und lokaler Active-Storage-Pfad | Öffentliches DPA-/TOM-/Subunternehmermaterial geprüft; abgeschlossenes AVV, Accountprodukt/-standort, Zugriff, Löschung und Offsite-Ziel belegen | öffentliche Basis geprüft, Account offen |
| Resend / Plus Five Five, Inc. | ausschließlich notwendige transaktionale Anfrage-, Angebots- und Rechnungsmails samt Metadaten/Inhalt; keine Marketingkampagnen | SMTP `smtp.resend.com`, API-Key; keine Aktivierung von Öffnungs-/Klicktracking im Anwendungscode | DPA 31.12.2025, SCC, US-Accountdatenspeicherung, öffentliche Subprozessoren und 30-Tage-Standardretention geprüft; Betreiberentscheidung vom 21.07.2026 akzeptiert die US-Verarbeitung für den eng begrenzten Versandzweck. Accountannahme, Versandregion, Content Storage und dokumentierte Transfer-Risikoabwägung nachziehen | öffentliche Basis und Zweckfreigabe geprüft, Account-/Transferbeleg offen |
| Umami unter `analytics.duzend.net` | Reichweitenmessung | Script-URL, Website-ID und Domains per ENV | Betreiber/Hosting, Version, Netzwerkbeleg, IP-/UA-Verarbeitung, Events, Retention, §25-/Art.-6-Entscheidung | offen |
| Browser-Push-Dienste | Endpoint/Schlüssel und generische Push-Payload | Web Push/VAPID | Browser-/Plattformmix, Beschäftigtenregel, Offboarding, Drittländer | offen |
| Mailbox/IONOS und verwendete Clients | Antworten und laufende Kommunikation | außerhalb der App; IONOS in Planungsdoku genannt | Vertrag, Clients/Weiterleitungen, Region, MFA, Retention | offen |

## Freigabegate

Für jeden aktiven Dienst müssen aktuelle Dokumentkopie/Vertrags-ID, Freigabedatum, verantwortliche Person, nächste Prüfung und technische Live-Evidenz hinterlegt werden. Bei Drittländern sind Transfermechanismus und Transfer Impact Assessment zu dokumentieren. Ohne diese Belege bleibt PRIV-005 beziehungsweise der jeweilige Produktionsslice offen.

Öffentliche Anbieterunterlagen reduzieren den Prüfaufwand, beweisen aber nicht,
dass der konkrete Kundenaccount den Vertrag abgeschlossen oder die dokumentierte
Konfiguration gewählt hat. Details und Primärlinks stehen im Betreiberpaket und
in `docs/goals/production-readiness-remediation/notes/T011-public-external-evidence.md`.
