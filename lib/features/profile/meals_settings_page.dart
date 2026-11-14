import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_top_bar.dart';
import '../../core/widgets/bottom_cta_bar.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/dialogs.dart';
import '../../core/widgets/icon_square.dart';
import '../../core/widgets/status_view.dart';
import '../../data/database.dart';
import '../../l10n/app_localizations.dart';
import '../diary/diary_repository.dart';
import '../diary/meal_style.dart';

/// Rename, add, hide and reorder meals.
///
/// Rules (spec §4): a meal with diary entries cannot be deleted, only
/// hidden, and at least one meal must stay visible.
class MealsSettingsPage extends ConsumerWidget {
  const MealsSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final slots = ref.watch(mealSlotsProvider);
    return Scaffold(
      appBar: AppTopBar(title: l10n.mealsTitle),
      bottomNavigationBar: BottomCtaBar(
        child: CtaButton(
          icon: Icons.add_rounded,
          label: l10n.mealsAdd,
          onPressed: () => _addMeal(context, ref),
        ),
      ),
      body: switch (slots) {
        AsyncData(:final value) => _MealsList(slots: value),
        AsyncError() => StatusView(
          icon: Icons.error_outline_rounded,
          title: l10n.errorGeneric,
          actionLabel: l10n.actionRetry,
          onAction: () => ref.invalidate(mealSlotsProvider),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  Future<void> _addMeal(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<_MealDialogResult>(
      context: context,
      builder: (_) => const _MealDialog(slot: null),
    );
    if (result is! _SaveMeal) return;
    await ref
        .read(diaryRepositoryProvider)
        .addMealSlot(name: result.name, startMinute: result.startMinute);
  }
}

class _MealsList extends ConsumerStatefulWidget {
  const _MealsList({required this.slots});

  /// All meals, sorted by position (from the database).
  final List<MealSlot> slots;

  @override
  ConsumerState<_MealsList> createState() => _MealsListState();
}

class _MealsListState extends ConsumerState<_MealsList> {
  /// The order right after a drag, until the database reports it. Without
  /// it the item would jump back for a moment.
  List<MealSlot>? _draggedOrder;

  @override
  void didUpdateWidget(_MealsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // New data from the database: it already has the new order.
    if (!identical(oldWidget.slots, widget.slots)) _draggedOrder = null;
  }

  Future<void> _reorder(int oldIndex, int newIndex) async {
    // `onReorderItem` already corrects newIndex for the removed item.
    final slots = [...(_draggedOrder ?? widget.slots)];
    slots.insert(newIndex, slots.removeAt(oldIndex));
    setState(() => _draggedOrder = slots);
    await ref.read(diaryRepositoryProvider).reorderMealSlots([
      for (final slot in slots) slot.id,
    ]);
  }

  Future<void> _setHidden(MealSlot slot, {required bool hidden}) async {
    final messenger = ScaffoldMessenger.of(context);
    final lastVisible = AppLocalizations.of(context).mealsLastVisible;
    final changed = await ref
        .read(diaryRepositoryProvider)
        .setMealSlotHidden(slot.id, hidden: hidden);
    if (!changed) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(lastVisible)));
    }
  }

  Future<void> _edit(MealSlot slot) async {
    final result = await showDialog<_MealDialogResult>(
      context: context,
      builder: (_) => _MealDialog(slot: slot),
    );
    switch (result) {
      case _SaveMeal(:final name, :final startMinute):
        await ref
            .read(diaryRepositoryProvider)
            .updateMealSlot(
              slot.id,
              customName: name,
              startMinute: startMinute,
            );
      case _DeleteMeal():
        await _delete(slot);
      case null:
        break;
    }
  }

  Future<void> _delete(MealSlot slot) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final repository = ref.read(diaryRepositoryProvider);
    final name = mealSlotName(slot, l10n);

    // Checked first, so the user is not asked "löschen?" in vain.
    if (await repository.mealSlotHasEntries(slot.id)) {
      if (mounted) await _explainInUse(slot);
      return;
    }
    if (!mounted) return;
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.mealsDeleteTitle(name),
      message: l10n.mealsDeleteText,
      confirmLabel: l10n.actionDelete,
      destructive: true,
    );
    if (!confirmed) return;

    final result = await repository.deleteMealSlot(slot.id);
    switch (result) {
      case MealSlotDeleteResult.deleted:
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.mealsDeleted(name))),
        );
      case MealSlotDeleteResult.lastVisible:
        messenger.showSnackBar(SnackBar(content: Text(l10n.mealsLastVisible)));
      case MealSlotDeleteResult.hasEntries:
        // Only if an entry was added in the meantime.
        if (mounted) await _explainInUse(slot);
    }
  }

  /// "Diese Mahlzeit wird verwendet" with the offer to hide it instead.
  Future<void> _explainInUse(MealSlot slot) async {
    final l10n = AppLocalizations.of(context);
    final hide = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.mealsInUseTitle),
        content: Text(l10n.mealsInUseText(mealSlotName(slot, l10n))),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.actionCancel),
          ),
          if (!slot.isHidden)
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.mealsInUseHide),
            ),
        ],
      ),
    );
    if (hide == true) await _setHidden(slot, hidden: true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final slots = _draggedOrder ?? widget.slots;
    return ReorderableListView(
      // Own drag handles: a long press on the whole row would clash with
      // the tap that opens the edit dialog.
      buildDefaultDragHandles: false,
      onReorderItem: _reorder,
      padding: const EdgeInsets.fromLTRB(Spacing.l, 0, Spacing.l, Spacing.xl),
      // The lifted card keeps its round shape (no square Material shadow).
      proxyDecorator: (child, _, _) =>
          Material(type: MaterialType.transparency, child: child),
      header: Padding(
        padding: const EdgeInsets.fromLTRB(
          Spacing.xs,
          Spacing.s,
          Spacing.xs,
          Spacing.m,
        ),
        child: Text(l10n.mealsHint, style: theme.textTheme.bodySmall),
      ),
      children: [
        for (final (index, slot) in slots.indexed)
          Padding(
            key: ValueKey(slot.id),
            padding: const EdgeInsets.only(bottom: Spacing.s),
            child: _MealRow(
              slot: slot,
              index: index,
              onTap: () => _edit(slot),
              onVisibleChanged: (visible) => _setHidden(slot, hidden: !visible),
            ),
          ),
      ],
    );
  }
}

/// One meal as a card: its icon, name, start time, "anzeigen" switch and
/// drag handle.
class _MealRow extends StatelessWidget {
  const _MealRow({
    required this.slot,
    required this.index,
    required this.onTap,
    required this.onVisibleChanged,
  });

  final MealSlot slot;
  final int index;
  final VoidCallback onTap;
  final ValueChanged<bool> onVisibleChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = context.appColors;
    final palette = mealPaletteOf(slot, colors);
    final name = mealSlotName(slot, l10n);
    final details = [
      _startTimeText(context, slot.startMinute),
      if (slot.isHidden) l10n.mealsHidden,
    ].join(' · ');

    return AppCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 64),
        child: Padding(
          padding: const EdgeInsetsDirectional.only(
            start: Spacing.l,
            top: Spacing.s,
            bottom: Spacing.s,
          ),
          child: Row(
            children: [
              IconSquare(
                icon: mealIconOf(slot),
                background: palette.background,
                foreground: palette.icon,
              ),
              const SizedBox(width: Spacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.w800,
                        // Hidden meals look a bit quieter.
                        color: slot.isHidden ? colors.inkMuted : null,
                      ),
                    ),
                    Text(details, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              Semantics(
                label: l10n.mealsShow(name),
                child: Switch.adaptive(
                  value: !slot.isHidden,
                  onChanged: onVisibleChanged,
                ),
              ),
              ReorderableDragStartListener(
                index: index,
                // Its own node, so screen readers announce the handle (the
                // list adds "move up/down" actions to the row itself).
                child: Semantics(
                  container: true,
                  label: l10n.mealsMove(name),
                  child: SizedBox.square(
                    // At least 48 × 48, so the handle is easy to grab.
                    dimension: 48,
                    child: Icon(
                      Icons.drag_indicator_rounded,
                      color: colors.inkMuted,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "ab 11:00" or "keine Uhrzeit", in the format of the device (12/24 h).
String _startTimeText(BuildContext context, int? startMinute) {
  final l10n = AppLocalizations.of(context);
  if (startMinute == null) return l10n.mealsNoStartTime;
  return l10n.mealsStartTime(_formatMinute(context, startMinute));
}

String _formatMinute(BuildContext context, int minute) =>
    MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay(hour: minute ~/ 60, minute: minute % 60),
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );

// -----------------------------------------------------------------------------
// The dialog to add or edit a meal

/// What the meal dialog returns: save the values, or delete the meal.
sealed class _MealDialogResult {
  const _MealDialogResult();
}

class _SaveMeal extends _MealDialogResult {
  const _SaveMeal({required this.name, required this.startMinute});

  /// Trimmed; empty means "default name" (only possible for built-in meals).
  final String name;
  final int? startMinute;
}

class _DeleteMeal extends _MealDialogResult {
  const _DeleteMeal();
}

/// Name and start time of a meal. [slot] is `null` for a new meal.
class _MealDialog extends StatefulWidget {
  const _MealDialog({required this.slot});

  final MealSlot? slot;

  @override
  State<_MealDialog> createState() => _MealDialogState();
}

class _MealDialogState extends State<_MealDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.slot?.customName);
  late int? _startMinute = widget.slot?.startMinute;

  /// Built-in meals have a translated default name, so the field may be
  /// left empty. Meals the user added need a name.
  bool get _hasDefaultName => widget.slot?.builtIn != null;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final start = _startMinute ?? 12 * 60;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: start ~/ 60, minute: start % 60),
    );
    if (picked != null) {
      setState(() => _startMinute = picked.hour * 60 + picked.minute);
    }
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context)
        .pop(_SaveMeal(name: _name.text.trim(), startMinute: _startMinute));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final slot = widget.slot;
    final startMinute = _startMinute;
    // The name shown when the field stays empty (built-in meals only).
    final defaultName = slot == null
        ? null
        : mealSlotName(slot.copyWith(customName: const Value(null)), l10n);

    return AlertDialog(
      title: Text(slot == null ? l10n.mealsNewTitle : l10n.mealsEditTitle),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _name,
                autofocus: slot == null,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: l10n.mealsNameLabel,
                  hintText: _hasDefaultName && defaultName != null
                      ? l10n.mealsNameDefaultHint(defaultName)
                      : null,
                ),
                validator: (text) =>
                    !_hasDefaultName && (text ?? '').trim().isEmpty
                    ? l10n.mealsNameMissing
                    : null,
                onFieldSubmitted: (_) => _save(),
              ),
              const SizedBox(height: Spacing.l),
              Text(l10n.mealsStartTimeLabel, style: theme.textTheme.labelLarge),
              const SizedBox(height: Spacing.xs),
              Text(
                startMinute == null
                    ? l10n.mealsNoStartTime
                    : _formatMinute(context, startMinute),
                style: theme.textTheme.titleMedium,
              ),
              Wrap(
                spacing: Spacing.s,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.schedule_rounded),
                    label: Text(l10n.mealsPickTime),
                    onPressed: _pickTime,
                  ),
                  if (startMinute != null)
                    TextButton(
                      onPressed: () => setState(() => _startMinute = null),
                      child: Text(l10n.mealsClearTime),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        if (slot != null)
          TextButton(
            onPressed: () => Navigator.of(context).pop(const _DeleteMeal()),
            style: TextButton.styleFrom(
              foregroundColor: context.appColors.ratingHigh,
            ),
            child: Text(l10n.actionDelete),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionCancel),
        ),
        TextButton(onPressed: _save, child: Text(l10n.actionSave)),
      ],
    );
  }
}
