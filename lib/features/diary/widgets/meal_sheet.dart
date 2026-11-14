import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/format.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/icon_square.dart';
import '../../../data/database.dart';
import '../../../l10n/app_localizations.dart';
import '../../products/nutrient_format.dart';
import '../../products/nutrients.dart';
import '../diary_repository.dart';
import '../meal_style.dart';
import '../total_text.dart';
import 'entry_sheet.dart';

/// Opens the entries of one meal on [day] as a bottom sheet.
///
/// [onAdd] runs after the sheet closed via "Hinzufügen" (it opens the
/// add-food page). The sheet covers the navigation bar (root navigator).
Future<void> showMealSheet(
  BuildContext context, {
  required String day,
  required MealSlot slot,
  required VoidCallback onAdd,
}) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => MealSheet(day: day, slotId: slot.id, onAdd: onAdd),
  );
}

/// The entries of one meal: tap to change, swipe left to delete (with
/// "Rückgängig"), "Hinzufügen" at the bottom. Follows the database live.
class MealSheet extends ConsumerStatefulWidget {
  const MealSheet({
    super.key,
    required this.day,
    required this.slotId,
    required this.onAdd,
  });

  final String day;
  final int slotId;
  final VoidCallback onAdd;

  @override
  ConsumerState<MealSheet> createState() => _MealSheetState();
}

class _MealSheetState extends ConsumerState<MealSheet> {
  /// Entries that were swiped away. A swiped [Dismissible] must leave the
  /// tree at once, but the database stream only reports the deletion a
  /// moment later – so these are hidden right away.
  final _removedIds = <int>{};

  Future<void> _delete(DiaryEntry entry) async {
    setState(() => _removedIds.add(entry.id));
    final repository = ref.read(diaryRepositoryProvider);
    // The app's ScaffoldMessenger: the SnackBar shows inside this sheet
    // (it has its own Scaffold) and stays on Today after the sheet closes.
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

  Future<void> _openEntry(DiaryEntry entry, List<MealSlot> slots) async {
    final result = await showEntrySheet(context, entry: entry, slots: slots);
    if (result == EntrySheetResult.delete) await _delete(entry);
  }

  void _add() {
    Navigator.of(context).pop();
    widget.onAdd();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = context.appColors;
    final slots = ref.watch(mealSlotsProvider).value ?? const <MealSlot>[];
    final slot = slots.where((s) => s.id == widget.slotId).firstOrNull;
    final entries = [
      for (final item
          in ref.watch(dayEntriesProvider(widget.day)).value ??
              const <DayEntry>[])
        if (item.slot.id == widget.slotId &&
            !_removedIds.contains(item.entry.id))
          item.entry,
    ];
    final totals = NutrientTotals.sum(entries.map((e) => e.nutrients));

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Scaffold(
        // The sheet's own Scaffold, so the "Rückgängig" SnackBar appears
        // above the sheet and not hidden behind it.
        backgroundColor: Colors.transparent,
        body: ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(
            Spacing.l,
            0,
            Spacing.l,
            Spacing.l,
          ),
          children: [
            if (slot != null)
              _Header(slot: slot, entries: entries, totals: totals),
            const SizedBox(height: Spacing.m),
            if (entries.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: Spacing.xl),
                child: Text(
                  l10n.mealSheetEmpty,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium!.copyWith(
                    color: colors.inkMuted,
                  ),
                ),
              ),
            for (final entry in entries)
              Padding(
                padding: const EdgeInsets.only(bottom: Spacing.s),
                child: _EntryRow(
                  entry: entry,
                  onTap: () => _openEntry(entry, slots),
                  onDelete: () => _delete(entry),
                ),
              ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.all(Spacing.l),
          child: CtaButton(
            label: l10n.actionAdd,
            icon: Icons.add_rounded,
            onPressed: _add,
          ),
        ),
      ),
    );
  }
}

/// Icon, meal name, number of entries and the kcal sum.
class _Header extends StatelessWidget {
  const _Header({
    required this.slot,
    required this.entries,
    required this.totals,
  });

  final MealSlot slot;
  final List<DiaryEntry> entries;
  final NutrientTotals totals;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = mealPaletteOf(slot, context.appColors);
    return Row(
      children: [
        IconSquare(
          icon: mealIconOf(slot),
          background: palette.background,
          foreground: palette.icon,
          size: 44,
          iconSize: 24,
          radius: Radii.input,
        ),
        const SizedBox(width: Spacing.m),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(
                  mealSlotName(slot, l10n),
                  style: theme.textTheme.titleMedium,
                ),
              ),
              Text(
                l10n.todayMealEntries(entries.length),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(width: Spacing.s),
        Text(
          l10n.unitKcal(totalText(totals, Nutrient.kcal, l10n)),
          style: theme.textTheme.titleMedium!.copyWith(
            fontFeatures: tabularFigures,
          ),
        ),
      ],
    );
  }
}

/// One entry: name, amount (· brand), kcal. Swipe left to delete.
class _EntryRow extends StatelessWidget {
  const _EntryRow({
    required this.entry,
    required this.onTap,
    required this.onDelete,
  });

  final DiaryEntry entry;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = context.appColors;
    final kcal = entry.nutrients.kcal;
    final amount = formatAmount(
      entry.amount,
      isLiquid: entry.isLiquid,
      locale: l10n.localeName,
    );
    final brand = entry.brand;
    final radius = BorderRadius.circular(Radii.input);
    return Dismissible(
      key: ValueKey(entry.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        decoration: BoxDecoration(
          color: colors.ratingHighBg,
          borderRadius: radius,
        ),
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsets.symmetric(horizontal: Spacing.xl),
        child: Icon(Icons.delete_outline_rounded, color: colors.ratingHigh),
      ),
      child: Material(
        color: colors.surfaceAlt,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.l,
                vertical: Spacing.m,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.name.isEmpty
                              ? l10n.productUnknownName
                              : entry.name,
                          style: theme.textTheme.bodyLarge!.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          brand == null ? amount : '$amount · $brand',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: Spacing.m),
                  Text(
                    kcal == null
                        ? '–'
                        : formatNutrientValue(Nutrient.kcal, kcal, l10n),
                    // Screen readers would read "–" as "dash".
                    semanticsLabel: kcal == null ? l10n.ratingNoData : null,
                    style: theme.textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.w800,
                      fontFeatures: tabularFigures,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
