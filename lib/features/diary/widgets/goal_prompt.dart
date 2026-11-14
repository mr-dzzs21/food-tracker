import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/hero_header.dart';
import '../../../l10n/app_localizations.dart';

/// The compact hint "Leg dein Tagesziel fest" inside the Today hero, shown
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
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(
        Spacing.m,
        Spacing.xs,
        0,
        Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.heroGlass,
        borderRadius: BorderRadius.circular(Radii.input),
      ),
      child: Row(
        children: [
          Icon(Icons.flag_rounded, color: colors.onHero, size: 20),
          const SizedBox(width: Spacing.s),
          Expanded(
            // Wrap: with large text the button moves below the sentence.
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: Spacing.s,
              children: [
                Text(
                  l10n.todayGoalCardTitle,
                  style: Theme.of(context).textTheme.labelMedium!
                      .copyWith(color: colors.onHero, fontSize: 13),
                ),
                HeroPill(
                  label: l10n.todayGoalCardButton,
                  filled: true,
                  onPressed: onSetGoal,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 20),
            color: colors.onHero,
            tooltip: l10n.todayGoalCardDismiss,
            onPressed: onDismiss,
          ),
        ],
      ),
    );
  }
}
