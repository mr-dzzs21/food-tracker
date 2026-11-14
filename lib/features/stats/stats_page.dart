import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/clock.dart';
import '../../core/format.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/status_view.dart';
import '../../l10n/app_localizations.dart';
import '../diary/total_text.dart';
import '../goals/goals_repository.dart';
import '../products/nutrient_format.dart';
import '../products/nutrients.dart';
import 'stats_providers.dart';
import 'week_stats.dart';
import 'week_title.dart';
import 'widgets/week_bars.dart';

/// Tab "Statistik": kcal per day of one week, averages and how many days
/// have entries. ‹ › switch weeks; there are no future weeks.
class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final monday = ref.watch(selectedWeekProvider);
    final stats = ref.watch(weekStatsProvider(monday));
    final goal = ref.watch(goalProvider);

    return Scaffold(
      appBar: _WeekSwitcherBar(monday: monday),
      body: switch ((stats, goal)) {
        (AsyncData(value: final stats), AsyncData(value: final goal)) =>
          stats.isEmpty
              ? StatusView(
                  icon: Icons.bar_chart_outlined,
                  title: l10n.statsEmptyTitle,
                  message: l10n.statsEmptyText,
                )
              : _StatsContent(stats: stats, goalKcal: goal?.kcal),
        (AsyncError(), _) || (_, AsyncError()) => StatusView(
          icon: Icons.error_outline,
          title: l10n.errorGeneric,
          actionLabel: l10n.actionRetry,
          onAction: () => ref
            ..invalidate(weekStatsProvider(monday))
            ..invalidate(goalProvider),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

/// App bar with ‹ "Diese Woche" ›, like the date switcher on "Heute".
class _WeekSwitcherBar extends ConsumerWidget implements PreferredSizeWidget {
  const _WeekSwitcherBar({required this.monday});

  final String monday;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final current = currentMonday(ref.watch(clockProvider));
    final notifier = ref.read(selectedWeekProvider.notifier);
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.chevron_left),
        tooltip: l10n.statsPreviousWeek,
        onPressed: notifier.previous,
      ),
      titleSpacing: 0,
      title: Text(
        weekTitle(monday, current: current, l10n: l10n),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.chevron_right),
          tooltip: l10n.statsNextWeek,
          // The current week is the last one: the future has no entries.
          onPressed: monday == current ? null : notifier.next,
        ),
      ],
    );
  }
}

class _StatsContent extends ConsumerWidget {
  const _StatsContent({required this.stats, required this.goalKcal});

  final WeekStats stats;
  final int? goalKcal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final goal = goalKcal;
    final averageKcal = _averageText(stats, Nutrient.kcal, l10n);

    return ListView(
      padding: const EdgeInsets.all(Spacing.l),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.statsChartTitle, style: theme.textTheme.titleMedium),
                const SizedBox(height: Spacing.l),
                WeekBars(
                  stats: stats,
                  goalKcal: goal,
                  today: todayKey(ref.watch(clockProvider)),
                ),
                if (goal != null) ...[
                  const SizedBox(height: Spacing.m),
                  Text(
                    l10n.statsGoalLine(
                      formatKcal(goal.toDouble(), l10n.localeName),
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: Spacing.m),
        // Both tiles get the height of the taller one (large text sizes).
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _StatTile(
                  title: l10n.statsAverageKcalTitle,
                  value: averageKcal,
                  semanticsLabel: l10n.statsAverageKcalSemantics(averageKcal),
                ),
              ),
              const SizedBox(width: Spacing.m),
              Expanded(
                child: _StatTile(
                  title: l10n.statsDaysLoggedTitle,
                  value: l10n.statsDaysLoggedValue('${stats.daysLogged}'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.m),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.l),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.statsAverageMacrosTitle,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: Spacing.s),
                for (final (nutrient, color) in [
                  (Nutrient.protein, context.appColors.protein),
                  (Nutrient.carbs, context.appColors.carbs),
                  (Nutrient.fat, context.appColors.fat),
                ])
                  _MacroAverageRow(
                    name: nutrientName(nutrient, l10n),
                    value: l10n.unitGrams(_averageText(stats, nutrient, l10n)),
                    color: color,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: Spacing.m),
        Text(
          l10n.statsAverageNote,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// "1.850", "mind. 1.850" or "–" for the average of [nutrient].
String _averageText(WeekStats stats, Nutrient nutrient, AppLocalizations l10n) {
  final average = stats.average(nutrient);
  if (average == null) return '–';
  return boundedNumberText(
    nutrient,
    average,
    stats.averageState(nutrient),
    l10n,
  );
}

/// A card with a small title and a big value ("Tage mit Einträgen", "3 von 7").
class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.title,
    required this.value,
    this.semanticsLabel,
  });

  final String title;
  final String value;

  /// Read instead of "title value" when the title has a symbol such as Ø.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label:
          semanticsLabel ??
          AppLocalizations.of(context).nutrientWithValue(title, value),
      container: true,
      excludeSemantics: true,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One macro with its colour dot: "● Eiweiß ........ 85 g".
class _MacroAverageRow extends StatelessWidget {
  const _MacroAverageRow({
    required this.name,
    required this.value,
    required this.color,
  });

  final String name;
  final String value;
  final Color color;

  /// Same size as the text, so the dot never looks lost at large text.
  static const double _dotSize = 12;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Semantics(
      label: l10n.statsAverageMacroSemantics(name, value),
      container: true,
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
        child: Row(
          children: [
            Container(
              width: _dotSize,
              height: _dotSize,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: Spacing.s),
            Expanded(child: Text(name, style: theme.textTheme.bodyLarge)),
            const SizedBox(width: Spacing.s),
            Text(
              value,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
