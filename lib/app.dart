import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'core/clock.dart';
import 'core/theme/app_theme.dart';
import 'data/settings_repository.dart';
import 'l10n/app_localizations.dart';
import 'router.dart';

/// The root widget: theme, language and navigation.
class FoodTrackerApp extends ConsumerStatefulWidget {
  const FoodTrackerApp({super.key});

  @override
  ConsumerState<FoodTrackerApp> createState() => _FoodTrackerAppState();
}

class _FoodTrackerAppState extends ConsumerState<FoodTrackerApp> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // Back in the foreground – maybe on a new day: "Heute" moves on.
    _lifecycle = AppLifecycleListener(
      onResume: () => ref.read(todayProvider.notifier).refresh(),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
