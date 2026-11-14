import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// App name shown in the task switcher
  ///
  /// In en, this message translates to:
  /// **'Food Tracker'**
  String get appTitle;

  /// No description provided for @tabToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get tabToday;

  /// No description provided for @tabScan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get tabScan;

  /// No description provided for @tabStats.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get tabStats;

  /// No description provided for @tabProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get tabProfile;

  /// No description provided for @actionRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get actionRetry;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @actionUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get actionUndo;

  /// No description provided for @actionAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get actionAdd;

  /// No description provided for @actionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get actionEdit;

  /// No description provided for @actionClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionClose;

  /// No description provided for @actionOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get actionOk;

  /// No description provided for @mealBreakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get mealBreakfast;

  /// No description provided for @mealLunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get mealLunch;

  /// No description provided for @mealDinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get mealDinner;

  /// No description provided for @mealSnacks.
  ///
  /// In en, this message translates to:
  /// **'Snacks'**
  String get mealSnacks;

  /// No description provided for @failureInvalidBarcode.
  ///
  /// In en, this message translates to:
  /// **'This barcode looks invalid. Please scan it again.'**
  String get failureInvalidBarcode;

  /// No description provided for @failureNotFound.
  ///
  /// In en, this message translates to:
  /// **'We don\'t know this product yet. You can add it yourself.'**
  String get failureNotFound;

  /// No description provided for @failureNotFood.
  ///
  /// In en, this message translates to:
  /// **'This doesn\'t seem to be a food product.'**
  String get failureNotFood;

  /// No description provided for @failureIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Nutrition values are missing for this product. You can fill them in yourself.'**
  String get failureIncomplete;

  /// No description provided for @failureOffline.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. Your diary still works – product search needs internet.'**
  String get failureOffline;

  /// No description provided for @failureTimeout.
  ///
  /// In en, this message translates to:
  /// **'Open Food Facts isn\'t responding right now. Try again in a moment.'**
  String get failureTimeout;

  /// No description provided for @failureRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Too many requests in a short time. Wait a minute, then try again.'**
  String get failureRateLimited;

  /// No description provided for @failureServer.
  ///
  /// In en, this message translates to:
  /// **'Open Food Facts has a problem right now. Try again later.'**
  String get failureServer;

  /// No description provided for @failureMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Open Food Facts is unavailable right now (maintenance or high load). Try again later.'**
  String get failureMaintenance;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get errorGeneric;

  /// Shown instead of the name when Open Food Facts has no name for a product (the stored name is empty)
  ///
  /// In en, this message translates to:
  /// **'Unknown product'**
  String get productUnknownName;

  /// Temporary text for screens that are not built yet
  ///
  /// In en, this message translates to:
  /// **'This screen is being built.'**
  String get placeholderComingSoon;

  /// Fallback name of a user-added meal without a name
  ///
  /// In en, this message translates to:
  /// **'Meal'**
  String get mealUnnamed;

  /// Tooltip of the + button of a meal section
  ///
  /// In en, this message translates to:
  /// **'Add to {meal}'**
  String mealAddTooltip(String meal);

  /// Title of the selected day when it is today; date like '14. Nov.'
  ///
  /// In en, this message translates to:
  /// **'Today, {date}'**
  String dayTitleToday(String date);

  /// No description provided for @dayTitleYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday, {date}'**
  String dayTitleYesterday(String date);

  /// No description provided for @dayTitleTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow, {date}'**
  String dayTitleTomorrow(String date);

  /// Tooltip of the left arrow in the date switcher
  ///
  /// In en, this message translates to:
  /// **'Previous day'**
  String get dayPrevious;

  /// Tooltip of the right arrow in the date switcher
  ///
  /// In en, this message translates to:
  /// **'Next day'**
  String get dayNext;

  /// Tooltip/semantics of the date title (opens a date picker)
  ///
  /// In en, this message translates to:
  /// **'Choose a day'**
  String get dayPick;

  /// Button that jumps back to today in the date switcher
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dayJumpToday;

  /// No description provided for @todayGoalCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Set a goal'**
  String get todayGoalCardTitle;

  /// No description provided for @todayGoalCardText.
  ///
  /// In en, this message translates to:
  /// **'With a daily goal, the ring shows how much is left for today.'**
  String get todayGoalCardText;

  /// No description provided for @todayGoalCardButton.
  ///
  /// In en, this message translates to:
  /// **'Set goal'**
  String get todayGoalCardButton;

  /// Tooltip of the close button on the goal card
  ///
  /// In en, this message translates to:
  /// **'Hide this hint'**
  String get todayGoalCardDismiss;

  /// Small label under the big number in the calorie ring
  ///
  /// In en, this message translates to:
  /// **'kcal left'**
  String get todayRingLeft;

  /// Small label under the big number in the calorie ring (no goal set)
  ///
  /// In en, this message translates to:
  /// **'kcal eaten'**
  String get todayRingEaten;

  /// Small label under the big number when more was eaten than the goal. Neutral wording, never 'failed'.
  ///
  /// In en, this message translates to:
  /// **'kcal above your goal'**
  String get todayRingOver;

  /// Under the remaining kcal, e.g. 'von 2.490'
  ///
  /// In en, this message translates to:
  /// **'of {goal}'**
  String todayRingOfGoal(String goal);

  /// Screen reader sentence for the calorie ring
  ///
  /// In en, this message translates to:
  /// **'{left} kcal left of {goal} kcal. Eaten: {eaten} kcal.'**
  String todayRingSemanticsLeft(String left, String goal, String eaten);

  /// Screen reader sentence for the calorie ring
  ///
  /// In en, this message translates to:
  /// **'{over} kcal above your goal of {goal} kcal. Eaten: {eaten} kcal.'**
  String todayRingSemanticsOver(String over, String goal, String eaten);

  /// Screen reader sentence for the calorie ring
  ///
  /// In en, this message translates to:
  /// **'{eaten} kcal eaten. No daily goal set.'**
  String todayRingSemanticsEaten(String eaten);

  /// No description provided for @todayEatenLine.
  ///
  /// In en, this message translates to:
  /// **'Eaten: {eaten} kcal'**
  String todayEatenLine(String eaten);

  /// Hint when some entries have no value for a nutrient, so totals are 'at least'
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Values are missing for 1 entry} other{Values are missing for {count} entries}}'**
  String todayMissingValues(int count);

  /// No description provided for @todayEmptyDay.
  ///
  /// In en, this message translates to:
  /// **'Nothing logged yet. Tap + next to a meal to add food.'**
  String get todayEmptyDay;

  /// Macro bar value with a goal, e.g. '45 von 120 g'
  ///
  /// In en, this message translates to:
  /// **'{eaten} of {goal} g'**
  String todayMacroOfGoal(String eaten, String goal);

  /// A nutrient with its value, e.g. 'Eiweiß: 45 g'
  ///
  /// In en, this message translates to:
  /// **'{nutrient}: {value}'**
  String nutrientWithValue(String nutrient, String value);

  /// A sum where some entries have no value
  ///
  /// In en, this message translates to:
  /// **'at least {value}'**
  String totalAtLeast(String value);

  /// Remaining kcal when some entries have no value
  ///
  /// In en, this message translates to:
  /// **'at most {value}'**
  String totalAtMost(String value);

  /// No description provided for @unitGrams.
  ///
  /// In en, this message translates to:
  /// **'{value} g'**
  String unitGrams(String value);

  /// No description provided for @unitKcal.
  ///
  /// In en, this message translates to:
  /// **'{value} kcal'**
  String unitKcal(String value);

  /// No description provided for @diaryEntryDeleted.
  ///
  /// In en, this message translates to:
  /// **'Entry deleted'**
  String get diaryEntryDeleted;

  /// No description provided for @entryAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get entryAmountLabel;

  /// No description provided for @entryMealLabel.
  ///
  /// In en, this message translates to:
  /// **'Meal'**
  String get entryMealLabel;

  /// Error under the amount field
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount between 0 and 10,000.'**
  String get amountInvalid;

  /// No description provided for @nutrientKcal.
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get nutrientKcal;

  /// No description provided for @nutrientFat.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get nutrientFat;

  /// No description provided for @nutrientSaturatedFat.
  ///
  /// In en, this message translates to:
  /// **'Saturates'**
  String get nutrientSaturatedFat;

  /// No description provided for @nutrientCarbs.
  ///
  /// In en, this message translates to:
  /// **'Carbohydrate'**
  String get nutrientCarbs;

  /// No description provided for @nutrientSugars.
  ///
  /// In en, this message translates to:
  /// **'Sugars'**
  String get nutrientSugars;

  /// No description provided for @nutrientFibre.
  ///
  /// In en, this message translates to:
  /// **'Fibre'**
  String get nutrientFibre;

  /// No description provided for @nutrientProtein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get nutrientProtein;

  /// No description provided for @nutrientSalt.
  ///
  /// In en, this message translates to:
  /// **'Salt'**
  String get nutrientSalt;

  /// No description provided for @ratingLevelLow.
  ///
  /// In en, this message translates to:
  /// **'low'**
  String get ratingLevelLow;

  /// No description provided for @ratingLevelMedium.
  ///
  /// In en, this message translates to:
  /// **'medium'**
  String get ratingLevelMedium;

  /// Neutral word: 'viel/hoch', never 'bad'
  ///
  /// In en, this message translates to:
  /// **'high'**
  String get ratingLevelHigh;

  /// No description provided for @ratingNoData.
  ///
  /// In en, this message translates to:
  /// **'no data'**
  String get ratingNoData;

  /// No description provided for @ratingTitle.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get ratingTitle;

  /// No description provided for @ratingTitleFood.
  ///
  /// In en, this message translates to:
  /// **'Rating per 100 g'**
  String get ratingTitleFood;

  /// No description provided for @ratingTitleDrink.
  ///
  /// In en, this message translates to:
  /// **'Rating per 100 ml'**
  String get ratingTitleDrink;

  /// Screen reader text of one rating row, e.g. 'Fett: hoch, 33 g'
  ///
  /// In en, this message translates to:
  /// **'{nutrient}: {level}, {value}'**
  String ratingRowSemantics(String nutrient, String level, String value);

  /// No description provided for @ratingNotRated.
  ///
  /// In en, this message translates to:
  /// **'This type of product gets no traffic-light rating (e.g. water, coffee, tea, spices, baby food, alcohol). You can see the nutrition values below.'**
  String get ratingNotRated;

  /// No description provided for @ratingNoCategory.
  ///
  /// In en, this message translates to:
  /// **'The product type is unknown, so there is no traffic-light rating.'**
  String get ratingNoCategory;

  /// No description provided for @ratingSuspicious.
  ///
  /// In en, this message translates to:
  /// **'These values look inconsistent and may be wrong.'**
  String get ratingSuspicious;

  /// No description provided for @plusFibreSource.
  ///
  /// In en, this message translates to:
  /// **'source of fibre'**
  String get plusFibreSource;

  /// No description provided for @plusFibreHigh.
  ///
  /// In en, this message translates to:
  /// **'high in fibre'**
  String get plusFibreHigh;

  /// No description provided for @plusProteinSource.
  ///
  /// In en, this message translates to:
  /// **'source of protein'**
  String get plusProteinSource;

  /// No description provided for @plusProteinHigh.
  ///
  /// In en, this message translates to:
  /// **'high in protein'**
  String get plusProteinHigh;

  /// A plus point, e.g. 'Ballaststoffquelle · 4,5 g'
  ///
  /// In en, this message translates to:
  /// **'{label} · {value}'**
  String plusPointRow(String label, String value);

  /// Plain text only, no logo or colours
  ///
  /// In en, this message translates to:
  /// **'Nutri-Score: {grade} (according to Open Food Facts)'**
  String productNutriScore(String grade);

  /// Licence caption of a product photo
  ///
  /// In en, this message translates to:
  /// **'Photo: Open Food Facts contributors, CC BY-SA'**
  String get productImageCaption;

  /// No description provided for @productFavouriteAdd.
  ///
  /// In en, this message translates to:
  /// **'Add to favourites'**
  String get productFavouriteAdd;

  /// No description provided for @productFavouriteRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove from favourites'**
  String get productFavouriteRemove;

  /// No description provided for @productAmountTitle.
  ///
  /// In en, this message translates to:
  /// **'How much?'**
  String get productAmountTitle;

  /// No description provided for @productServingChip.
  ///
  /// In en, this message translates to:
  /// **'1 serving ({amount})'**
  String productServingChip(String amount);

  /// Chip with the amount used the last time this food was logged
  ///
  /// In en, this message translates to:
  /// **'Last time: {amount}'**
  String productLastAmountChip(String amount);

  /// No description provided for @productDay.
  ///
  /// In en, this message translates to:
  /// **'Day: {day}'**
  String productDay(String day);

  /// SnackBar after adding a food to the diary
  ///
  /// In en, this message translates to:
  /// **'Added to {meal}'**
  String productAdded(String meal);

  /// No description provided for @productNutritionTitle.
  ///
  /// In en, this message translates to:
  /// **'Nutrition facts'**
  String get productNutritionTitle;

  /// No description provided for @productPer100g.
  ///
  /// In en, this message translates to:
  /// **'per 100 g'**
  String get productPer100g;

  /// No description provided for @productPer100ml.
  ///
  /// In en, this message translates to:
  /// **'per 100 ml'**
  String get productPer100ml;

  /// No description provided for @productPerServing.
  ///
  /// In en, this message translates to:
  /// **'per serving ({amount})'**
  String productPerServing(String amount);

  /// No description provided for @productAttribution.
  ///
  /// In en, this message translates to:
  /// **'Data: Open Food Facts (ODbL)'**
  String get productAttribution;

  /// No description provided for @productCorrectHint.
  ///
  /// In en, this message translates to:
  /// **'Wrong data? You can correct it on Open Food Facts.'**
  String get productCorrectHint;

  /// No description provided for @productOpenOff.
  ///
  /// In en, this message translates to:
  /// **'View on Open Food Facts'**
  String get productOpenOff;

  /// No description provided for @productLinkFailed.
  ///
  /// In en, this message translates to:
  /// **'The link could not be opened.'**
  String get productLinkFailed;

  /// Button when Open Food Facts does not know a barcode
  ///
  /// In en, this message translates to:
  /// **'Add it yourself'**
  String get productCreateOwn;

  /// Button when a product has no calories
  ///
  /// In en, this message translates to:
  /// **'Complete the values'**
  String get productCompleteValues;

  /// No description provided for @productGone.
  ///
  /// In en, this message translates to:
  /// **'This food no longer exists.'**
  String get productGone;

  /// No description provided for @disclaimerShort.
  ///
  /// In en, this message translates to:
  /// **'Data from Open Food Facts. Values can be wrong. The rating is for guidance only and is not medical advice.'**
  String get disclaimerShort;

  /// Short disclaimer for own foods (no Open Food Facts data)
  ///
  /// In en, this message translates to:
  /// **'The rating is for guidance only and is not medical advice.'**
  String get disclaimerRating;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
