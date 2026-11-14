import 'dart:math' as math;

import 'package:cupertino_ui/cupertino_ui.dart'
    show CupertinoPageTransitionsBuilder;
import 'package:material_ui/material_ui.dart';

// The visual language of the app (design C "Lebendig", see
// .notes/design/design-c.md): own font, own colours, soft rounded shapes.
// Screens never type colours or radii themselves – they use the tokens here
// and the shared widgets in lib/core/widgets/.

/// The font of the whole app (bundled in assets/fonts/, licence in OFL.txt).
const appFontFamily = 'Nunito';

/// Numbers with equal widths, so "1.240" does not jump while it changes.
const tabularFigures = [FontFeature.tabularFigures()];

/// Spacing steps. Use these instead of random numbers so the app looks even.
abstract final class Spacing {
  static const double xs = 4;
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 24;
  static const double xxl = 32;

  /// Side padding of hero headers (a bit more air than lists).
  static const double page = 20;

  /// Empty space at the end of a list with a floating button, so the button
  /// never hides the last row.
  static const double belowFab = 96;
}

/// Corner radii. The named ones say where they belong; `s`…`xl` are general
/// steps for everything else.
abstract final class Radii {
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 24;

  /// Small squares: icon boxes, the "+" button on a meal tile.
  static const double square = 12;

  /// Rounded square buttons (back button, icon buttons on the hero).
  static const double iconButton = 14;

  /// Text fields and the pills on the hero.
  static const double input = 16;

  /// The raised scan button in the navigation bar.
  static const double scanButton = 18;

  /// Buttons and the rating rows on the product page.
  static const double button = 20;

  /// White cards.
  static const double card = 24;

  /// Meal tiles on the Today tab.
  static const double tile = 26;

  /// Top corners of bottom sheets and the navigation bar, dialogs.
  static const double sheet = 28;

  /// Bottom corners of the green hero header.
  static const double hero = 36;

  /// Fully round ends (pills, chips).
  static const double pill = 999;
}

/// Background and icon colour of one meal tile.
@immutable
class MealPalette {
  const MealPalette(this.background, this.icon);

  final Color background;
  final Color icon;

  static MealPalette lerp(MealPalette a, MealPalette b, double t) =>
      MealPalette(
        Color.lerp(a.background, b.background, t)!,
        Color.lerp(a.icon, b.icon, t)!,
      );
}

/// All colours of the app, for light and dark mode.
///
/// Text colours were chosen so they have at least 4.5:1 contrast on the
/// backgrounds they are used on (checked in test/theme_test.dart).
///
/// Rating colours are only an *extra* hint. The app always shows an icon and a
/// word as well, so colour-blind people get the same information. Going over
/// the daily goal is never shown in a rating or error colour.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.ink,
    required this.inkMuted,
    required this.border,
    required this.brandDark,
    required this.brand,
    required this.heroStart,
    required this.heroMid,
    required this.heroEnd,
    required this.heroDecor,
    required this.heroGlass,
    required this.onHero,
    required this.cta,
    required this.onCta,
    required this.tonal,
    required this.onTonal,
    required this.navInactive,
    required this.snackAction,
    required this.shadow,
    required this.ratingLow,
    required this.ratingLowBg,
    required this.ratingMedium,
    required this.ratingMediumBg,
    required this.ratingHigh,
    required this.ratingHighBg,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.mealPalettes,
  });

  /// Page background behind cards.
  final Color background;

  /// Cards, sheets, dialogs and the navigation bar.
  final Color surface;

  /// Text fields on cards, progress tracks.
  final Color surfaceAlt;

  /// Main text and icons.
  final Color ink;

  /// Secondary text.
  final Color inkMuted;

  /// Thin lines: chip outlines, dividers (ink at 10 %).
  final Color border;

  final Color brandDark;

  /// The app green: active tab, text buttons, focus border, plus points.
  final Color brand;

  /// The three stops of the hero gradient (see [heroGradient]).
  final Color heroStart;
  final Color heroMid;
  final Color heroEnd;

  /// Decorative circles in the hero (never under text).
  final Color heroDecor;

  /// Translucent background of pills and buttons on the hero (macro pills,
  /// "Heute", Nutri-Score, back/star/arrow buttons). Slightly darker than the
  /// gradient: white text on a *lighter* (white) glass would stay below
  /// 4.5:1 on the light green.
  final Color heroGlass;

  /// Text and icons on the hero gradient.
  final Color onHero;

  /// Main buttons ("Hinzufügen") and selected pills.
  final Color cta;
  final Color onCta;

  /// Secondary buttons.
  final Color tonal;
  final Color onTonal;

  /// Labels and icons of the tabs that are not selected.
  final Color navInactive;

  /// The "Rückgängig" button on a SnackBar (SnackBars use [cta] colours).
  final Color snackAction;

  /// Shadow under cards and bars; transparent in dark mode, where the
  /// surface colour alone sets cards apart.
  final Color shadow;

  /// Rating "niedrig": text/icon colour and its background.
  final Color ratingLow;
  final Color ratingLowBg;

  /// Rating "mittel".
  final Color ratingMedium;
  final Color ratingMediumBg;

  /// Rating "hoch".
  final Color ratingHigh;
  final Color ratingHighBg;

  /// Colours of the three macro nutrients (bars and dots).
  final Color protein;
  final Color carbs;
  final Color fat;

  /// Meal tile colours: peach, mint, lavender, butter, sky, rose. See
  /// `mealPaletteIndex` in the diary feature for which meal gets which.
  final List<MealPalette> mealPalettes;

  /// The green hero gradient (150°, like the design mock-up).
  LinearGradient get heroGradient => LinearGradient(
    begin: const Alignment(-0.5, -0.87),
    end: const Alignment(0.5, 0.87),
    colors: [heroStart, heroMid, heroEnd],
    stops: const [0, 0.55, 1],
  );

  /// The gradient of the raised scan button (white icon on it).
  LinearGradient get scanGradient => LinearGradient(
    begin: const Alignment(-0.5, -0.87),
    end: const Alignment(0.5, 0.87),
    colors: [heroMid, heroEnd],
  );

  /// Soft shadow under white cards (none in dark mode).
  List<BoxShadow> get cardShadow => [
    BoxShadow(color: shadow, blurRadius: 18, offset: const Offset(0, 6)),
  ];

  /// Upward shadow of the navigation bar and sticky bottom buttons.
  List<BoxShadow> get barShadow => [
    BoxShadow(
      color: shadow.withValues(alpha: shadow.a * 1.4),
      blurRadius: 24,
      offset: const Offset(0, -8),
    ),
  ];

  // Colours with transparency are written as 0xAARRGGBB, e.g. ink at 10 %
  // = 0x1A102A1C (0x1A = 26 = 10 % of 255).
  static const light = AppColors(
    background: Color(0xFFF2F6EF),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFEEF3EB),
    ink: Color(0xFF102A1C),
    inkMuted: Color(0xFF4F6658),
    border: Color(0x1A102A1C),
    brandDark: Color(0xFF0E4D2F),
    brand: Color(0xFF1C7A4A),
    heroStart: Color(0xFF0E4D2F),
    heroMid: Color(0xFF1C7A4A),
    heroEnd: Color(0xFF2B8240),
    heroDecor: Color(0x389BE36D),
    heroGlass: Color(0x1F000000),
    onHero: Color(0xFFFFFFFF),
    cta: Color(0xFF102A1C),
    onCta: Color(0xFFFFFFFF),
    tonal: Color(0xFFD9F2DF),
    onTonal: Color(0xFF0E4D2F),
    navInactive: Color(0xFF5F7A6B),
    snackAction: Color(0xFF9FE0B4),
    shadow: Color(0x0F102A1C),
    ratingLow: Color(0xFF1D5E3A),
    ratingLowBg: Color(0xFFD9F2DF),
    ratingMedium: Color(0xFF7A5200),
    ratingMediumBg: Color(0xFFFFF0C7),
    ratingHigh: Color(0xFF9B2C12),
    ratingHighBg: Color(0xFFFFE0D6),
    protein: Color(0xFF3B7BE0),
    carbs: Color(0xFFC98A12),
    fat: Color(0xFF9B51D0),
    mealPalettes: [
      MealPalette(Color(0xFFFFE6CF), Color(0xFFA4521A)),
      MealPalette(Color(0xFFD9F2DF), Color(0xFF1C7A4A)),
      MealPalette(Color(0xFFE6E0FA), Color(0xFF5B45B0)),
      MealPalette(Color(0xFFFFF2BF), Color(0xFF7A5E00)),
      MealPalette(Color(0xFFD8ECFF), Color(0xFF1F5FA8)),
      MealPalette(Color(0xFFFFE0EA), Color(0xFFA8325E)),
    ],
  );

  static const dark = AppColors(
    background: Color(0xFF0B1711),
    surface: Color(0xFF14251B),
    surfaceAlt: Color(0xFF1B3024),
    ink: Color(0xFFE7F2EA),
    inkMuted: Color(0xFFA9BFB1),
    border: Color(0x1AE7F2EA),
    brandDark: Color(0xFF0A3320),
    brand: Color(0xFF3FAE6A),
    heroStart: Color(0xFF0A3320),
    heroMid: Color(0xFF145C38),
    heroEnd: Color(0xFF1F6E35),
    heroDecor: Color(0x1F9BE36D),
    heroGlass: Color(0x24000000),
    onHero: Color(0xFFFFFFFF),
    cta: Color(0xFFE7F2EA),
    onCta: Color(0xFF0B1711),
    tonal: Color(0xFF173626),
    onTonal: Color(0xFF9FE0B4),
    navInactive: Color(0xFF8FA79A),
    snackAction: Color(0xFF0E4D2F),
    shadow: Color(0x00000000),
    ratingLow: Color(0xFF9FE0B4),
    ratingLowBg: Color(0xFF163A25),
    ratingMedium: Color(0xFFFFD98A),
    ratingMediumBg: Color(0xFF3F3412),
    ratingHigh: Color(0xFFFFB4A0),
    ratingHighBg: Color(0xFF4A2219),
    protein: Color(0xFF8AB8F0),
    carbs: Color(0xFFF2C14E),
    fat: Color(0xFFD7A6EB),
    mealPalettes: [
      MealPalette(Color(0xFF3A2A1F), Color(0xFFFFB98A)),
      MealPalette(Color(0xFF173626), Color(0xFF8EE0A8)),
      MealPalette(Color(0xFF2A2540), Color(0xFFC3B5FF)),
      MealPalette(Color(0xFF393117), Color(0xFFFFD966)),
      MealPalette(Color(0xFF16283D), Color(0xFF9CC8FF)),
      MealPalette(Color(0xFF3D1B28), Color(0xFFFFB0CB)),
    ],
  );

  /// The tokens are fixed per brightness; there is nothing to change.
  @override
  AppColors copyWith() => this;

  /// Smoothly blends light and dark when the theme mode changes.
  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      background: mix(background, other.background),
      surface: mix(surface, other.surface),
      surfaceAlt: mix(surfaceAlt, other.surfaceAlt),
      ink: mix(ink, other.ink),
      inkMuted: mix(inkMuted, other.inkMuted),
      border: mix(border, other.border),
      brandDark: mix(brandDark, other.brandDark),
      brand: mix(brand, other.brand),
      heroStart: mix(heroStart, other.heroStart),
      heroMid: mix(heroMid, other.heroMid),
      heroEnd: mix(heroEnd, other.heroEnd),
      heroDecor: mix(heroDecor, other.heroDecor),
      heroGlass: mix(heroGlass, other.heroGlass),
      onHero: mix(onHero, other.onHero),
      cta: mix(cta, other.cta),
      onCta: mix(onCta, other.onCta),
      tonal: mix(tonal, other.tonal),
      onTonal: mix(onTonal, other.onTonal),
      navInactive: mix(navInactive, other.navInactive),
      snackAction: mix(snackAction, other.snackAction),
      shadow: mix(shadow, other.shadow),
      ratingLow: mix(ratingLow, other.ratingLow),
      ratingLowBg: mix(ratingLowBg, other.ratingLowBg),
      ratingMedium: mix(ratingMedium, other.ratingMedium),
      ratingMediumBg: mix(ratingMediumBg, other.ratingMediumBg),
      ratingHigh: mix(ratingHigh, other.ratingHigh),
      ratingHighBg: mix(ratingHighBg, other.ratingHighBg),
      protein: mix(protein, other.protein),
      carbs: mix(carbs, other.carbs),
      fat: mix(fat, other.fat),
      mealPalettes: [
        for (var i = 0; i < mealPalettes.length; i++)
          MealPalette.lerp(
            mealPalettes[i],
            other.mealPalettes[math.min(i, other.mealPalettes.length - 1)],
            t,
          ),
      ],
    );
  }
}

/// The text styles of the app (all Nunito, numbers in design-c.md):
///
/// | Style          | Size/weight | Used for                          |
/// |----------------|-------------|-----------------------------------|
/// | headlineMedium | 32 / 900    | big numbers (calorie ring)        |
/// | headlineSmall  | 26 / 900    | page and product titles           |
/// | titleLarge     | 20 / 900    | hero titles, app bars             |
/// | titleMedium    | 18 / 900    | section titles, sheet titles      |
/// | titleSmall     | 15 / 900    | tile names, button labels         |
/// | bodyLarge      | 15 / 700    | body text, list rows, text fields |
/// | bodyMedium     | 15 / 700    | default text                      |
/// | bodySmall      | 13 / 700    | secondary text (muted colour)     |
/// | labelLarge     | 15 / 800    | buttons                           |
/// | labelMedium    | 12 / 800    | small labels, pills, captions     |
/// | labelSmall     | 11 / 800    | navigation bar labels             |
TextTheme buildTextTheme(AppColors colors) {
  TextStyle style(double size, FontWeight weight, {Color? color}) => TextStyle(
    fontFamily: appFontFamily,
    fontSize: size,
    fontWeight: weight,
    color: color ?? colors.ink,
    letterSpacing: 0,
  );
  const black = FontWeight.w900;
  const extraBold = FontWeight.w800;
  const bold = FontWeight.w700;
  return TextTheme(
    displayLarge: style(48, black),
    displayMedium: style(40, black),
    displaySmall: style(36, black),
    headlineLarge: style(32, black),
    headlineMedium: style(
      32,
      black,
    ).copyWith(fontFeatures: tabularFigures, height: 1.1),
    headlineSmall: style(26, black).copyWith(height: 1.15),
    titleLarge: style(20, black),
    titleMedium: style(18, black),
    titleSmall: style(15, black),
    bodyLarge: style(15, bold),
    bodyMedium: style(15, bold),
    bodySmall: style(13, bold, color: colors.inkMuted),
    labelLarge: style(15, extraBold),
    labelMedium: style(12, extraBold),
    labelSmall: style(11, extraBold),
  );
}

/// Builds the light or dark theme of the app.
ThemeData buildTheme(Brightness brightness) {
  final colors = brightness == Brightness.light
      ? AppColors.light
      : AppColors.dark;
  final text = buildTextTheme(colors);
  final scheme =
      ColorScheme.fromSeed(
        seedColor: colors.brand,
        brightness: brightness,
      ).copyWith(
        primary: colors.brand,
        onPrimary: brightness == Brightness.light
            ? colors.surface
            : colors.background,
        primaryContainer: colors.tonal,
        onPrimaryContainer: colors.onTonal,
        secondary: colors.brand,
        secondaryContainer: colors.tonal,
        onSecondaryContainer: colors.onTonal,
        surface: colors.surface,
        onSurface: colors.ink,
        onSurfaceVariant: colors.inkMuted,
        surfaceContainerLowest: colors.surface,
        surfaceContainerLow: colors.surface,
        surfaceContainer: colors.surfaceAlt,
        surfaceContainerHigh: colors.surfaceAlt,
        surfaceContainerHighest: colors.surfaceAlt,
        outline: colors.inkMuted,
        outlineVariant: colors.border,
        inverseSurface: colors.cta,
        onInverseSurface: colors.onCta,
        inversePrimary: colors.snackAction,
        surfaceTint: Colors.transparent,
      );

  final buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(Radii.button),
  );
  const buttonPadding = EdgeInsets.symmetric(
    horizontal: Spacing.page,
    vertical: Spacing.m,
  );
  final buttonText = text.labelLarge!.copyWith(fontWeight: FontWeight.w900);
  final sheetShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(Radii.sheet),
  );
  // Selected pills/segments use the CTA colours, the others look like a
  // white pill with a thin outline.
  Color? pillBackground(Set<WidgetState> states) =>
      states.contains(WidgetState.selected) ? colors.cta : colors.surface;
  Color? pillForeground(Set<WidgetState> states) =>
      states.contains(WidgetState.selected) ? colors.onCta : colors.ink;
  BorderSide pillSide(Set<WidgetState> states) =>
      states.contains(WidgetState.selected)
      ? BorderSide(color: colors.cta)
      : BorderSide(color: colors.border);

  return ThemeData(
    brightness: brightness,
    colorScheme: scheme,
    fontFamily: appFontFamily,
    textTheme: text,
    scaffoldBackgroundColor: colors.background,
    canvasColor: colors.surface,
    dividerColor: colors.border,
    splashFactory: InkRipple.splashFactory,
    splashColor: colors.ink.withValues(alpha: 0.06),
    highlightColor: colors.ink.withValues(alpha: 0.04),
    iconTheme: IconThemeData(color: colors.ink),
    extensions: [colors],
    // iOS-style sliding pages on every platform (not the Android zoom).
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
        TargetPlatform.fuchsia: CupertinoPageTransitionsBuilder(),
      },
    ),
    // Rounded "‹" back arrow in every app bar.
    actionIconTheme: ActionIconThemeData(
      backButtonIconBuilder: (_) =>
          const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
      closeButtonIconBuilder: (_) => const Icon(Icons.close_rounded),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: colors.background,
      foregroundColor: colors.ink,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: text.titleLarge,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: colors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.card),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: colors.cta,
        foregroundColor: colors.onCta,
        disabledBackgroundColor: colors.ink.withValues(alpha: 0.12),
        disabledForegroundColor: colors.ink.withValues(alpha: 0.45),
        minimumSize: const Size(64, 48),
        padding: buttonPadding,
        shape: buttonShape,
        textStyle: buttonText,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.tonal,
        foregroundColor: colors.onTonal,
        elevation: 0,
        minimumSize: const Size(64, 48),
        padding: buttonPadding,
        shape: buttonShape,
        textStyle: buttonText,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.ink,
        backgroundColor: colors.surface,
        side: BorderSide(color: colors.border),
        minimumSize: const Size(64, 48),
        padding: buttonPadding,
        shape: buttonShape,
        textStyle: buttonText,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colors.brand,
        minimumSize: const Size(48, 48),
        shape: buttonShape,
        textStyle: text.labelLarge,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(foregroundColor: colors.ink),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colors.cta,
      foregroundColor: colors.onCta,
      elevation: 2,
      highlightElevation: 4,
      shape: buttonShape,
      extendedTextStyle: buttonText,
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith(pillBackground),
        foregroundColor: WidgetStateProperty.resolveWith(pillForeground),
        iconColor: WidgetStateProperty.resolveWith(pillForeground),
        side: WidgetStateProperty.resolveWith(pillSide),
        shape: const WidgetStatePropertyAll(StadiumBorder()),
        textStyle: WidgetStatePropertyAll(text.bodySmall),
        minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
      ),
    ),
    chipTheme: ChipThemeData(
      color: WidgetStateProperty.resolveWith(pillBackground),
      side: WidgetStateBorderSide.resolveWith(pillSide),
      shape: const StadiumBorder(),
      showCheckmark: false,
      labelStyle: text.bodySmall!.copyWith(
        color: WidgetStateColor.resolveWith(
          (states) => pillForeground(states) ?? colors.ink,
        ),
        fontWeight: FontWeight.w800,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.s,
        vertical: Spacing.xs,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors.surfaceAlt,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Spacing.l,
        vertical: Spacing.l,
      ),
      labelStyle: text.labelMedium!.copyWith(color: colors.inkMuted),
      floatingLabelStyle: text.labelMedium!.copyWith(color: colors.brand),
      hintStyle: text.bodyLarge!.copyWith(color: colors.inkMuted),
      suffixStyle: text.bodyLarge!.copyWith(
        fontWeight: FontWeight.w800,
        color: colors.inkMuted,
      ),
      prefixIconColor: colors.inkMuted,
      suffixIconColor: colors.inkMuted,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.input),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.input),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.input),
        borderSide: BorderSide(color: colors.brand, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.input),
        borderSide: BorderSide(color: scheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.input),
        borderSide: BorderSide(color: scheme.error, width: 2),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? colors.surface
            : colors.inkMuted,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? colors.brand
            : colors.surfaceAlt,
      ),
      trackOutlineColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? colors.brand
            : colors.border,
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: colors.inkMuted,
      titleTextStyle: text.bodyLarge!.copyWith(fontWeight: FontWeight.w800),
      subtitleTextStyle: text.bodySmall,
      leadingAndTrailingTextStyle: text.bodyLarge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.l),
      ),
    ),
    dividerTheme: DividerThemeData(color: colors.border, space: 1),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: colors.brand,
      linearTrackColor: colors.surfaceAlt,
      circularTrackColor: Colors.transparent,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      shape: sheetShape,
      titleTextStyle: text.titleMedium,
      contentTextStyle: text.bodyMedium,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: colors.surface,
      modalBackgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      dragHandleColor: colors.ink.withValues(alpha: 0.2),
      dragHandleSize: const Size(40, 5),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.sheet)),
      ),
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      shape: sheetShape,
      headerHeadlineStyle: text.headlineSmall,
    ),
    timePickerTheme: TimePickerThemeData(
      backgroundColor: colors.surface,
      shape: sheetShape,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: colors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.l),
      ),
      textStyle: text.bodyLarge,
    ),
    dropdownMenuTheme: DropdownMenuThemeData(textStyle: text.bodyLarge),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: colors.cta,
      contentTextStyle: text.bodyMedium!.copyWith(color: colors.onCta),
      actionTextColor: colors.snackAction,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.l),
      ),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: colors.cta,
        borderRadius: BorderRadius.circular(Radii.s),
      ),
      textStyle: text.labelMedium!.copyWith(color: colors.onCta),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: colors.brand,
      selectionHandleColor: colors.brand,
      selectionColor: colors.brand.withValues(alpha: 0.3),
    ),
  );
}

/// Short access to the app colours: `context.appColors.ratingHigh`.
extension AppColorsContext on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}
