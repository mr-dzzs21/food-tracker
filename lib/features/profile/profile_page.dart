import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/format.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/eating_disorder_help.dart';
import '../../core/widgets/section_header.dart';
import '../../data/database.dart';
import '../../data/settings_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../router.dart';
import '../diary/diary_repository.dart';
import '../goals/goals_repository.dart';
import '../products/nutrient_format.dart';
import '../products/nutrients.dart';

/// Tab "Profil": daily goal and all settings.
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final themeMode = ref.watch(themeModeProvider).value ?? ThemeMode.system;
    final language = _LanguageChoice.of(ref.watch(localeProvider).value);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabProfile)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: Spacing.xl),
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(Spacing.l, Spacing.s, Spacing.l, 0),
            child: _GoalSummaryCard(),
          ),
          SectionHeader(l10n.profileSettingsTitle),
          ListTile(
            leading: const Icon(Icons.restaurant_outlined),
            title: Text(l10n.mealsTitle),
            subtitle: Text(l10n.mealsSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Routes.meals),
          ),
          ListTile(
            leading: const Icon(Icons.kitchen_outlined),
            title: Text(l10n.myFoodsTitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Routes.myFoods),
          ),
          ListTile(
            leading: const Icon(Icons.brightness_6_outlined),
            title: Text(l10n.profileTheme),
            subtitle: Text(_themeLabel(themeMode, l10n)),
            onTap: () => _chooseTheme(context, ref, themeMode),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.profileLanguage),
            subtitle: Text(language.label(l10n)),
            onTap: () => _chooseLanguage(context, ref, language),
          ),
          SectionHeader(l10n.profileInfoTitle),
          ListTile(
            leading: const Icon(Icons.support_outlined),
            title: Text(l10n.helpEdTitle),
            onTap: () => showEatingDisorderHelp(context),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.profileAbout),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Routes.about),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever_outlined),
            title: Text(l10n.profileDeleteAll),
            onTap: () => _deleteAllData(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _chooseTheme(
    BuildContext context,
    WidgetRef ref,
    ThemeMode current,
  ) async {
    final l10n = AppLocalizations.of(context);
    final chosen = await _showChoiceDialog(
      context,
      title: l10n.profileTheme,
      current: current,
      options: {
        for (final mode in ThemeMode.values) mode: _themeLabel(mode, l10n),
      },
    );
    if (chosen != null) await ref.read(themeModeProvider.notifier).set(chosen);
  }

  Future<void> _chooseLanguage(
    BuildContext context,
    WidgetRef ref,
    _LanguageChoice current,
  ) async {
    final l10n = AppLocalizations.of(context);
    final chosen = await _showChoiceDialog(
      context,
      title: l10n.profileLanguage,
      current: current,
      options: {
        for (final choice in _LanguageChoice.values) choice: choice.label(l10n),
      },
    );
    // The app watches the setting, so all texts switch at once.
    if (chosen != null) {
      await ref.read(localeProvider.notifier).set(chosen.locale);
    }
  }

  Future<void> _deleteAllData(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.profileDeleteAllTitle),
        content: Text(l10n.profileDeleteAllText),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.profileDeleteAllConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    // Read before the settings are cleared (the language may change).
    final done = l10n.profileDeleteAllDone;
    // Diary, foods and goal go; the four default meals come back.
    await ref.read(databaseProvider).deleteAllData();
    if (!context.mounted) return;
    // Theme, language and the hidden "Ziel festlegen" card are reset too.
    await clearAllSettings(ref);
    if (!context.mounted) return;
    ref.invalidate(selectedDayProvider);
    messenger.showSnackBar(SnackBar(content: Text(done)));
  }
}

String _themeLabel(ThemeMode mode, AppLocalizations l10n) => switch (mode) {
  ThemeMode.system => l10n.settingSystem,
  ThemeMode.light => l10n.themeLight,
  ThemeMode.dark => l10n.themeDark,
};

/// The three choices on "Sprache". An enum instead of `Locale?`, because
/// `null` ("follow the system") cannot be a value of a radio button.
enum _LanguageChoice {
  system(null),
  german(Locale('de')),
  english(Locale('en'));

  const _LanguageChoice(this.locale);
  final Locale? locale;

  static _LanguageChoice of(Locale? locale) => switch (locale?.languageCode) {
    'de' => german,
    'en' => english,
    _ => system,
  };

  String label(AppLocalizations l10n) => switch (this) {
    system => l10n.settingSystem,
    german => l10n.languageGerman,
    english => l10n.languageEnglish,
  };
}

/// A dialog with one radio button per option. Choosing one closes it and
/// returns that value; "Abbrechen" returns `null`.
Future<T?> _showChoiceDialog<T extends Object>(
  BuildContext context, {
  required String title,
  required T current,
  required Map<T, String> options,
}) {
  return showDialog<T>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      contentPadding: const EdgeInsets.symmetric(vertical: Spacing.m),
      content: SingleChildScrollView(
        child: RadioGroup<T>(
          groupValue: current,
          onChanged: (value) => Navigator.of(context).pop(value),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final MapEntry(key: value, value: label) in options.entries)
                RadioListTile<T>(value: value, title: Text(label)),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context).actionCancel),
        ),
      ],
    ),
  );
}

/// "Dein Tagesziel": kcal and macros, or "Noch kein Ziel".
class _GoalSummaryCard extends ConsumerWidget {
  const _GoalSummaryCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = l10n.localeName;
    final goal = ref.watch(goalProvider).value;
    final macros = goal == null ? '' : _macroText(goal, l10n);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(
                l10n.profileGoalTitle,
                style: theme.textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: Spacing.s),
            if (goal == null) ...[
              Text(l10n.profileGoalNone, style: theme.textTheme.headlineSmall),
              const SizedBox(height: Spacing.xs),
              Text(
                l10n.profileGoalNoneText,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ] else ...[
              Text(
                l10n.profileGoalKcal(formatKcal(goal.kcal.toDouble(), locale)),
                style: theme.textTheme.headlineSmall,
              ),
              if (macros.isNotEmpty) ...[
                const SizedBox(height: Spacing.xs),
                Text(macros, style: theme.textTheme.bodyMedium),
              ],
            ],
            const SizedBox(height: Spacing.m),
            FilledButton.tonal(
              onPressed: () => context.push(Routes.goal),
              child: Text(
                goal == null ? l10n.profileGoalSet : l10n.profileGoalChange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Eiweiß: 64 g · Kohlenhydrate: 338 g · Fett: 77 g" (only the set ones).
String _macroText(UserGoalRow goal, AppLocalizations l10n) => [
  for (final (nutrient, grams) in [
    (Nutrient.protein, goal.protein),
    (Nutrient.carbs, goal.carbs),
    (Nutrient.fat, goal.fat),
  ])
    if (grams != null)
      l10n.nutrientWithValue(
        nutrientName(nutrient, l10n),
        l10n.unitGrams(formatGrams(grams, l10n.localeName)),
      ),
].join(' · ');
