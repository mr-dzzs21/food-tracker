import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/clock.dart';
import '../../core/format.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/status_view.dart';
import '../../data/database.dart';
import '../../data/settings_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../router.dart';
import '../goals/goals_repository.dart';
import '../products/nutrients.dart';
import 'diary_repository.dart';
import 'total_text.dart';
import 'widgets/calorie_ring.dart';
import 'widgets/goal_prompt.dart';
import 'widgets/macro_bars.dart';
import 'widgets/meal_card.dart';
import 'widgets/meal_sheet.dart';

/// Tab "Heute": weekday and date with ‹ ›, the summary card (calorie ring
/// and macro bars), below it one white card per meal. Tapping a card opens
/// its entries in a sheet.
class TodayPage extends ConsumerWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final day = ref.watch(selectedDayProvider);
    final entries = ref.watch(dayEntriesProvider(day));
    final slots = ref.watch(mealSlotsProvider);
    final goal = ref.watch(goalProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: switch ((entries, slots, goal)) {
          (
            AsyncData(value: final entries),
            AsyncData(value: final slots),
            AsyncData(value: final goal),
          ) =>
            _TodayContent(day: day, entries: entries, slots: slots, goal: goal),
          (AsyncError(), _, _) ||
          (_, AsyncError(), _) ||
          (_, _, AsyncError()) => _HeaderOnly(
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
          _ => _HeaderOnly(
            day: day,
            child: const Padding(
              padding: EdgeInsets.all(Spacing.xxl),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
        },
      ),
    );
  }
}

/// While loading or after an error: the date header, then [child].
class _HeaderOnly extends StatelessWidget {
  const _HeaderOnly({required this.day, required this.child});

  final String day;
  final Widget child;

  @override
  Widget build(BuildContext context) => ListView(
    padding: EdgeInsets.zero,
    children: [
      _DayHeader(day: day),
      child,
    ],
  );
}

/// "SAMSTAG" over "14. November" (+ a "Heute" pill) and ‹ ›. Tapping the
/// date opens a date picker; on another day the "Heute" pill is a button
/// that jumps back.
class _DayHeader extends ConsumerWidget {
  const _DayHeader({required this.day});

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
    final locale = l10n.localeName;
    final date = parseDayKey(day);
    final isToday = day == todayKey(ref.watch(clockProvider));
    final notifier = ref.read(selectedDayProvider.notifier);
    final pillStyle = Theme.of(context).textTheme.labelMedium!
        .copyWith(color: colors.onTonal, fontWeight: FontWeight.w800);
    const pillPadding = EdgeInsets.symmetric(horizontal: 10, vertical: 4);

    return PageHeader(
      overline: DateFormat.EEEE(locale).format(date),
      // Wrap: with large text the pill moves below the date.
      titleWidget: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: Spacing.s,
        children: [
          Tooltip(
            message: l10n.dayPick,
            child: InkWell(
              onTap: () => _pickDay(context, ref),
              borderRadius: BorderRadius.circular(Radii.s),
              child: Text(
                DateFormat.MMMMd(locale).format(date),
                style: PageHeader.titleStyle(context, large: true),
              ),
            ),
          ),
          if (isToday)
            Container(
              padding: pillPadding,
              decoration: ShapeDecoration(
                color: colors.tonal,
                shape: const StadiumBorder(),
              ),
              child: Text(l10n.dayTodayBadge, style: pillStyle),
            )
          else
            TextButton(
              onPressed: notifier.today,
              style: TextButton.styleFrom(
                backgroundColor: colors.tonal,
                foregroundColor: colors.onTonal,
                textStyle: pillStyle,
                minimumSize: const Size(48, 28),
                padding: pillPadding,
                tapTargetSize: MaterialTapTargetSize.padded,
                shape: const StadiumBorder(),
              ),
              child: Text(l10n.dayJumpToday),
            ),
        ],
      ),
      actions: [
        RoundIconButton(
          icon: Icons.chevron_left_rounded,
          tooltip: l10n.dayPrevious,
          onPressed: notifier.previous,
        ),
        RoundIconButton(
          icon: Icons.chevron_right_rounded,
          tooltip: l10n.dayNext,
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
    final colors = context.appColors;
    final totals = DayTotals.of(entries);
    final goal = this.goal;
    final showGoalPrompt =
        goal == null && ref.watch(goalCardDismissedProvider).value == false;
    final missingKcal = totals.all[Nutrient.kcal].missingCount;
    final smallStyle = theme.textTheme.labelMedium!.copyWith(
      color: colors.inkMuted,
      fontWeight: FontWeight.w600,
    );

    // Visible meals, plus hidden meals that have entries on this day.
    final slotIdsWithEntries = {for (final item in entries) item.slot.id};
    final shownSlots = [
      for (final slot in slots)
        if (!slot.isHidden || slotIdsWithEntries.contains(slot.id)) slot,
    ];

    return ListView(
      padding: const EdgeInsets.only(bottom: Spacing.xl),
      children: [
        _DayHeader(day: day),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.l,
            Spacing.s,
            Spacing.l,
            0,
          ),
          child: SummaryCard(
            child: _DaySummary(totals: totals.all, goal: goal),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.page,
            Spacing.m,
            Spacing.page,
            0,
          ),
          child: Text(
            goal == null
                ? l10n.todayReferenceNote
                : l10n.todayEatenGoalLine(
                    totalText(totals.all, Nutrient.kcal, l10n),
                    formatKcal(goal.kcal.toDouble(), l10n.localeName),
                  ),
            style: smallStyle,
          ),
        ),
        if (missingKcal > 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.page,
              Spacing.xs,
              Spacing.page,
              0,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: colors.inkMuted,
                ),
                const SizedBox(width: Spacing.xs),
                Flexible(
                  child: Text(
                    l10n.todayMissingValues(missingKcal),
                    style: smallStyle,
                  ),
                ),
              ],
            ),
          ),
        if (showGoalPrompt)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.l,
              Spacing.m,
              Spacing.l,
              0,
            ),
            child: GoalPrompt(
              onSetGoal: () => context.go(Routes.goal),
              onDismiss: () =>
                  ref.read(goalCardDismissedProvider.notifier).dismiss(),
            ),
          ),
        const SizedBox(height: Spacing.xs),
        for (final slot in shownSlots)
          Padding(
            padding: const EdgeInsets.fromLTRB(Spacing.l, 10, Spacing.l, 0),
            child: MealCard(
              slot: slot,
              entryNames: [
                for (final item in entries)
                  if (item.slot.id == slot.id)
                    item.entry.name.isEmpty
                        ? l10n.productUnknownName
                        : item.entry.name,
              ],
              totals: totals.forMeal(slot.id),
              onOpen: () => showMealSheet(
                context,
                day: day,
                slot: slot,
                onAdd: () => context.push(Routes.addFood(day, slot.id)),
              ),
              onAdd: () => context.push(Routes.addFood(day, slot.id)),
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

/// Ring and macro bars. Side by side on a normal phone; stacked when the
/// space is narrow or the text is very large.
class _DaySummary extends StatelessWidget {
  const _DaySummary({required this.totals, required this.goal});

  final NutrientTotals totals;
  final UserGoalRow? goal;

  @override
  Widget build(BuildContext context) {
    final ring = CalorieRing(totals: totals, goalKcal: goal?.kcal);
    final macros = MacroBars(totals: totals, goal: goal);
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked =
            constraints.maxWidth < 280 ||
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
            const SizedBox(width: Spacing.l),
            Expanded(child: macros),
          ],
        );
      },
    );
  }
}
