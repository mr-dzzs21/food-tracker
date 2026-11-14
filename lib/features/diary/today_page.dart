import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/clock.dart';
import '../../core/theme/app_theme.dart';
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
import 'widgets/entry_sheet.dart';
import 'widgets/goal_card.dart';
import 'widgets/macro_bars.dart';
import 'widgets/meal_section.dart';

/// Tab "Heute": calorie ring, macros and the meals of the selected day.
class TodayPage extends ConsumerWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final day = ref.watch(selectedDayProvider);
    final entries = ref.watch(dayEntriesProvider(day));
    final slots = ref.watch(mealSlotsProvider);
    final goal = ref.watch(goalProvider);

    return Scaffold(
      appBar: _DateSwitcherBar(day: day),
      body: switch ((entries, slots, goal)) {
        (
          AsyncData(value: final entries),
          AsyncData(value: final slots),
          AsyncData(value: final goal),
        ) =>
          _TodayContent(day: day, entries: entries, slots: slots, goal: goal),
        (AsyncError(), _, _) ||
        (_, AsyncError(), _) ||
        (_, _, AsyncError()) => StatusView(
          icon: Icons.error_outline,
          title: AppLocalizations.of(context).errorGeneric,
          actionLabel: AppLocalizations.of(context).actionRetry,
          onAction: () => ref
            ..invalidate(dayEntriesProvider(day))
            ..invalidate(mealSlotsProvider)
            ..invalidate(goalProvider),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

/// App bar with ‹ "Heute, 14. Nov." ›. Tapping the title opens a date picker;
/// "Heute" jumps back when another day is shown.
class _DateSwitcherBar extends ConsumerWidget implements PreferredSizeWidget {
  const _DateSwitcherBar({required this.day});

  final String day;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

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
    final today = todayKey(ref.watch(clockProvider));
    final notifier = ref.read(selectedDayProvider.notifier);
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.chevron_left),
        tooltip: l10n.dayPrevious,
        onPressed: notifier.previous,
      ),
      titleSpacing: 0,
      title: Tooltip(
        message: l10n.dayPick,
        child: TextButton(
          onPressed: () => _pickDay(context, ref),
          child: Text(
            dayLabel(day, today: today, l10n: l10n),
            style: Theme.of(context).textTheme.titleLarge,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      actions: [
        if (day != today)
          TextButton(onPressed: notifier.today, child: Text(l10n.dayJumpToday)),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          tooltip: l10n.dayNext,
          onPressed: notifier.next,
        ),
      ],
    );
  }
}

class _TodayContent extends ConsumerStatefulWidget {
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
  ConsumerState<_TodayContent> createState() => _TodayContentState();
}

class _TodayContentState extends ConsumerState<_TodayContent> {
  /// Entries that were swiped away. A swiped [Dismissible] must leave the
  /// tree at once, but the database stream only reports the deletion a
  /// moment later – so these are hidden right away.
  final _removedIds = <int>{};

  Future<void> _delete(DiaryEntry entry) async {
    setState(() => _removedIds.add(entry.id));
    final repository = ref.read(diaryRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    await repository.deleteEntry(entry.id);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.diaryEntryDeleted),
          // A SnackBar with an action stays until closed by default; this one
          // should disappear on its own.
          persist: false,
          action: SnackBarAction(
            label: l10n.actionUndo,
            onPressed: () async {
              await repository.restoreEntry(entry);
              if (mounted) setState(() => _removedIds.remove(entry.id));
            },
          ),
        ),
      );
  }

  Future<void> _openEntry(DiaryEntry entry) async {
    final result = await showEntrySheet(
      context,
      entry: entry,
      slots: widget.slots,
    );
    if (result == EntrySheetResult.delete) await _delete(entry);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final goal = widget.goal;
    final entries = [
      for (final item in widget.entries)
        if (!_removedIds.contains(item.entry.id)) item,
    ];
    final totals = DayTotals.of(entries);
    final missingKcal = totals.all[Nutrient.kcal].missingCount;
    final showGoalCard =
        goal == null && ref.watch(goalCardDismissedProvider).value == false;

    // Visible meals, plus hidden meals that have entries on this day.
    final slotIdsWithEntries = {for (final item in entries) item.slot.id};
    final shownSlots = [
      for (final slot in widget.slots)
        if (!slot.isHidden || slotIdsWithEntries.contains(slot.id)) slot,
    ];

    return ListView(
      padding: const EdgeInsets.all(Spacing.l),
      children: [
        if (showGoalCard) ...[
          GoalCard(
            onSetGoal: () => context.go(Routes.goal),
            onDismiss: () =>
                ref.read(goalCardDismissedProvider.notifier).dismiss(),
          ),
          const SizedBox(height: Spacing.l),
        ],
        Card(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.xl),
            child: Column(
              children: [
                CalorieRing(totals: totals.all, goalKcal: goal?.kcal),
                if (goal != null) ...[
                  const SizedBox(height: Spacing.m),
                  Text(
                    l10n.todayEatenLine(
                      totalText(totals.all, Nutrient.kcal, l10n),
                    ),
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
                if (missingKcal > 0) ...[
                  const SizedBox(height: Spacing.s),
                  _MissingValuesHint(count: missingKcal),
                ],
                const SizedBox(height: Spacing.xl),
                MacroBars(totals: totals.all, goal: goal),
              ],
            ),
          ),
        ),
        if (entries.isEmpty)
          Padding(
            padding: const EdgeInsets.all(Spacing.l),
            child: Text(
              l10n.todayEmptyDay,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        for (final slot in shownSlots) ...[
          const SizedBox(height: Spacing.m),
          MealSection(
            slot: slot,
            entries: [
              for (final item in entries)
                if (item.slot.id == slot.id) item.entry,
            ],
            totals: totals.forMeal(slot.id),
            onAdd: () => context.push(Routes.addFood(widget.day, slot.id)),
            onTapEntry: _openEntry,
            onDelete: _delete,
          ),
        ],
      ],
    );
  }
}

/// "Für 2 Einträge fehlen Angaben" with an info icon (brief R16).
class _MissingValuesHint extends StatelessWidget {
  const _MissingValuesHint({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.info_outline, size: 18, color: color),
        const SizedBox(width: Spacing.xs),
        Flexible(
          child: Text(
            AppLocalizations.of(context).todayMissingValues(count),
            style: theme.textTheme.bodySmall?.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}
