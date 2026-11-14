import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/app_info.dart';
import '../../core/links.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/eating_disorder_help.dart';
import '../../l10n/app_localizations.dart';

/// About the app: version, licences, data source, disclaimers, help.
class AboutPage extends ConsumerWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final version = ref.watch(appVersionProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Spacing.l,
          Spacing.l,
          Spacing.l,
          Spacing.xxl,
        ),
        children: [
          Icon(Icons.eco_outlined, size: 48, color: theme.colorScheme.primary),
          const SizedBox(height: Spacing.s),
          Text(
            l10n.appTitle,
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          Text(
            l10n.aboutVersion(version),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          _Section(
            title: l10n.aboutOpenSource,
            children: [
              Text(l10n.aboutOpenSourceText),
              TextButton.icon(
                icon: const Icon(Icons.code),
                label: Text(l10n.aboutSourceCode),
                onPressed: () => openLink(context, Uri.parse(repositoryUrl)),
              ),
            ],
          ),
          // Required by the Open Food Facts licence (ODbL / CC BY-SA).
          _Section(
            title: l10n.aboutDataSourceTitle,
            children: [
              Text(l10n.aboutDataSourceText),
              TextButton.icon(
                icon: const Icon(Icons.open_in_new),
                label: Text(l10n.aboutOpenOff),
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
          const SizedBox(height: Spacing.xl),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(Spacing.l),
              child: EatingDisorderHelp(),
            ),
          ),
          const SizedBox(height: Spacing.xl),
          OutlinedButton.icon(
            icon: const Icon(Icons.description_outlined),
            label: Text(l10n.aboutLicenses),
            onPressed: () => showLicensePage(
              context: context,
              applicationName: l10n.appTitle,
              applicationVersion: version,
            ),
          ),
        ],
      ),
    );
  }
}

/// A heading with text below it.
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
          const SizedBox(height: Spacing.s),
          ...children,
        ],
      ),
    );
  }
}
