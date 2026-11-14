import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'core/theme/app_theme.dart';
import 'data/settings_repository.dart';
import 'l10n/app_localizations.dart';
import 'router.dart';

/// The root widget: theme, language and navigation.
class FoodTrackerApp extends ConsumerWidget {
  const FoodTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // While the settings are still loading, follow the system.
    final themeMode = ref.watch(themeModeProvider).value ?? ThemeMode.system;
    final locale = ref.watch(localeProvider).value;

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      routerConfig: ref.watch(routerProvider),
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: themeMode,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      // Use the delegates from material_ui, not the generated
      // `AppLocalizations.localizationsDelegates` (those point to the old
      // built-in Material library and break German texts in dialogs).
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
    );
  }
}
