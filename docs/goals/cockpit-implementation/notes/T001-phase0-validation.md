# T001 – Phase-0-Bestandsvalidierung

## Belegter Ausgangsbestand

- Rails 8.1, SQLite, Turbo, Stimulus, Tailwind, Active Storage sowie Solid Queue/Cache/Cable sind vorhanden (`Gemfile`). Ein PDF-Renderer, ein Dokumentmodell und ein Lieferantenmodell fehlen.
- `AdminUser` ist derzeit ausschließlich `email` plus Passwortdigest. Login und Passwortreset existieren, aber inaktive Konten, Admin-Verwaltung, Namen, Signaturen, Benachrichtigungen und die Absicherung des letzten aktiven Kontos fehlen (`app/models/admin_user.rb`, `app/controllers/admin/*`).
- `Inquiry` speichert bereits Kontakt-, Veranstaltungs-, Miet- und Kalkulations-Snapshot-Daten, wird aber nur öffentlich erstellt. Es fehlen Zuständigkeit, Prozessstatus, nächster Schritt, Fälligkeit, Abschlussgrund, interne Liste und Chronik (`app/models/inquiry.rb`, `app/controllers/inquiries_controller.rb`, `config/routes.rb`).
- Der aktuelle Adminbereich besteht aus Dashboard, Produkten, Kategorien und Events. Das Dashboard zeigt nur Gesamtzahlen (`app/controllers/admin/dashboard_controller.rb`, `app/views/admin/dashboard/index.html.erb`).
- Ein `Order`-, Aktivitäten-, Notiz-, Anlagen- oder Ressourcenmodell existiert nicht. Active Storage ist vorhanden und kann für spätere autorisierte Vorgangsanlagen verwendet werden.
- Der Katalog besitzt 90 Produkte und 103 Varianten. `ProductVariant` enthält `sku`, `size`, Verkaufspreis, `availability` und `is_available`; Händler-SKU, Einkaufspreise und Beschaffungsregeln fehlen. Die Werte `availability`/`is_available` werden im Produktformular gepflegt und dürfen erst nach einer erhaltenden Migration auf das Lieferantenmodell abgelöst werden (`app/models/product*.rb`, `app/views/admin/products/_form.html.erb`).
- Seeds enthalten nur einen Admin und beispielhafte Rothaus-Varianten. Die drei beschlossenen Start-Admins müssen als sichere, idempotente Seed-/Migrationsstrategie ergänzt werden; produktive Zugangsdaten dürfen nicht im Repository stehen (`db/seeds.rb`).

## Test- und Betriebsbaseline

`bin/rails test` lief mit 64 Tests und 3 vorhandenen Fehlern:

1. `ApplicationHelperTest#test_falls_back_to_subcategory_when_name_is_blank` – erwartetes Label `Afri Cola`, tatsächlich `Cola`.
2. `ApplicationHelperTest#test_builds_product_labels_from_brand_and_name` – erwartet `Rothaus Pils`, tatsächlich `Pils`.
3. `Admin::PasswordsControllerTest#test_enqueues_reset_email_for_existing_admin` – erwartet einen Job, Controller verwendet derzeit `deliver_now`.

Diese Fehler liegen außerhalb des ersten Cockpit-Schnitts und müssen als eigene Repo-Health-Aufgabe bereinigt werden, bevor die Suite als grüne Cockpit-Abnahme dienen kann. Beim Rails-Start erscheint zusätzlich eine nicht blockierende libvips-/openslide-Warnung.

## Phase-0-Entscheidungen für Phase 1

- `Inquiry` wird erweitert, statt einen zweiten Eingang einzuführen; seine vorhandenen strukturierten Felder werden beim Umwandeln als Snapshot in `Order` kopiert.
- `Order` erhält eine optionale, eindeutige `inquiry_id`. Ein eindeutiger DB-Index und ein transaktionaler Service `Orders::CreateFromInquiry` machen die Konvertierung idempotent.
- Phase 1 beginnt mit einem zusammenhängenden Slice: Admin-Konten/Deaktivierung, Inquiry-Ownership und -Status, Order-Konvertierung sowie listenfähige Admin-UI und Tests. Chronik/Anlagen können daran anschließen, statt ihr Modell vor dem Kernablauf vorwegzunehmen.
- Produkt-/Lieferantenmigration, PDF-Wahl, Backup/Restore und DSGVO-Löschkonzept bleiben vor Phase 2 beziehungsweise Produktivbetrieb als Pflichtprüfungen offen. Sie blockieren Phase 1 nicht.

## Erstes Worker-Paket

Die erste Implementierung soll den echten Kernablauf vom Eingang bis zur Auftragsakte liefern, ohne die noch offene Angebots- oder Lieferantenarchitektur vorwegzunehmen. Sie darf die vorhandenen öffentlichen Formulare und gespeicherten Inquiry-Daten nicht verändern oder verlieren.
