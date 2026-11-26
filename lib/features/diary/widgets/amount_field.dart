import 'package:material_ui/material_ui.dart';

import '../../../l10n/app_localizations.dart';
import '../diary_repository.dart';

/// Text field for an amount in g (or ml for drinks).
///
/// Accepts a decimal comma ("12,5") as well as a point. Shows an error when
/// the text is not a valid amount (see [parseEntryAmount]).
class AmountField extends StatelessWidget {
  const AmountField({
    super.key,
    required this.controller,
    required this.isLiquid,
    this.onChanged,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final bool isLiquid;
  final ValueChanged<String>? onChanged;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Rebuilds the error text on every keystroke.
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, value, _) {
        final invalid = parseEntryAmount(value.text, l10n.localeName) == null;
        return TextField(
          controller: controller,
          autofocus: autofocus,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.done,
          onChanged: onChanged,
          decoration: InputDecoration(
            labelText: l10n.entryAmountLabel,
            suffixText: isLiquid ? 'ml' : 'g',
            errorText: invalid ? l10n.amountInvalid : null,
          ),
        );
      },
    );
  }
}
