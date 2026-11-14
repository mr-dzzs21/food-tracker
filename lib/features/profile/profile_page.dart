import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/format.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/card_list.dart';
import '../../core/widgets/dialogs.dart';
import '../../core/widgets/eating_disorder_help.dart';
import '../../core/widgets/icon_square.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/section_header.dart';
import '../../data/database.dart';
import '../../data/settings_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../router.dart';
import '../diary/diary_repository.dart';
import '../goals/goals_repository.dart';
import '../products/nutrient_format.dart';
import '../products/nutrients.dart';
import '../stats/stats_providers.dart';

/// Tab "Profil": daily goal and all settings.
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final themeMode = ref.watch(themeModeProvider).value ?? ThemeMode.system;
    final language = _LanguageChoice.of(ref.watch(localeProvider).value);

    final colors = context.appColors;
    final palettes = colors.mealPalettes;
    // A tinted icon square per row, in the colours of the meal cards.
    Widget icon(IconData icon, MealPalette palette) => IconSquare(
      icon: icon,
      background: palette.background,
      foreground: palette.icon,
    );

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.only(bottom: Spacing.xl),
        children: [
          PageHeader(title: l10n.tabProfile, large: true),
          const _GoalCard(),
          SectionHeader(l10n.profileSettingsTitle),
          _Group(
            children: [
              CardRow(
                leading: icon(Icons.restaurant_rounded, palettes[0]),
                title: l10n.mealsTitle,
                subtitle: l10n.mealsSubtitle,
                onTap: () => context.push(Routes.meals),
              ),
              CardRow(
                leading: icon(Icons.kitchen_rounded, palettes[1]),
                title: l10n.myFoodsTitle,
                onTap: () => context.push(Routes.myFoods),
              ),
              CardRow(
                leading: icon(Icons.dark_mode_rounded, palettes[2]),
                title: l10n.profileTheme,
                subtitle: _themeLabel(themeMode, l10n),
                onTap: () => _chooseTheme(context, ref, themeMode),
              ),
              CardRow(
                leading: icon(Icons.language_rounded, palettes[4]),
                title: l10n.profileLanguage,
                subtitle: language.label(l10n),
                onTap: () => _chooseLanguage(context, ref, language),
              ),
            ],
          ),
          SectionHeader(l10n.profileInfoTitle),
          _Group(
            children: [
              CardRow(
                leading: icon(Icons.support_rounded, palettes[5]),
                title: l10n.helpEdTitle,
                onTap: () => showEatingDisorderHelp(context),
              ),
              CardRow(
                leading: icon(Icons.info_rounded, palettes[3]),
                title: l10n.profileAbout,
                onTap: () => context.push(Routes.about),
              ),
              // In the "hoch" rating colours: it cannot be undone.
              CardRow(
                leading: IconSquare(
                  icon: Icons.delete_forever_rounded,
                  background: colors.ratingHighBg,
                  foreground: colors.ratingHigh,
                ),
                title: l10n.profileDeleteAll,
                titleColor: colors.ratingHigh,
                showChevron: false,
                onTap: () => _deleteAllData(context, ref),
              ),
            ],
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
    final chosen = await showChoiceSheet(
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
    final chosen = await showChoiceSheet(
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
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.profileDeleteAllTitle,
      message: l10n.profileDeleteAllText,
      confirmLabel: l10n.profileDeleteAllConfirm,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    // Read before the settings are cleared (the language may change).
    final done = l10n.profileDeleteAllDone;
    // Diary, foods and goal go; the four default meals come back.
    await ref.read(databaseProvider).deleteAllData();
    if (!context.mounted) return;
    // Theme, language and the hidden "Ziel festlegen" card are reset too.
    await clearAllSettings(ref);
    if (!context.mounted) return;
    ref
      ..invalidate(selectedDayProvider)
      ..invalidate(selectedWeekProvider);
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

/// A [CardGroup] with the page's side padding.
class _Group extends StatelessWidget {
  const _Group({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: Spacing.l),
    child: CardGroup(children: children),
  );
}

/// The summary card: "Dein Tagesziel" with the big kcal number and the
/// macros, or "Noch kein Ziel"; a tonal button opens the goal page.
class _GoalCard extends ConsumerWidget {
  const _GoalCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = l10n.localeName;
    final goal = ref.watch(goalProvider).value;
    final macros = goal == null ? '' : _macroText(goal, l10n);

    return Padding(
      padding: const EdgeInsets.fromLTRB(Spacing.l, Spacing.s, Spacing.l, 0),
      child: SummaryCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(
                l10n.profileGoalTitle,
                style: PageHeader.overlineStyle(context),
              ),
            ),
            const SizedBox(height: Spacing.xs),
            if (goal == null) ...[
              Text(l10n.profileGoalNone, style: theme.textTheme.headlineSmall),
              const SizedBox(height: Spacing.xs),
              Text(l10n.profileGoalNoneText, style: theme.textTheme.bodySmall),
            ] else ...[
              Text(
                l10n.profileGoalKcal(formatKcal(goal.kcal.toDouble(), locale)),
                style: theme.textTheme.headlineMedium,
              ),
              if (macros.isNotEmpty) ...[
                const SizedBox(height: Spacing.xs),
                Text(macros, style: theme.textTheme.bodySmall),
              ],
            ],
            const SizedBox(height: Spacing.m),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TonalButton(
                icon: goal == null ? Icons.flag_rounded : Icons.tune_rounded,
                onPressed: () => context.push(Routes.goal),
                label: goal == null
                    ? l10n.profileGoalSet
                    : l10n.profileGoalChange,
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
