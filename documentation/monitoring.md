# Monitoring & Alerting (Zapfe + Hausl)

## Ziel
Frühzeitig erkennen, wenn kritische Funktionen ausfallen, und direkt per Telegram alarmiert werden.

## Architektur (klein, robust)
- Separates Ops-Setup mit **Uptime Kuma** (kein eigenes Rails-Projekt nötig).
- Monitore für beide Projekte in einem Dashboard.
- Telegram als zentrale Alerting-Integration.
- Dashboard-Hosting über `status.duzend.net` hinter Reverse Proxy + BasicAuth.

## DNS
In der **autoritativen DNS-Zone** anlegen:
- `A status.duzend.net -> 157.180.19.232`
- optional `AAAA status.duzend.net -> <deine IPv6>`

## Start auf dem Server
```bash
cd /home/leo/dev/projects/ops-monitoring
cp .env.example .env
# BasicAuth-Hash erzeugen:
docker run --rm caddy:2-alpine caddy hash-password --plaintext 'DEIN_SICHERES_PASSWORT'
docker compose up -d
```

Danach Dashboard öffnen:
- `https://status.duzend.net`

## Monitore anlegen
1. HTTP(s)-Monitor: `https://hausl.duzend.net/up`
2. HTTP(s)-Monitor: `https://staging.zapfe.jetzt/up`
3. Kritischer Zapfe-Flow:
   - `https://staging.zapfe.jetzt/monitoring/inquiry_flow?token=<MONITORING_TOKEN>`

Hinweis zu (3):
- Die Route prüft, ob Inquiry-Validierung + Mail-Rendering funktionieren.
- Kein DB-Schreiben, kein echter Mailversand.
- Token wird über `MONITORING_TOKEN` geschützt.

## Token setzen (Zapfe App)
In der Deploy-Umgebung zusätzlich setzen:
- `MONITORING_TOKEN=<lange-zufallszeichenfolge>`

Dann deployen:
```bash
bin/kamal deploy
```

## Telegram einrichten
1. Bot via `@BotFather` erstellen.
2. Chat-ID ermitteln.
3. In Uptime Kuma Notification vom Typ Telegram anlegen.
4. Notification bei allen Monitoren verknüpfen.

## Empfohlene Intervalle
- `/up`: 60 Sekunden
- `inquiry_flow`: 5 Minuten

## Nächster Ausbauschritt
- Optional Sentry in beiden Rails-Projekten ergänzen (Error Tracking auf App-Ebene).

## DNS-Automatisierung (statt manuell)
Empfohlene Optionen:
1. `dnscontrol` oder `octoDNS` (DNS as Code).
2. Terraform mit DNS-Provider.
3. Eigene API-Skripte, falls der DNS-Provider eine API bietet.
