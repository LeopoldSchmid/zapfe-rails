# Verarbeitungsinventar (Arbeitsstand)

Stand: 16. Juli 2026. Verantwortlicher: ape2tap UG (haftungsbeschränkt). Dieses Inventar ist die technische Grundlage für VVT, Löschkonzept, Datenschutzhinweise und TOMs. Rechtliche Freigaben sind separat nachzuweisen.

| Verarbeitung | Betroffene/Daten | Zweck | vorläufige Grundlage | Empfänger/System | Löschtrigger / Hold |
|---|---|---|---|---|---|
| Websitebetrieb | IP, Zeitpunkt, Pfad, UA, Request-ID | Auslieferung, Fehler- und Missbrauchsabwehr | Art. 6(1)(f) | Rails/Proxy, Hetzner | Logrotation; Security-/Incident-Hold |
| Anfrage | Name, E-Mail, freiwilliges Telefon, Event, Nachricht, Auswahl/Kalkulation | vorvertragliche Bearbeitung | Art. 6(1)(b) | internes CRM, Hetzner, Resend | Abschluss/Absage plus freizugebende Frist; Anspruchs-Hold |
| Auftrag/Angebot | Kontakt, Event, Leistungen, Kommunikation, Dateien | Vertrag, Planung, Durchführung | Art. 6(1)(b) | internes Cockpit, Hetzner, Resend, erforderliche Lieferanten | Vertragsende plus freizugebende Frist; Anspruchs-Hold |
| Rechnung | Empfänger, Positionen, Steuer-, Zahlungs- und Dokumentdaten | Abrechnung und gesetzliche Nachweise | Art. 6(1)(b)/(c) | Cockpit, Mail, Steuerberatung/Behörden soweit erforderlich | gesetzliche handels-/steuerrechtliche Frist; Audit-/Verfahrens-Hold |
| Web Push | Endpoint, Schlüssel, Adminzuordnung; generischer Nachrichtentext | freiwillige interne Erinnerung | Art. 6(1)(f), Beschäftigtenkontext gesondert prüfen | Browser-/Push-Infrastruktur | Abmeldung, Geräteverlust, Offboarding |
| Reichweitenmessung | Seitenaufruf, Referrer, Browser-/Geräteklasse, grobe Region gemäß Live-Konfiguration | Webverbesserung | Interessenabwägung/§25-Prüfung offen | Umami-Betreiber | konkrete Live-Retention freizugeben |
| Security-Audit | Akteur/Ziel, Ereignis, Request-ID, HMAC-IP, UA-Familie | Zugriffsschutz, Nachvollziehbarkeit | Art. 6(1)(f) | internes Cockpit | Security-Retention/Incident-Hold freizugeben |
| Backup | Kopie aller produktiven Datengruppen und Dateien | Verfügbarkeit/Wiederherstellung | folgt Primärzwecken, Art. 6(1)(f)/(c) | verschlüsseltes Offsite-Ziel offen | Generationenfrist; Tombstone-Nachlauf vor Freigabe |

## Datenschutz-Folgenabschätzung

Der technische Stand enthält keine systematische Bewertung persönlicher Aspekte, keine umfangreiche Verarbeitung besonderer Kategorien und keine öffentliche Überwachung. Dennoch muss der Betreiber die Kriterien nach Art. 35 DSGVO anhand realer Mengen, Beschäftigtendaten, Push-/Analysekonfiguration und möglicher Freitextinhalte dokumentieren. Das Ergebnis – „erforderlich“ oder „nicht erforderlich“ mit Begründung – ist ein externer Freigabebeleg.

## Technische und organisatorische Maßnahmen

Technisch umgesetzt sind insbesondere TLS/HTTPS, Host-Allowlist, restriktive CSP/Permissions-Policy, Rollenprinzip, MFA, Session-Widerruf, Rate Limits, pseudonymisierte Security-Audits, signaturbasierte Uploadprüfung, verschlüsselbare Backups, Restore-Integritätsprüfung und transaktionale Legal-Hold-/Löschsperren. Organisatorisch zu belegen sind Berechtigungsreview, Offboarding, Schlüsselbesitz, Backupalarmierung, Incident-/Breach-Übung, Lieferantenprüfung und regelmäßige Löschläufe.
