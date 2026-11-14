import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Small user settings (theme, language, a dismissed hint) are stored as
// key/value pairs on the device with shared_preferences. Everything bigger
// lives in the drift database.

/// Gives access to the key/value store. Tests can override it.
final sharedPreferencesProvider = Provider<SharedPreferencesAsync>(
  (ref) => SharedPreferencesAsync(),
);

/// Light, dark or follow the system. Default: follow the system.
class ThemeModeSetting extends AsyncNotifier<ThemeMode> {
  static const _key = 'theme_mode';

  @override
  Future<ThemeMode> build() async {
    final name = await ref.read(sharedPreferencesProvider).getString(_key);
    return ThemeMode.values.asNameMap()[name] ?? ThemeMode.system;
  }

  Future<void> set(ThemeMode mode) async {
    state = AsyncData(mode);
    await ref.read(sharedPreferencesProvider).setString(_key, mode.name);
  }
}

final themeModeProvider = AsyncNotifierProvider<ThemeModeSetting, ThemeMode>(
  ThemeModeSetting.new,
);

/// The app language: `null` = follow the device, otherwise `de` or `en`.
class LocaleSetting extends AsyncNotifier<Locale?> {
  static const _key = 'locale';

  /// Languages the app is translated into.
  static const supported = ['de', 'en'];

  @override
  Future<Locale?> build() async {
    final code = await ref.read(sharedPreferencesProvider).getString(_key);
    return supported.contains(code) ? Locale(code!) : null;
  }

  Future<void> set(Locale? locale) async {
    state = AsyncData(locale);
    final prefs = ref.read(sharedPreferencesProvider);
    if (locale == null) {
      await prefs.remove(_key);
    } else {
      await prefs.setString(_key, locale.languageCode);
    }
  }
}

final localeProvider = AsyncNotifierProvider<LocaleSetting, Locale?>(
  LocaleSetting.new,
);

/// Whether the user closed the "Ziel festlegen" card on the Today screen.
class GoalCardDismissed extends AsyncNotifier<bool> {
  static const _key = 'goal_card_dismissed';

  @override
  Future<bool> build() async =>
      await ref.read(sharedPreferencesProvider).getBool(_key) ?? false;

  Future<void> dismiss() async {
    state = const AsyncData(true);
    await ref.read(sharedPreferencesProvider).setBool(_key, true);
  }

  /// Shows the card again (used by "Alle Daten löschen").
  Future<void> reset() async {
    state = const AsyncData(false);
    await ref.read(sharedPreferencesProvider).remove(_key);
  }
}

final goalCardDismissedProvider =
    AsyncNotifierProvider<GoalCardDismissed, bool>(GoalCardDismissed.new);

/// Removes every stored setting (used by "Alle Daten löschen").
Future<void> clearAllSettings(WidgetRef ref) async {
  await ref.read(sharedPreferencesProvider).clear();
  ref
    ..invalidate(themeModeProvider)
    ..invalidate(localeProvider)
    ..invalidate(goalCardDismissedProvider);
}
