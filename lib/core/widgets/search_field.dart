import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import 'buttons.dart';

/// A text field for searching, with a search button at the end. White on
/// the page background (with the card shadow), the button is a small dark
/// square.
///
/// [onSubmitted] runs on the keyboard's search key and on the button, and
/// only with non-empty text (trimmed). Online searches belong there, not in
/// [onChanged], because Open Food Facts allows only a few searches per
/// minute.
class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onSubmitted,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onSubmitted;
  final ValueChanged<String>? onChanged;

  void _submit() {
    final text = controller.text.trim();
    if (text.isNotEmpty) onSubmitted(text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Radii.input),
        boxShadow: colors.cardShadow,
      ),
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.search,
        onChanged: onChanged,
        onSubmitted: (_) => _submit(),
        decoration: InputDecoration(
          hintText: hintText,
          fillColor: colors.surface,
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: Padding(
            padding: const EdgeInsetsDirectional.only(end: Spacing.xs),
            child: SquareIconButton(
              icon: Icons.arrow_forward_rounded,
              tooltip: l10n.searchSubmit,
              size: 36,
              iconSize: 20,
              background: colors.cta,
              foreground: colors.onCta,
              onPressed: _submit,
            ),
          ),
        ),
      ),
    );
  }
}
