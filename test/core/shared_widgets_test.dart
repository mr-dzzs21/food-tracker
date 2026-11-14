import 'package:flutter_test/flutter_test.dart';
import 'package:food_tracker/core/theme/app_theme.dart';
import 'package:food_tracker/core/widgets/app_top_bar.dart';
import 'package:food_tracker/core/widgets/card_list.dart';
import 'package:food_tracker/core/widgets/dialogs.dart';
import 'package:food_tracker/core/widgets/selectable_card.dart';
import 'package:food_tracker/core/widgets/switch_row.dart';
import 'package:food_tracker/data/database.dart';
import 'package:food_tracker/features/scan/widgets/barcode_scanner_view.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/pump_app.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = newTestDatabase());
  tearDown(() => db.close());

  Future<void> pump(
    WidgetTester tester,
    Widget child, {
    Brightness brightness = Brightness.light,
  }) => pumpWidgetInApp(
    tester,
    Scaffold(body: child),
    db: db,
    brightness: brightness,
  );

  group('CardRow and CardGroup', () {
    testWidgets('a tappable row shows a chevron and is one button', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      var taps = 0;
      await pump(
        tester,
        CardGroup(
          children: [
            CardRow(
              title: 'Mahlzeiten',
              subtitle: 'Sortieren',
              onTap: () {
                taps++;
              },
            ),
            const CardRow(title: 'Nur Text'),
          ],
        ),
      );

      expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
      // One thin line between the two rows.
      expect(find.byType(Divider), findsOneWidget);
      await tester.tap(find.text('Sortieren'));
      expect(taps, 1);
      expect(
        tester.getSize(find.byType(CardRow).first).height,
        greaterThanOrEqualTo(48),
      );
      semantics.dispose();
    });

    testWidgets('own trailing widget and title colour', (tester) async {
      await pump(
        tester,
        CardRow(
          title: 'Alle Daten löschen',
          titleColor: AppColors.light.ratingHigh,
          showChevron: false,
          onTap: () {},
        ),
      );
      expect(find.byIcon(Icons.chevron_right_rounded), findsNothing);
      final text = tester.widget<Text>(find.text('Alle Daten löschen'));
      expect(text.style!.color, AppColors.light.ratingHigh);
    });
  });

  testWidgets('SwitchRow: tapping the text flips the adaptive switch', (
    tester,
  ) async {
    var value = false;
    await pump(
      tester,
      StatefulBuilder(
        builder: (context, setState) => SwitchRow(
          title: 'Getränk',
          value: value,
          onChanged: (v) => setState(() => value = v),
        ),
      ),
    );
    await tester.tap(find.text('Getränk'));
    await tester.pump();
    expect(value, isTrue);
    expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
  });

  testWidgets('SelectableCard: selected state for screen readers', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    var chosen = 'a';
    await pump(
      tester,
      StatefulBuilder(
        builder: (context, setState) => Column(
          children: [
            for (final option in ['a', 'b'])
              SelectableCard(
                title: 'Option $option',
                subtitle: 'Text $option',
                selected: chosen == option,
                onTap: () => setState(() => chosen = option),
              ),
          ],
        ),
      ),
    );

    Matcher state({required bool selected}) => isSemantics(
      isButton: true,
      isSelected: selected,
      isInMutuallyExclusiveGroup: true,
      hasTapAction: true,
    );
    final cardB = find.ancestor(
      of: find.text('Option b'),
      matching: find.byType(SelectableCard),
    );
    expect(tester.getSemantics(cardB), state(selected: false));
    await tester.tap(find.text('Option b'));
    await tester.pump();
    expect(chosen, 'b');
    expect(tester.getSemantics(cardB), state(selected: true));
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    semantics.dispose();
  });

  group('dialogs', () {
    testWidgets('showConfirmDialog returns true only when confirmed', (
      tester,
    ) async {
      final results = <bool>[];
      await pump(
        tester,
        Builder(
          builder: (context) => TextButton(
            onPressed: () async => results.add(
              await showConfirmDialog(
                context,
                title: 'Löschen?',
                message: 'Wirklich?',
                confirmLabel: 'Ja, löschen',
                destructive: true,
              ),
            ),
            child: const Text('Frage'),
          ),
        ),
      );

      await tester.tap(find.text('Frage'));
      await tester.pumpAndSettle();
      // The destructive action uses the "hoch" rating colour.
      final confirm = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Ja, löschen'),
      );
      expect(
        confirm.style!.foregroundColor!.resolve({}),
        AppColors.light.ratingHigh,
      );
      await tester.tap(find.text('Abbrechen'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Frage'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ja, löschen'));
      await tester.pumpAndSettle();
      expect(results, [false, true]);
    });

    testWidgets('showChoiceSheet marks the current option and returns one', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      String? result;
      await pump(
        tester,
        Builder(
          builder: (context) => TextButton(
            onPressed: () async => result = await showChoiceSheet(
              context,
              title: 'Darstellung',
              current: 'system',
              options: const {
                'system': 'Wie das System',
                'light': 'Hell',
                'dark': 'Dunkel',
              },
            ),
            child: const Text('Öffnen'),
          ),
        ),
      );

      await tester.tap(find.text('Öffnen'));
      await tester.pumpAndSettle();
      expect(find.text('Darstellung'), findsOneWidget);
      expect(
        tester.getSemantics(find.text('Wie das System')),
        isSemantics(label: 'Wie das System', isSelected: true, isButton: true),
      );
      await tester.tap(find.text('Dunkel'));
      await tester.pumpAndSettle();
      expect(result, 'dark');
      expect(find.text('Darstellung'), findsNothing);
      semantics.dispose();
    });
  });

  testWidgets('AppTopBar: no back button on a first page, one on top', (
    tester,
  ) async {
    await pumpWidgetInApp(
      tester,
      Builder(
        builder: (context) => Scaffold(
          appBar: const AppTopBar(title: 'Scannen', large: true),
          body: TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) =>
                    const Scaffold(appBar: AppTopBar(title: 'Unterseite')),
              ),
            ),
            child: const Text('Weiter'),
          ),
        ),
      ),
      db: db,
    );

    expect(find.byTooltip('Zurück'), findsNothing);
    final title = tester.widget<Text>(find.text('Scannen'));
    expect(title.style!.fontSize, 26);

    await tester.tap(find.text('Weiter'));
    await tester.pumpAndSettle();
    expect(find.text('Unterseite'), findsOneWidget);
    await tester.tap(find.byTooltip('Zurück'));
    await tester.pumpAndSettle();
    expect(find.text('Unterseite'), findsNothing);
  });

  group('camera area', () {
    test('the viewfinder window is centred and fits', () {
      for (final size in [
        const Size(360, 380),
        const Size(800, 300),
        const Size(300, 120),
      ]) {
        final window = ScannerViewfinder.windowRect(size);
        expect(window.center, size.center(Offset.zero));
        expect(window.width, lessThanOrEqualTo(size.width * 0.8));
        expect(window.height, lessThanOrEqualTo(size.height * 0.5));
        expect((Offset.zero & size).contains(window.topLeft), isTrue);
      }
    });

    testWidgets('frame and viewfinder paint in light and dark', (tester) async {
      for (final brightness in Brightness.values) {
        await pump(
          tester,
          const SizedBox(
            height: 300,
            child: CameraArea(child: ScannerViewfinder()),
          ),
          brightness: brightness,
        );
        expect(find.byType(ScannerViewfinder), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });
  });
}
