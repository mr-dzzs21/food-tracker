import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_tracker/core/licenses.dart';
import 'package:food_tracker/core/theme/app_theme.dart';
import 'package:material_ui/material_ui.dart';

/// WCAG contrast ratio between two opaque colours (1.0 – 21.0).
double contrastRatio(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final lighter = la > lb ? la : lb;
  final darker = la > lb ? lb : la;
  return (lighter + 0.05) / (darker + 0.05);
}

/// [top] (may be translucent) painted over the opaque [bottom].
Color over(Color top, Color bottom) => Color.alphaBlend(top, bottom);

void main() {
  for (final (name, colors) in [
    ('light', AppColors.light),
    ('dark', AppColors.dark),
  ]) {
    group('contrast ($name)', () {
      void expectReadable(
        Color text,
        Color background, {
        double minimum = 4.5,
        required String what,
      }) {
        expect(
          contrastRatio(text, background),
          greaterThanOrEqualTo(minimum),
          reason: '$what: $text on $background',
        );
      }

      test('text on backgrounds, cards, inputs and meal tiles', () {
        final backgrounds = {
          'background': colors.background,
          'surface': colors.surface,
          'surfaceAlt': colors.surfaceAlt,
          for (final (i, palette) in colors.mealPalettes.indexed)
            'meal tile $i': palette.background,
        };
        for (final MapEntry(key: where, value: background)
            in backgrounds.entries) {
          expectReadable(colors.ink, background, what: 'ink on $where');
          expectReadable(colors.inkMuted, background, what: 'muted on $where');
        }
      });

      test('rating words on their pills, also on cards', () {
        for (final (fg, bg) in [
          (colors.ratingLow, colors.ratingLowBg),
          (colors.ratingMedium, colors.ratingMediumBg),
          (colors.ratingHigh, colors.ratingHighBg),
        ]) {
          expectReadable(fg, bg, what: 'rating');
          expectReadable(fg, colors.surface, what: 'rating on surface');
          expectReadable(colors.ink, bg, what: 'ink on rating background');
        }
      });

      test('white text on the hero gradient and its glass pills', () {
        for (final stop in [colors.heroStart, colors.heroMid, colors.heroEnd]) {
          expectReadable(colors.onHero, stop, what: 'on hero');
          expectReadable(
            colors.onHero,
            over(colors.heroGlass, stop),
            what: 'on hero glass',
          );
          // Buttons and pills also where a decorative circle lies under
          // them (the top corner, next to the back/star buttons).
          expectReadable(
            colors.onHero,
            over(colors.heroGlass, over(colors.heroDecor, stop)),
            what: 'on hero glass over a circle',
          );
          // Large titles (≥ 18.66 px bold need 3:1) may touch a circle.
          expectReadable(
            colors.onHero,
            over(colors.heroDecor, stop),
            minimum: 3,
            what: 'large title over a circle',
          );
        }
      });

      test('buttons, navigation bar and links', () {
        expectReadable(colors.onCta, colors.cta, what: 'CTA');
        expectReadable(colors.onTonal, colors.tonal, what: 'tonal');
        expectReadable(colors.navInactive, colors.surface, what: 'tab');
        expectReadable(colors.brand, colors.surface, what: 'brand on card');
        expectReadable(colors.brand, colors.background, what: 'brand on page');
        expectReadable(colors.snackAction, colors.cta, what: 'undo button');
        // The white scan icon on the raised gradient button (graphic: 3:1).
        for (final stop in colors.scanGradient.colors) {
          expectReadable(colors.onHero, stop, minimum: 3, what: 'scan icon');
        }
      });

      test('text on the camera area, whatever the picture shows', () {
        expectReadable(colors.onCamera, colors.camera, what: 'camera');
        // The hint pill and the torch button lie on the picture: check the
        // worst cases, a white and a black picture.
        for (final picture in [const Color(0xFFFFFFFF), colors.camera]) {
          expectReadable(
            colors.onCamera,
            over(colors.cameraScrim, picture),
            what: 'on the camera scrim',
          );
        }
      });

      test('"Alle Daten löschen" in the rating colours', () {
        expectReadable(colors.ratingHigh, colors.surface, what: 'title');
        expectReadable(colors.ratingHigh, colors.ratingHighBg, what: 'icon');
      });
    });
  }

  group('theme', () {
    for (final brightness in Brightness.values) {
      test('uses the tokens and Nunito ($brightness)', () {
        final theme = buildTheme(brightness);
        final colors = theme.extension<AppColors>()!;
        expect(
          colors,
          brightness == Brightness.light ? AppColors.light : AppColors.dark,
        );
        expect(theme.scaffoldBackgroundColor, colors.background);
        expect(theme.colorScheme.primary, colors.brand);
        expect(theme.colorScheme.surface, colors.surface);
        expect(theme.textTheme.bodyMedium!.fontFamily, appFontFamily);
        expect(theme.textTheme.headlineMedium!.fontSize, 32);
        expect(theme.textTheme.headlineMedium!.fontWeight, FontWeight.w900);
        expect(theme.textTheme.headlineSmall!.fontSize, 26);
        expect(theme.textTheme.labelSmall!.fontSize, 11);
        // Main buttons use the CTA colours.
        final filled = theme.filledButtonTheme.style!;
        expect(filled.backgroundColor!.resolve({}), colors.cta);
        expect(filled.foregroundColor!.resolve({}), colors.onCta);
        // iOS-style page transitions everywhere.
        for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
          expect(
            theme.pageTransitionsTheme.builders[platform].runtimeType
                .toString(),
            'CupertinoPageTransitionsBuilder',
          );
        }
      });
    }

    test('the dark theme blends smoothly from the light one', () {
      final halfway = AppColors.light.lerp(AppColors.dark, 0.5);
      expect(halfway.mealPalettes, hasLength(6));
      expect(halfway.background, isNot(AppColors.light.background));
      expect(AppColors.light.lerp(AppColors.dark, 1).ink, AppColors.dark.ink);
    });
  });

  test('the Nunito licence is on the licence page', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerAppLicenses();
    final entries = await LicenseRegistry.licenses.toList();
    final nunito = entries.where((e) => e.packages.contains('Nunito'));
    expect(nunito, isNotEmpty);
    expect(
      nunito.first.paragraphs.map((p) => p.text).join(' '),
      contains('SIL OPEN FONT LICENSE'),
    );
  });
}
