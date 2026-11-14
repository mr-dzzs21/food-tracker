import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';
import '../links.dart';
import '../theme/app_theme.dart';

/// The eating-disorder helpline of the BIÖG (German Federal Institute for
/// Public Health). Checked 2026-11-14 – check again before each release.
abstract final class EatingDisorderHelpline {
  static const phoneNumber = '0221 892031';
  static final phoneUri = Uri(scheme: 'tel', path: '+49221892031');
  static const website = 'essstoerungen.bioeg.de';
  static final websiteUri = Uri.https(website);
}

/// Help for people with eating disorders: a short text, a button to call the
/// BIÖG helpline, its opening hours and its website.
///
/// A calorie app can make an eating disorder worse, so this help is always
/// visible on the goal page and the about page, and reachable from the
/// profile tab. The English UI shows a general sentence plus the German
/// service (the app has no English helpline).
class EatingDisorderHelp extends StatelessWidget {
  const EatingDisorderHelp({super.key, this.showTitle = true});

  /// False inside a dialog that already shows the title.
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTitle) ...[
          Semantics(
            header: true,
            child: Text(l10n.helpEdTitle, style: theme.textTheme.titleSmall),
          ),
          const SizedBox(height: Spacing.s),
        ],
        Text(l10n.helpEdText),
        const SizedBox(height: Spacing.s),
        TextButton.icon(
          icon: const Icon(Icons.phone_outlined),
          label: Text(l10n.helpEdCall(EatingDisorderHelpline.phoneNumber)),
          onPressed: () => openLink(context, EatingDisorderHelpline.phoneUri),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.m),
          child: Text(
            l10n.helpEdHours,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: Spacing.xs),
        TextButton.icon(
          icon: const Icon(Icons.open_in_new),
          label: Text(l10n.helpEdWebsite(EatingDisorderHelpline.website)),
          onPressed: () => openLink(context, EatingDisorderHelpline.websiteUri),
        ),
      ],
    );
  }
}

/// Shows [EatingDisorderHelp] in a dialog (used by the profile tab).
Future<void> showEatingDisorderHelp(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.helpEdTitle),
      content: const SingleChildScrollView(
        child: EatingDisorderHelp(showTitle: false),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionClose),
        ),
      ],
    ),
  );
}
