# Rundgang durch den Code (für Einsteiger)

Diese Seite erklärt in einfachen Worten, wo in der App was steht. Du musst nicht alles auf einmal verstehen.
Fang mit dem Abschnitt an, der dich gerade interessiert.

## 1. Die wichtigsten Ordner

| Ordner | Was drin ist |
|---|---|
| `lib/` | der ganze App-Code |
| `lib/features/` | ein Ordner pro Funktion: `diary` (Tagebuch), `products` (Produkte und Suche), `scan`, `goals` (Ziel), `stats` (Statistik), `profile` |
| `lib/core/` | Dinge, die überall gebraucht werden: Farben und Abstände (`theme/`), Zahlenformat (`format.dart`), Datum (`clock.dart`), gemeinsame Bausteine (`widgets/`) |
| `lib/data/` | die Datenbank (`database.dart`) und kleine Einstellungen |
| `lib/l10n/` | alle Texte auf Deutsch (`app_de.arb`) und Englisch (`app_en.arb`) |
| `assets/data/` | die eingebauten Lebensmittel-Listen |
| `test/` | die automatischen Tests, gleich aufgebaut wie `lib/` |

Faustregel: **Seiten** heißen `…_page.dart`. **Datenzugriff** steht in `…_repository.dart`. Reine
Rechenlogik ohne Bildschirm hat einen sprechenden Namen wie `calculator.dart` oder `health_rating.dart`.

## 2. Was passiert, wenn du ein Produkt scannst?

1. **Kamera:** `lib/features/scan/widgets/barcode_scanner_view.dart` liest den Strichcode.
2. **Prüfen:** `lib/features/products/gtin.dart` prüft die Prüfziffer, damit Tippfehler gar nicht erst
   gesucht werden.
3. **Seite öffnen:** Die App geht zur Adresse `/product/<nummer>`. Alle Adressen stehen in
   `lib/router.dart` (`Routes`).
4. **Nachschauen:** `lib/features/products/product_repository.dart` schaut zuerst in der eigenen Datenbank
   nach (Cache). Nur wenn das Produkt fehlt oder zu alt ist, fragt er Open Food Facts
   (`off_client.dart`). Die Antwort übersetzt `off_product_mapper.dart` in unsere Felder.
5. **Bewerten:** `health_rating.dart` entscheidet „wenig / mittel / viel“ für Fett, Zucker und Salz.
6. **Anzeigen:** `product_page.dart` zeigt alles an. Mit „Hinzufügen“ speichert
   `lib/features/diary/diary_repository.dart` einen Tagebuch-Eintrag. Dabei werden die Nährwerte
   **kopiert**, damit sich alte Tage nie mehr ändern.

## 3. Was ist ein „Provider“?

Ein Provider ist eine Stelle, an der die App Daten **holt**, z. B. `diaryRepositoryProvider` oder
`clockProvider` (die aktuelle Uhrzeit). Bildschirme fragen Provider statt sich die Daten selbst zu besorgen.
Der Vorteil: In Tests kann man einen Provider **austauschen**, z. B. eine feste Uhrzeit oder eine leere
Test-Datenbank. Genau das macht `test/helpers/pump_app.dart`.

## 4. Kleine Änderungen selbst machen

### Einen Text ändern oder hinzufügen
1. Text in **beiden** Dateien eintragen: `lib/l10n/app_de.arb` (mit „du“) und `lib/l10n/app_en.arb`.
2. `flutter gen-l10n` ausführen.
3. Im Code verwenden: `AppLocalizations.of(context).deinSchluessel`.

### Ein Lebensmittel zur einfachen Liste hinzufügen
Steht in `tool/simple_foods/README.md`. Kurz: Zeile in `tool/simple_foods/foods.tsv` ergänzen, das
Bau-Skript laufen lassen, Tests laufen lassen.

### Eine neue Spalte in der Datenbank
1. Spalte in `lib/data/database.dart` ergänzen.
2. `schemaVersion` um 1 erhöhen und in der Migration (`onUpgrade`) `m.addColumn(...)` eintragen. Sonst
   funktioniert die App auf Handys mit der alten Datenbank nicht mehr.
3. `dart run build_runner build` ausführen.
4. Den Migrationstest in `test/data/migration_test.dart` erweitern.

## 5. Prüfen, ob alles noch geht

```sh
dart format lib test        # Code ordentlich formatieren
flutter analyze             # findet Fehler und Unsauberkeiten, muss "No issues found!" sagen
flutter test                # alle Tests, müssen grün sein
```

Dieselben Prüfungen laufen automatisch auf GitHub bei jedem Hochladen (CI). Ein rotes Kreuz bei GitHub
heißt: Eine Prüfung ist fehlgeschlagen. Klick drauf, dann siehst du welche.

## 6. Die App auf dem iPhone ausprobieren

```sh
flutter build ios --release
xcrun devicectl device install app --device <iPhone-ID> build/ios/iphoneos/Runner.app
```

Die iPhone-ID zeigt `xcrun devicectl list devices`. Das iPhone muss entsperrt sein und im Entwicklermodus
laufen.
