import 'package:material_ui/material_ui.dart';

import '../../../data/database.dart';
import '../../../l10n/app_localizations.dart';
import '../diary_repository.dart';

/// A dropdown to choose the meal of an entry.
///
/// Offers the visible meals. A hidden meal is only offered when it is the
/// current choice (for example an old entry in a meal the user hid later),
/// so the dropdown never shows an empty value.
class MealDropdown extends StatelessWidget {
  const MealDropdown({
    super.key,
    required this.slots,
    required this.selectedId,
    required this.onChanged,
  });

  /// All meals, sorted by position (as `mealSlotsProvider` returns them).
  final List<MealSlot> slots;
  final int? selectedId;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final options = [
      for (final slot in slots)
        if (!slot.isHidden || slot.id == selectedId) slot,
    ];
    final hasSelection = options.any((slot) => slot.id == selectedId);
    return DropdownButtonFormField<int>(
      initialValue: hasSelection ? selectedId : null,
      isExpanded: true,
      decoration: InputDecoration(labelText: l10n.entryMealLabel),
      items: [
        for (final slot in options)
          DropdownMenuItem(
            value: slot.id,
            child: Text(
              mealSlotName(slot, l10n),
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
      onChanged: (id) {
        if (id != null) onChanged(id);
      },
    );
  }
}
