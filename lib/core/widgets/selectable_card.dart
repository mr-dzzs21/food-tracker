import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

/// A white card that is one option of a group, e.g. "Wie aktiv bist du?".
/// The selected card gets a 2 px brand border and a filled check circle.
///
/// For screen readers it is a button with the "selected" state, like the
/// radio buttons it replaces.
class SelectableCard extends StatelessWidget {
  const SelectableCard({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final subtitle = this.subtitle;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(Radii.button),
      // Always 2 px, so the card does not jump when it gets selected.
      side: BorderSide(
        color: selected ? colors.brand : colors.brand.withValues(alpha: 0),
        width: 2,
      ),
    );
    return Semantics(
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Radii.button),
          boxShadow: colors.cardShadow,
        ),
        child: Material(
          color: colors.surface,
          shape: shape,
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
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: theme.textTheme.bodyLarge!.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(subtitle, style: theme.textTheme.bodySmall),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: Spacing.m),
                    // Decoration only: the state is in the semantics above.
                    ExcludeSemantics(
                      child: Icon(
                        selected
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color: selected ? colors.brand : colors.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
