import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';
import 'buttons.dart';
import 'icon_square.dart';

/// A friendly centred message: for empty lists, errors and "offline".
///
/// Shows an [icon], a [title], an optional [message] and an optional button
/// (for example "Nochmal versuchen").
class StatusView extends StatelessWidget {
  const StatusView({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Smaller version for use inside a list or card.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final actionLabel = this.actionLabel;
    final message = this.message;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(compact ? Spacing.l : Spacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Decoration: the title says the same.
            ExcludeSemantics(
              child: IconSquare(
                icon: icon,
                background: colors.tonal,
                foreground: colors.onTonal,
                size: compact ? 48 : 64,
                iconSize: compact ? 26 : 34,
                radius: compact ? Radii.l : Radii.button,
              ),
            ),
            const SizedBox(height: Spacing.m),
            Text(
              title,
              style: compact
                  ? theme.textTheme.titleSmall
                  : theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: Spacing.s),
              Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.inkMuted,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: Spacing.l),
              TonalButton(label: actionLabel, onPressed: onAction),
            ],
          ],
        ),
      ),
    );
  }
}
