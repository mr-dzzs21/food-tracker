import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/format.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/database.dart';
import '../../../l10n/app_localizations.dart';
import '../diary_repository.dart';
import 'amount_field.dart';
import 'meal_dropdown.dart';

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

/// Bottom sheet: change the amount or meal of an entry, or delete it.
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
    final entry = widget.entry;
    return Padding(
      // Keeps the fields above the on-screen keyboard.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          Spacing.xl,
          0,
          Spacing.xl,
          Spacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              entry.name.isEmpty ? l10n.productUnknownName : entry.name,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: Spacing.l),
            AmountField(
              controller: _amount,
              isLiquid: entry.isLiquid,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: Spacing.l),
            MealDropdown(
              slots: widget.slots,
              selectedId: _slotId,
              onChanged: (id) => setState(() => _slotId = id),
            ),
            const SizedBox(height: Spacing.xl),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: Spacing.s,
              runSpacing: Spacing.s,
              children: [
                TextButton.icon(
                  onPressed: () =>
                      Navigator.of(context).pop(EntrySheetResult.delete),
                  icon: const Icon(Icons.delete_outline),
                  label: Text(l10n.actionDelete),
                ),
                FilledButton(
                  onPressed: parseEntryAmount(_amount.text) == null
                      ? null
                      : _save,
                  child: Text(l10n.actionSave),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
