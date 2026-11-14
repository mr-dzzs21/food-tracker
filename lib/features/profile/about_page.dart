import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/app_info.dart';
import '../../core/links.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_top_bar.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/card_list.dart';
import '../../core/widgets/eating_disorder_help.dart';
import '../../core/widgets/icon_square.dart';
import '../../l10n/app_localizations.dart';

/// About the app: version, licences, data source, disclaimers, help.
class AboutPage extends ConsumerWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final version = ref.watch(appVersionProvider);

    final colors = context.appColors;

    return Scaffold(
      appBar: AppTopBar(title: l10n.aboutTitle),
      body: ListView(
        padding: const EdgeInsets.only(top: Spacing.s, bottom: Spacing.xxl),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.l),
            child: AppCard(
              padding: const EdgeInsets.all(Spacing.xl),
              child: Column(
                children: [
                  ExcludeSemantics(
                    child: IconSquare(
                      icon: Icons.eco_rounded,
                      background: colors.tonal,
                      foreground: colors.onTonal,
                      size: 64,
                      iconSize: 36,
                      radius: Radii.button,
                    ),
                  ),
                  const SizedBox(height: Spacing.m),
                  Text(
                    l10n.appTitle,
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: Spacing.xs),
                  Text(
                    l10n.aboutVersion(version),
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          _Section(
            title: l10n.aboutOpenSource,
            children: [
              Text(l10n.aboutOpenSourceText),
              _LinkButton(
                icon: Icons.code_rounded,
                label: l10n.aboutSourceCode,
                onPressed: () => openLink(context, Uri.parse(repositoryUrl)),
              ),
            ],
          ),
          // Required by the Open Food Facts licence (ODbL / CC BY-SA).
          _Section(
            title: l10n.aboutDataSourceTitle,
            children: [
              Text(l10n.aboutDataSourceText),
              _LinkButton(
                icon: Icons.open_in_new_rounded,
                label: l10n.aboutOpenOff,
                onPressed: () =>
                    openLink(context, Uri.https('world.openfoodfacts.org')),
              ),
            ],
          ),
          _Section(
            title: l10n.aboutNotesTitle,
            children: [
              Text(l10n.disclaimerShort),
              const SizedBox(height: Spacing.s),
              Text(l10n.disclaimerGoals),
            ],
          ),
          _Section(
            title: l10n.aboutPrivacyTitle,
            children: [Text(l10n.aboutPrivacyText)],
          ),
          _Section(
            title: l10n.helpEdTitle,
            children: const [EatingDisorderHelp(showTitle: false)],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.l,
              Spacing.xl,
              Spacing.l,
              0,
            ),
            child: TonalButton(
              large: true,
              icon: Icons.description_rounded,
              label: l10n.aboutLicenses,
              onPressed: () => showLicensePage(
                context: context,
                applicationName: l10n.appTitle,
                applicationVersion: version,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A titled white card with text (and links) in it.
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return CardSection(
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

/// A link below a text, aligned with the text's start.
class _LinkButton extends StatelessWidget {
  const _LinkButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: Spacing.xs),
    child: TextButton.icon(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.xs),
      ),
      icon: Icon(icon),
      label: Text(label),
      onPressed: onPressed,
    ),
  );
}
