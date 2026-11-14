import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';

/// A text field for searching, with a search button at the end.
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
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      onChanged: onChanged,
      onSubmitted: (_) => _submit(),
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: IconButton(
          icon: const Icon(Icons.arrow_forward),
          tooltip: l10n.searchSubmit,
          onPressed: _submit,
        ),
      ),
    );
  }
}
