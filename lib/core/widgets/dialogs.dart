import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

/// Asks a yes/no question in a dialog: [title], [message], "Abbrechen" and
/// [confirmLabel]. Returns `true` only when the user confirmed.
///
/// [destructive] paints the confirm button in the "hoch" rating colour
/// (deleting something). Never use it for anything about the daily goal.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  String? cancelLabel,
  bool destructive = false,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      final colors = context.appColors;
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              cancelLabel ?? AppLocalizations.of(context).actionCancel,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: destructive
                ? TextButton.styleFrom(foregroundColor: colors.ratingHigh)
                : null,
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
  return confirmed ?? false;
}

/// A bottom sheet with a [title] and one row per option; the [current] one
/// has a check mark. Tapping a row closes the sheet and returns its value,
/// closing it otherwise returns `null`.
Future<T?> showChoiceSheet<T extends Object>(
  BuildContext context, {
  required String title,
  required T current,
  required Map<T, String> options,
}) {
  return showModalBottomSheet<T>(
    context: context,
    // Above the navigation bar.
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (context) =>
        _ChoiceSheet<T>(title: title, current: current, options: options),
  );
}

class _ChoiceSheet<T extends Object> extends StatelessWidget {
  const _ChoiceSheet({
    required this.title,
    required this.current,
    required this.options,
  });

  final String title;
  final T current;
  final Map<T, String> options;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(Spacing.l, 0, Spacing.l, Spacing.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.xs,
                0,
                Spacing.xs,
                Spacing.m,
              ),
              child: Semantics(
                header: true,
                child: Text(title, style: theme.textTheme.titleMedium),
              ),
            ),
            for (final MapEntry(key: value, value: label) in options.entries)
              Padding(
                padding: const EdgeInsets.only(bottom: Spacing.s),
                child: Semantics(
                  button: true,
                  selected: value == current,
                  inMutuallyExclusiveGroup: true,
                  child: Material(
                    color: value == current ? colors.tonal : colors.surfaceAlt,
                    borderRadius: BorderRadius.circular(Radii.input),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(value),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 52),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Spacing.l,
                            vertical: Spacing.m,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  label,
                                  style: theme.textTheme.bodyLarge!.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: value == current
                                        ? colors.onTonal
                                        : colors.ink,
                                  ),
                                ),
                              ),
                              if (value == current)
                                ExcludeSemantics(
                                  child: Icon(
                                    Icons.check_rounded,
                                    color: colors.onTonal,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
