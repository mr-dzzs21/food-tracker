// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Food Tracker';

  @override
  String get tabToday => 'Today';

  @override
  String get tabScan => 'Scan';

  @override
  String get tabStats => 'Statistics';

  @override
  String get tabProfile => 'Profile';

  @override
  String get actionRetry => 'Try again';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionSave => 'Save';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionUndo => 'Undo';

  @override
  String get actionAdd => 'Add';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionClose => 'Close';

  @override
  String get actionOk => 'OK';

  @override
  String get mealBreakfast => 'Breakfast';

  @override
  String get mealLunch => 'Lunch';

  @override
  String get mealDinner => 'Dinner';

  @override
  String get mealSnacks => 'Snacks';

  @override
  String get failureInvalidBarcode =>
      'This barcode looks invalid. Please scan it again.';

  @override
  String get failureNotFound =>
      'We don\'t know this product yet. You can add it yourself.';

  @override
  String get failureNotFood => 'This doesn\'t seem to be a food product.';

  @override
  String get failureIncomplete =>
      'Nutrition values are missing for this product. You can fill them in yourself.';

  @override
  String get failureOffline =>
      'You\'re offline. Your diary still works – product search needs internet.';

  @override
  String get failureTimeout =>
      'Open Food Facts isn\'t responding right now. Try again in a moment.';

  @override
  String get failureRateLimited =>
      'Too many requests in a short time. Wait a minute, then try again.';

  @override
  String get failureServer =>
      'Open Food Facts has a problem right now. Try again later.';

  @override
  String get failureMaintenance =>
      'Open Food Facts is unavailable right now (maintenance or high load). Try again later.';

  @override
  String get errorGeneric => 'Something went wrong.';

  @override
  String get placeholderComingSoon => 'This screen is being built.';
}
