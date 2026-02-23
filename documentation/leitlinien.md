# Leitlinien Zapfe Rails

Stand: 2026-02-23

## Zielbild
- Rails 8.1.x als alleiniger App-Stack.
- Server-rendered UI mit Hotwire (Turbo + Stimulus).
- SQLite3 als primäre Datenbank (geringe Last, einfacher Betrieb).
- Active Storage (Disk) für Produktbilder.
- Action Mailer mit Resend für transaktionale E-Mails.
- Deployment auf Hetzner mit Kamal, analog Hausl.

## Architektur
- Rails-Standards zuerst: RESTful Routes, Resource-Controller, klare Models.
- Domainlogik in Models/Service-Objekten, nicht in Views.
- Keine unnötigen externen Dienste.
- Keine public User-Accounts in V1.
- Admin-Bereich ist klar getrennt vom Public-Bereich.

## UI-Prinzipien
- UI soll visuell nahezu identisch zum aktuellen Zapfe-Auftritt bleiben.
- Bestehende Informationsarchitektur (Seiten/Flows) beibehalten, sofern kein funktionaler Grund dagegen spricht.
- Abweichungen nur, wenn sie Wartbarkeit verbessern oder Abhängigkeiten reduzieren.
- Calculator in V1 bewusst vereinfacht (kein Geo-Dienst), Layout/Bedienlogik möglichst ähnlich.

## Datenmodell (V1, schlank)
- Category
- Product
- ProductVariant
- Event (öffentliche Event-Karten, durch Admin pflegbar, optional `instagram_url`)
- Inquiry (Kontakt + Kalkulator-Anfrage, optional für Nachvollziehbarkeit)
- AdminUser

Nicht Teil von V1:
- öffentliches User-System
- Buchungs-/Checkout-Engine
- komplexes Inventory- oder Event-Management

## Bilder & Dateien
- Produktbilder über Active Storage verwalten.
- Lokale Speicherung via `storage/` Volume (Kamal Persistent Volume).
- Bildderivate/Thumbnails über Active Storage Variants.

## E-Mail
- Resend bleibt Versandprovider.
- Versand über Action Mailer.
- Zwei Mails pro Anfrage:
  - Bestätigung an Kunden
  - Benachrichtigung an Admin

## Testing-Standards
- Jede veränderte Businesslogik erhält Rails-Tests (Model/Service/Controller).
- Kritische Flows erhalten systematische Request-/System-Tests.
- Der Kostenkalkulator wird als testbare Service-Klasse abgebildet.
- Ziel: keine rein in Views versteckte Preislogik.

## Betriebsprinzipien
- Keep it simple: wenig moving parts, niedriger Ops-Aufwand.
- Sicherheit im Admin-Bereich über serverseitige Authentifizierung.
- Konfiguration über ENV/Secrets; keine Secrets im Repo.

## Nicht-Ziele für V1
- Vollständige 1:1-Portierung aller Legacy-Datenstrukturen.
- Geocoding/Distance Pricing via externe APIs.
- Multi-Tenant/Role-Matrix wie in Hausl (hier nicht notwendig).
