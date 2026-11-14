import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/format.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/pill_choices.dart';
import '../../../data/database.dart';
import '../../../l10n/app_localizations.dart';
import '../diary_repository.dart';
import 'amount_field.dart';

/// What the user chose in the [EntrySheet].
enum EntrySheetResult { saved, delete }

/// Opens the sheet to change or delete [entry]. Deleting is left to the
/// caller (it shows the "Rückgängig" SnackBar).
Future<EntrySheetResult?> showEntrySheet(
  BuildContext context, {
  required DiaryEntry entry,
  required List<MealSlot> slots,
}) {
  return showModalBottomSheet<EntrySheetResult>(
    context: context,
    // Lets the sheet grow above the keyboard.
    isScrollControlled: true,
    builder: (_) => EntrySheet(entry: entry, slots: slots),
  );
}

/// Bottom sheet: change the amount or meal (pills) of an entry, or delete
/// it.
class EntrySheet extends ConsumerStatefulWidget {
  const EntrySheet({super.key, required this.entry, required this.slots});

  final DiaryEntry entry;
  final List<MealSlot> slots;

  @override
  ConsumerState<EntrySheet> createState() => _EntrySheetState();
}

class _EntrySheetState extends ConsumerState<EntrySheet> {
  late final TextEditingController _amount;
  late int _slotId = widget.entry.mealSlotId;

  @override
  void initState() {
    super.initState();
    _amount = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The number format depends on the language, which needs the context.
    if (_amount.text.isEmpty) {
      _amount.text = formatInputNumber(
        widget.entry.amount,
        AppLocalizations.of(context).localeName,
      );
    }
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amount = parseEntryAmount(_amount.text);
    if (amount == null) return;
    final navigator = Navigator.of(context);
    await ref
        .read(diaryRepositoryProvider)
        .updateEntry(widget.entry.id, amount: amount, mealSlotId: _slotId);
    navigator.pop(EntrySheetResult.saved);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = context.appColors;
    final entry = widget.entry;
    return Padding(
      // Keeps the fields above the on-screen keyboard.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            Spacing.page,
            0,
            Spacing.page,
            Spacing.l,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: Text(
                  entry.name.isEmpty ? l10n.productUnknownName : entry.name,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: Spacing.l),
              AmountField(
                controller: _amount,
                isLiquid: entry.isLiquid,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: Spacing.l),
              Text(
                l10n.entryMealLabel,
                style: theme.textTheme.labelMedium!.copyWith(
                  color: colors.inkMuted,
                ),
              ),
              const SizedBox(height: Spacing.xs),
              PillChoices<int>(
                // The visible meals, plus the entry's meal if it is hidden.
                choices: [
                  for (final slot in widget.slots)
                    if (!slot.isHidden || slot.id == _slotId)
                      PillChoice(mealSlotName(slot, l10n), slot.id),
                ],
                selected: _slotId,
                onSelected: (id) => setState(() => _slotId = id),
              ),
              const SizedBox(height: Spacing.xl),
              CtaButton(
                icon: Icons.check_rounded,
                label: l10n.actionSave,
                onPressed: parseEntryAmount(_amount.text) == null
                    ? null
                    : _save,
              ),
              const SizedBox(height: Spacing.s),
              Center(
                child: TextButton.icon(
                  onPressed: () =>
                      Navigator.of(context).pop(EntrySheetResult.delete),
                  style: TextButton.styleFrom(
                    foregroundColor: colors.ratingHigh,
                  ),
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: Text(l10n.actionDelete),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
