import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/icon_square.dart';
import '../../../l10n/app_localizations.dart';

/// The compact white card "Leg dein Tagesziel fest" on the Today tab, shown
/// while no goal is set. The user can close it for good ([onDismiss]).
class GoalPrompt extends StatelessWidget {
  const GoalPrompt({
    super.key,
    required this.onSetGoal,
    required this.onDismiss,
  });

  final VoidCallback onSetGoal;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    return AppCard(
      padding: const EdgeInsetsDirectional.fromSTEB(
        Spacing.m,
        Spacing.m,
        Spacing.xs,
        Spacing.m,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExcludeSemantics(
            child: IconSquare(
              icon: Icons.flag_rounded,
              background: colors.tonal,
              foreground: colors.onTonal,
              size: 40,
              iconSize: 22,
            ),
          ),
          const SizedBox(width: Spacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: Spacing.s),
                Text(
                  l10n.todayGoalCardTitle,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: Spacing.s),
                TonalButton(
                  label: l10n.todayGoalCardButton,
                  onPressed: onSetGoal,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 20),
            color: colors.inkMuted,
            tooltip: l10n.todayGoalCardDismiss,
            onPressed: onDismiss,
          ),
        ],
      ),
    );
  }
}
