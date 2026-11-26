# Architecture

A short map of how the app is built. For a beginner-friendly German tour see [RUNDGANG.md](RUNDGANG.md).

## Stack

| Concern | Choice | Why |
|---|---|---|
| UI | Flutter 3.47 with `material_ui` (the Material library that moved out of the SDK in 3.47) | iOS + Android from one code base |
| State | Riverpod 3 without code generation | testable (overrides), no build step for state |
| Navigation | go_router, `StatefulShellRoute.indexedStack` for the 4 tabs | every screen has an address (`Routes` helpers in `lib/router.dart`) |
| Database | drift (SQLite) | typed queries, watched streams, migrations, in-memory tests |
| Small settings | shared_preferences (`SharedPreferencesAsync`) | theme, language, a dismissed hint |
| Texts | gen-l10n, ARB files for German (du) and English | |
| Product data | own thin client for Open Food Facts on `package:http` | small, readable, easy to fake in tests |
| Barcode scanning | mobile_scanner | camera runs only while the Scan tab is visible |

## Layers and folders

```
lib/
  core/       no dependency on features: clock, number formatting, AppFailure, theme, shared widgets
  data/       database (tables, migrations) and settings
  features/   one folder per feature; repositories (data access + providers), pages, widgets, pure logic
```

Rules: `core` imports nothing from `features`. Features may use `core`, `data` and the models/repositories
of other features, never another feature's private widgets. Screens never touch drift tables directly –
only repositories do.

## Data flow

- **Foods** live in one table (`Foods`): products cached from Open Food Facts, the user's own foods and
  every simple/BLS food the user opened (stored on first open, so favourites, recents and the product page
  work the same for all of them).
- **Diary entries** keep a *copy* of the name and of the nutrients per 100 g at logging time, so past days
  never change when product data changes. Values of an entry are computed at read time
  (`per 100 g × amount / 100`).
- **Days** are text keys `yyyy-MM-dd` in local time (`core/clock.dart`); "now" always comes from
  `clockProvider`, so tests can fix the date.
- **Unknown values are `null`, never 0.** Sums show "mind." (at least) when an entry lacks a value.

## Search

`features/products/widgets/food_search_results.dart` shows three sections:

1. **Lebensmittel** – the curated simple-foods list (`simple_foods*.dart`, bundled TSV files), ranked by
   word-start matches, found while typing, offline.
2. Foods on the device (own foods, recently used).
3. **Markenprodukte (Deutschland)** – Open Food Facts search (`search.openfoodfacts.org`, filtered with
   `countries:"en:germany"`), loaded automatically after a short typing pause; stale requests are dropped.

The technical BLS list (`basic_foods*.dart`, 7,140 foods) appears only when no simple food matches.
Barcode lookups use the Open Food Facts product API v3.4 and work worldwide.

## Health rating

`features/products/health_rating.dart` is pure Dart: UK front-of-pack thresholds per 100 g (foods) or
100 ml (drinks), plus points for fibre and protein from Regulation (EC) 1924/2006, a list of product kinds
that are not rated (water, coffee, spices, alcohol …) and sanity checks for implausible data. It is covered by
the test vectors in `test/features/products/health_rating_test.dart`.

## Errors

The data layer throws `AppFailure` subtypes (`core/errors.dart`: not found, offline, timeout, rate limited
…); screens turn them into friendly texts with `failureMessage`. The Open Food Facts client retries once on
timeouts/network errors and pauses all requests for 60 s after a 429 or 503.

## Tests

- `test/` mirrors `lib/`: unit tests for the logic, widget tests for every screen (German and English,
  text scale 2.0, screen reader on for the search).
- `test/helpers/pump_app.dart` starts the app with an in-memory database, a fixed clock and no network.
- `test/data/migration_test.dart` upgrades a real version-1 database.
- `integration_test/app_screenshots_test.dart` runs the real app on a simulator and saves screenshots.
- CI (`.github/workflows/ci.yaml`) checks generated code, formatting, `flutter analyze`, all tests and an
  Android build on every push.
