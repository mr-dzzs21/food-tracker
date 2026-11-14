import 'package:clock/clock.dart';
import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// `Override` (the type of provider overrides) lives in misc.dart in Riverpod 3.
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:food_tracker/app.dart';
import 'package:food_tracker/core/app_info.dart';
import 'package:food_tracker/core/clock.dart';
import 'package:food_tracker/core/theme/app_theme.dart';
import 'package:food_tracker/data/database.dart';
import 'package:food_tracker/data/settings_repository.dart';
import 'package:food_tracker/l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

/// "Now" in every test: Saturday, 14 November 2026, 12:00 local time.
final testNow = DateTime(2026, 11, 14, 12);

/// A fresh in-memory database (with the four default meals).
///
/// `closeStreamsSynchronously` stops drift's watch queries at once when the
/// last listener leaves. By default drift waits one event-loop turn with a
/// timer, and widget tests fail on timers that are still pending at the end.
AppDatabase newTestDatabase() => AppDatabase(
  DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true),
);

/// An HTTP client that fails every request, so no test talks to the internet
/// by accident. Pass your own `MockClient` to simulate Open Food Facts.
http.Client offlineClient() =>
    MockClient((_) async => throw http.ClientException('no network in tests'));

/// Uses an empty in-memory store for shared_preferences.
void useInMemoryPreferences() {
  SharedPreferencesAsyncPlatform.instance =
      InMemorySharedPreferencesAsync.empty();
}

/// The standard overrides for widget and provider tests.
List<Override> testOverrides({
  required AppDatabase db,
  http.Client? client,
  DateTime? now,
}) {
  useInMemoryPreferences();
  return [
    databaseProvider.overrideWithValue(db),
    httpClientProvider.overrideWithValue(client ?? offlineClient()),
    clockProvider.overrideWithValue(Clock.fixed(now ?? testNow)),
    sharedPreferencesProvider.overrideWithValue(SharedPreferencesAsync()),
    appVersionProvider.overrideWithValue('0.1.0-test'),
  ];
}

/// Starts the whole app (router, tabs, theme) with test dependencies.
Future<void> pumpFoodTrackerApp(
  WidgetTester tester, {
  required AppDatabase db,
  http.Client? client,
  DateTime? now,
  Locale locale = const Locale('de'),
  List<Override> extraOverrides = const [],
}) async {
  final overrides = testOverrides(db: db, client: client, now: now);
  // The app reads its language from the settings, so store it there.
  await SharedPreferencesAsync().setString('locale', locale.languageCode);
  await tester.pumpWidget(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [...overrides, ...extraOverrides],
      child: const FoodTrackerApp(),
    ),
  );
  await tester.pumpAndSettle();
}

/// Shows a single [child] widget inside a themed, localised app, with the
/// standard test overrides. Use it for testing one screen or widget.
Future<void> pumpWidgetInApp(
  WidgetTester tester,
  Widget child, {
  required AppDatabase db,
  http.Client? client,
  DateTime? now,
  Locale locale = const Locale('de'),
  Brightness brightness = Brightness.light,
  List<Override> extraOverrides = const [],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [
        ...testOverrides(db: db, client: client, now: now),
        ...extraOverrides,
      ],
      child: MaterialApp(
        theme: buildTheme(brightness),
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        home: child,
      ),
    ),
  );
  await tester.pumpAndSettle();
}
