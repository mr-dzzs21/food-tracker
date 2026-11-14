import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/clock.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/hero_header.dart';
import '../../core/widgets/status_view.dart';
import '../../data/database.dart';
import '../../data/settings_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../router.dart';
import '../goals/goals_repository.dart';
import '../products/nutrients.dart';
import 'day_label.dart';
import 'diary_repository.dart';
import 'total_text.dart';
import 'widgets/calorie_ring.dart';
import 'widgets/goal_prompt.dart';
import 'widgets/macro_bars.dart';
import 'widgets/meal_sheet.dart';
import 'widgets/meal_tile.dart';

/// Tab "Heute": green hero with date, calorie ring and macros, below it one
/// colourful tile per meal. Tapping a tile opens its entries in a sheet.
class TodayPage extends ConsumerWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final day = ref.watch(selectedDayProvider);
    final entries = ref.watch(dayEntriesProvider(day));
    final slots = ref.watch(mealSlotsProvider);
    final goal = ref.watch(goalProvider);

    return Scaffold(
      body: switch ((entries, slots, goal)) {
        (
          AsyncData(value: final entries),
          AsyncData(value: final slots),
          AsyncData(value: final goal),
        ) =>
          _TodayContent(day: day, entries: entries, slots: slots, goal: goal),
        (AsyncError(), _, _) ||
        (_, AsyncError(), _) ||
        (_, _, AsyncError()) => _HeroOnly(
          day: day,
          child: StatusView(
            icon: Icons.error_outline_rounded,
            title: AppLocalizations.of(context).errorGeneric,
            actionLabel: AppLocalizations.of(context).actionRetry,
            onAction: () => ref
              ..invalidate(dayEntriesProvider(day))
              ..invalidate(mealSlotsProvider)
              ..invalidate(goalProvider),
          ),
        ),
        _ => _HeroOnly(
          day: day,
          child: const Padding(
            padding: EdgeInsets.all(Spacing.xxl),
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      },
    );
  }
}

/// While loading or after an error: the hero with the date, then [child].
class _HeroOnly extends StatelessWidget {
  const _HeroOnly({required this.day, required this.child});

  final String day;
  final Widget child;

  @override
  Widget build(BuildContext context) => ListView(
    padding: EdgeInsets.zero,
    children: [
      HeroHeader(
        top: _DateSwitcher(day: day),
        child: const SizedBox.shrink(),
      ),
      child,
    ],
  );
}

/// ‹ "Heute, 14. Nov." › on the hero. Tapping the title opens a date picker;
/// the "Heute" pill jumps back when another day is shown.
class _DateSwitcher extends ConsumerWidget {
  const _DateSwitcher({required this.day});

  final String day;

  Future<void> _pickDay(BuildContext context, WidgetRef ref) async {
    final now = ref.read(clockProvider).now();
    final picked = await showDatePicker(
      context: context,
      initialDate: parseDayKey(day),
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 1, 12, 31),
    );
    if (picked != null && context.mounted) {
      ref.read(selectedDayProvider.notifier).set(dayKeyOf(picked));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final today = todayKey(ref.watch(clockProvider));
    final notifier = ref.read(selectedDayProvider.notifier);
    return Row(
      children: [
        SquareIconButton(
          icon: Icons.chevron_left_rounded,
          tooltip: l10n.dayPrevious,
          onHero: true,
          onPressed: notifier.previous,
        ),
        Expanded(
          child: Tooltip(
            message: l10n.dayPick,
            child: TextButton(
              onPressed: () => _pickDay(context, ref),
              style: TextButton.styleFrom(foregroundColor: colors.onHero),
              child: Text(
                dayLabel(day, today: today, l10n: l10n),
                style: Theme.of(context).textTheme.titleLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        if (day != today)
          HeroPill(label: l10n.dayJumpToday, onPressed: notifier.today),
        SquareIconButton(
          icon: Icons.chevron_right_rounded,
          tooltip: l10n.dayNext,
          onHero: true,
          onPressed: notifier.next,
        ),
      ],
    );
  }
}

class _TodayContent extends ConsumerWidget {
  const _TodayContent({
    required this.day,
    required this.entries,
    required this.slots,
    required this.goal,
  });

  final String day;
  final List<DayEntry> entries;
  final List<MealSlot> slots;
  final UserGoalRow? goal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final totals = DayTotals.of(entries);
    final showGoalPrompt =
        goal == null && ref.watch(goalCardDismissedProvider).value == false;

    // Visible meals, plus hidden meals that have entries on this day.
    final slotIdsWithEntries = {for (final item in entries) item.slot.id};
    final shownSlots = [
      for (final slot in slots)
        if (!slot.isHidden || slotIdsWithEntries.contains(slot.id)) slot,
    ];

    return ListView(
      padding: const EdgeInsets.only(bottom: Spacing.xxl),
      children: [
        HeroHeader(
          top: _DateSwitcher(day: day),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: Spacing.m),
              _DaySummary(totals: totals.all, goal: goal),
              if (showGoalPrompt) ...[
                const SizedBox(height: Spacing.l),
                GoalPrompt(
                  onSetGoal: () => context.go(Routes.goal),
                  onDismiss: () =>
                      ref.read(goalCardDismissedProvider.notifier).dismiss(),
                ),
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.l,
            Spacing.l,
            Spacing.l,
            0,
          ),
          child: _MealGrid(
            slots: shownSlots,
            entries: entries,
            totals: totals,
            onOpen: (slot) => showMealSheet(
              context,
              day: day,
              slot: slot,
              onAdd: () => context.push(Routes.addFood(day, slot.id)),
            ),
            onAdd: (slot) => context.push(Routes.addFood(day, slot.id)),
          ),
        ),
        if (entries.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.xl,
              Spacing.xl,
              Spacing.xl,
              0,
            ),
            child: Text(
              l10n.todayEmptyDay,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ),
      ],
    );
  }
}

/// Ring, "Gegessen: …" and the macro pills. Side by side on a normal phone;
/// stacked when the space is narrow or the text is very large.
class _DaySummary extends StatelessWidget {
  const _DaySummary({required this.totals, required this.goal});

  final NutrientTotals totals;
  final UserGoalRow? goal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final style = Theme.of(context).textTheme.labelMedium!
        .copyWith(color: colors.onHero);
    final goal = this.goal;
    final missingKcal = totals[Nutrient.kcal].missingCount;

    final ring = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CalorieRing(totals: totals, goalKcal: goal?.kcal),
        if (goal != null) ...[
          const SizedBox(height: Spacing.s),
          Text(
            l10n.todayEatenLine(totalText(totals, Nutrient.kcal, l10n)),
            style: style,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
    final macros = MacroBars(totals: totals, goal: goal);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final stacked =
                constraints.maxWidth < 300 ||
                MediaQuery.textScalerOf(context).scale(1) > 1.5;
            if (stacked) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(child: ring),
                  const SizedBox(height: Spacing.l),
                  macros,
                ],
              );
            }
            return Row(
              children: [
                ring,
                const SizedBox(width: 18),
                Expanded(child: macros),
              ],
            );
          },
        ),
        if (missingKcal > 0) ...[
          const SizedBox(height: Spacing.m),
          Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 18, color: colors.onHero),
              const SizedBox(width: Spacing.xs),
              Flexible(
                child: Text(l10n.todayMissingValues(missingKcal), style: style),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// The meal tiles in two columns (one column with very large text).
class _MealGrid extends StatelessWidget {
  const _MealGrid({
    required this.slots,
    required this.entries,
    required this.totals,
    required this.onOpen,
    required this.onAdd,
  });

  final List<MealSlot> slots;
  final List<DayEntry> entries;
  final DayTotals totals;
  final ValueChanged<MealSlot> onOpen;
  final ValueChanged<MealSlot> onAdd;

  @override
  Widget build(BuildContext context) {
    final columns = MediaQuery.textScalerOf(context).scale(1) > 1.5 ? 1 : 2;
    Widget tile(MealSlot slot) => MealTile(
      slot: slot,
      entryCount: entries.where((item) => item.slot.id == slot.id).length,
      totals: totals.forMeal(slot.id),
      onOpen: () => onOpen(slot),
      onAdd: () => onAdd(slot),
    );

    return Column(
      children: [
        for (var start = 0; start < slots.length; start += columns) ...[
          if (start > 0) const SizedBox(height: Spacing.m),
          // Same height for both tiles of a row, whatever their texts need.
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = start; i < start + columns; i++) ...[
                  if (i > start) const SizedBox(width: Spacing.m),
                  Expanded(
                    child: i < slots.length
                        ? tile(slots[i])
                        : const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}
