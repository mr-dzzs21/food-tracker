import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';

/// The hint "Ziel festlegen" shown on the Today tab while no goal is set.
/// The user can close it for good ([onDismiss]).
class GoalCard extends StatelessWidget {
  const GoalCard({super.key, required this.onSetGoal, required this.onDismiss});

  final VoidCallback onSetGoal;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Spacing.l,
          Spacing.xs,
          Spacing.xs,
          Spacing.l,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.flag_outlined),
                const SizedBox(width: Spacing.s),
                Expanded(
                  child: Text(
                    l10n.todayGoalCardTitle,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: l10n.todayGoalCardDismiss,
                  onPressed: onDismiss,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: Spacing.m),
              child: Text(l10n.todayGoalCardText),
            ),
            const SizedBox(height: Spacing.m),
            FilledButton.tonal(
              onPressed: onSetGoal,
              child: Text(l10n.todayGoalCardButton),
            ),
          ],
        ),
      ),
    );
  }
}
