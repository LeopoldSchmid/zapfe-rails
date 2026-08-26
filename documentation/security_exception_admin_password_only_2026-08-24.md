# Sicherheitsausnahme: Passwort-only im Adminbereich

Stand: 24. August 2026. Diese Entscheidung gilt ausschließlich für den
internen Adminbereich unter `/admin`; die öffentliche Website ist nicht Teil
dieser Änderung.

## Entscheidung

Der Adminbereich ist vorerst ohne VPN und ohne zweiten Faktor erreichbar. Die
Anmeldung erfolgt mit persönlichen Passwörtern für diese Konten:

- `leopold.schmid@zapfe.jetzt`
- `dennis.buehler@zapfe.jetzt`
- `johannes.wiese@zapfe.jetzt`

Die Ausnahme gilt bis zum Review am **24. November 2026**. Owner ist Leopold
Schmid; Johannes Wiese ist als Vertretung eingetragen.

## Risikoakzeptanz

Wer ein Passwort eines Kontos erlangt, kann sich ohne weitere Hürde als diese
Person anmelden und – abhängig von ihrer Rolle – auf den Adminbereich und die
dort verarbeiteten Geschäfts- und Kontaktdaten zugreifen. Phishing,
Passwort-Wiederverwendung, Schadsoftware auf einem Mitarbeitergerät und
Sessiondiebstahl werden durch Passwort-only nicht zuverlässig verhindert.

Der Verzicht auf VPN reduziert zusätzlich die Netzwerkbarriere: `/admin` ist
über das Internet erreichbar. Die Maßnahme ist deshalb eine bewusste,
befristete Betriebsentscheidung und kein gleichwertiger Ersatz für MFA oder
einen vorgeschalteten privaten Netzwerkzugang.

## Verbindliche Gegenmaßnahmen

- ausschließlich persönliche Konten, keine gemeinsame Anmeldung;
- mindestens 16 Zeichen, keine naheliegenden Namen oder E-Mail-Bestandteile
  und keine bekannten schwachen Passwörter;
- für jedes Konto ein eigenes, zufällig erzeugtes Passwort im Passwortmanager;
- Login-Rate-Limits pro IP und Konto, Security-Audit für erfolgreiche und
  fehlgeschlagene Anmeldungen;
- Sessionrotation nach Login, Widerruf bei Passwort-, Rollen- oder
  Aktivitätsänderung, 30 Minuten Inaktivitätsablauf und 12 Stunden maximale
  Sessiondauer;
- Offboarding durch Deaktivierung des persönlichen Kontos; vorherige Sessions
  werden dadurch ungültig;
- Bootstrap-Passwörter nur über die Umgebung beziehungsweise den Secret-Store
  setzen, niemals im Repository speichern, und nach dem Seed-Vorgang aus dem
  Bootstrap-Secret entfernen.

## Neubewertung

Die Ausnahme wird vor dem Reviewtermin aufgehoben oder ausdrücklich verlängert.
Eine sofortige Neubewertung ist erforderlich, wenn ein Konto kompromittiert
wird, sich das Team vergrößert, sensible Funktionen hinzukommen oder der
Adminbereich für weitere Nutzergruppen geöffnet wird.

Die MFA-Spalten im Datenbankschema bleiben vorerst als rückwärtskompatible
Altlast bestehen. Sie werden nicht vom Login ausgewertet und besitzen keinen
aktiven Admin- oder Seedpfad.
