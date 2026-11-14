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

  /// Hint in the search field on the Scan tab
  ///
  /// In en, this message translates to:
  /// **'Search for a product'**
  String get searchFieldHint;

  /// Tooltip of the search button next to a search field
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchSubmit;

  /// No description provided for @scanRecentlyViewedTitle.
  ///
  /// In en, this message translates to:
  /// **'Recently viewed'**
  String get scanRecentlyViewedTitle;

  /// No description provided for @scanRecentlyViewedEmpty.
  ///
  /// In en, this message translates to:
  /// **'Products you scan or search for appear here.'**
  String get scanRecentlyViewedEmpty;

  /// Title of the full-screen scanner
  ///
  /// In en, this message translates to:
  /// **'Scan barcode'**
  String get scannerTitle;

  /// Hint over the camera preview
  ///
  /// In en, this message translates to:
  /// **'Point the camera at a barcode.'**
  String get scannerHint;

  /// Screen reader label of the camera area
  ///
  /// In en, this message translates to:
  /// **'Camera for scanning barcodes'**
  String get scannerPreviewLabel;

  /// Tooltip of the torch button
  ///
  /// In en, this message translates to:
  /// **'Turn on the light'**
  String get scannerTorchOn;

  /// Tooltip of the torch button
  ///
  /// In en, this message translates to:
  /// **'Turn off the light'**
  String get scannerTorchOff;

  /// No description provided for @scannerPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'No access to the camera'**
  String get scannerPermissionTitle;

  /// Shown when the camera permission was denied
  ///
  /// In en, this message translates to:
  /// **'To scan, allow camera access in your device settings (Settings › Food Tracker › Camera). Until then you can use the search.'**
  String get scannerPermissionText;

  /// Shown on devices without a camera (e.g. the simulator)
  ///
  /// In en, this message translates to:
  /// **'There is no camera here. Use the search.'**
  String get scannerUnsupported;

  /// No description provided for @scannerError.
  ///
  /// In en, this message translates to:
  /// **'The camera could not start. Try again or use the search.'**
  String get scannerError;

  /// Title of the search results page
  ///
  /// In en, this message translates to:
  /// **'Search: {query}'**
  String searchResultsTitle(String query);

  /// No description provided for @searchEmptyQuery.
  ///
  /// In en, this message translates to:
  /// **'Type what you are looking for.'**
  String get searchEmptyQuery;

  /// Section with matching foods already stored on the phone
  ///
  /// In en, this message translates to:
  /// **'On your device'**
  String get searchLocalTitle;

  /// Section with Open Food Facts search results
  ///
  /// In en, this message translates to:
  /// **'Online results'**
  String get searchOnlineTitle;

  /// No description provided for @searchNoOnlineResults.
  ///
  /// In en, this message translates to:
  /// **'No results at Open Food Facts.'**
  String get searchNoOnlineResults;

  /// No description provided for @searchNoResultsHint.
  ///
  /// In en, this message translates to:
  /// **'Check the spelling or add the food yourself.'**
  String get searchNoResultsHint;

  /// No description provided for @searchLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get searchLoadMore;

  /// Short Nutri-Score text in result lists (plain text, no logo)
  ///
  /// In en, this message translates to:
  /// **'Nutri-Score: {grade}'**
  String searchNutriScore(String grade);

  /// No description provided for @foodKcalPer100g.
  ///
  /// In en, this message translates to:
  /// **'{kcal} kcal per 100 g'**
  String foodKcalPer100g(String kcal);

  /// No description provided for @foodKcalPer100ml.
  ///
  /// In en, this message translates to:
  /// **'{kcal} kcal per 100 ml'**
  String foodKcalPer100ml(String kcal);

  /// No description provided for @foodKcalUnknown.
  ///
  /// In en, this message translates to:
  /// **'Calories unknown'**
  String get foodKcalUnknown;

  /// Title of the add-food page, e.g. 'Breakfast · Today, Nov 14'
  ///
  /// In en, this message translates to:
  /// **'{meal} · {day}'**
  String addFoodTitle(String meal, String day);

  /// No description provided for @addFoodSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search foods'**
  String get addFoodSearchHint;

  /// Button that opens the barcode scanner
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get addFoodScan;

  /// Button that opens the form for an own food
  ///
  /// In en, this message translates to:
  /// **'Own food'**
  String get addFoodCreateOwn;

  /// No description provided for @addFoodSegmentRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get addFoodSegmentRecent;

  /// No description provided for @addFoodSegmentFavourites.
  ///
  /// In en, this message translates to:
  /// **'Favourites'**
  String get addFoodSegmentFavourites;

  /// No description provided for @addFoodSegmentOwn.
  ///
  /// In en, this message translates to:
  /// **'My foods'**
  String get addFoodSegmentOwn;

  /// No description provided for @addFoodRecentEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet. Foods you add to your diary appear here.'**
  String get addFoodRecentEmpty;

  /// No description provided for @addFoodFavouritesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No favourites yet. Tap the star on a product page.'**
  String get addFoodFavouritesEmpty;

  /// No description provided for @addFoodOwnEmpty.
  ///
  /// In en, this message translates to:
  /// **'No own foods yet. Create one with “Own food”.'**
  String get addFoodOwnEmpty;

  /// No description provided for @addFoodNoLocalMatches.
  ///
  /// In en, this message translates to:
  /// **'Nothing found on your device. Tap “Search” on the keyboard to search online.'**
  String get addFoodNoLocalMatches;

  /// No description provided for @foodFormNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New food'**
  String get foodFormNewTitle;

  /// No description provided for @foodFormEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit food'**
  String get foodFormEditTitle;

  /// Label of a required field
  ///
  /// In en, this message translates to:
  /// **'{label} *'**
  String foodFormRequired(String label);

  /// No description provided for @foodFormRequiredHint.
  ///
  /// In en, this message translates to:
  /// **'* required'**
  String get foodFormRequiredHint;

  /// No description provided for @foodFormName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get foodFormName;

  /// No description provided for @foodFormBrand.
  ///
  /// In en, this message translates to:
  /// **'Brand (optional)'**
  String get foodFormBrand;

  /// No description provided for @foodFormBarcode.
  ///
  /// In en, this message translates to:
  /// **'Barcode'**
  String get foodFormBarcode;

  /// No description provided for @foodFormIsLiquid.
  ///
  /// In en, this message translates to:
  /// **'Drink (values per 100 ml)'**
  String get foodFormIsLiquid;

  /// No description provided for @foodFormNutrientsPer100g.
  ///
  /// In en, this message translates to:
  /// **'Nutrition per 100 g'**
  String get foodFormNutrientsPer100g;

  /// No description provided for @foodFormNutrientsPer100ml.
  ///
  /// In en, this message translates to:
  /// **'Nutrition per 100 ml'**
  String get foodFormNutrientsPer100ml;

  /// No description provided for @foodFormPortionTitle.
  ///
  /// In en, this message translates to:
  /// **'Portion (optional)'**
  String get foodFormPortionTitle;

  /// No description provided for @foodFormPortionSize.
  ///
  /// In en, this message translates to:
  /// **'Size of one portion'**
  String get foodFormPortionSize;

  /// No description provided for @foodFormPortionLabel.
  ///
  /// In en, this message translates to:
  /// **'Portion name'**
  String get foodFormPortionLabel;

  /// No description provided for @foodFormPortionLabelHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 1 slice'**
  String get foodFormPortionLabelHint;

  /// No description provided for @foodFormNameMissing.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name.'**
  String get foodFormNameMissing;

  /// No description provided for @foodFormKcalMissing.
  ///
  /// In en, this message translates to:
  /// **'Please enter the calories.'**
  String get foodFormKcalMissing;

  /// No description provided for @foodFormNotANumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a number.'**
  String get foodFormNotANumber;

  /// Error under a nutrient field; max is 100 (grams) or 900 (kcal)
  ///
  /// In en, this message translates to:
  /// **'Allowed: 0 to {max}'**
  String foodFormOutOfRange(String max);

  /// No description provided for @foodFormSaturatesAboveFat.
  ///
  /// In en, this message translates to:
  /// **'Can\'t be more than fat.'**
  String get foodFormSaturatesAboveFat;

  /// No description provided for @foodFormSugarsAboveCarbs.
  ///
  /// In en, this message translates to:
  /// **'Can\'t be more than carbohydrate.'**
  String get foodFormSugarsAboveCarbs;

  /// No description provided for @foodFormPortionSizeMissing.
  ///
  /// In en, this message translates to:
  /// **'Please also enter the size of one portion.'**
  String get foodFormPortionSizeMissing;

  /// No description provided for @foodFormDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete “{name}”?'**
  String foodFormDeleteTitle(String name);

  /// No description provided for @foodFormDeleteText.
  ///
  /// In en, this message translates to:
  /// **'Entries in your diary are kept.'**
  String get foodFormDeleteText;

  /// SnackBar after deleting an own food
  ///
  /// In en, this message translates to:
  /// **'“{name}” deleted'**
  String foodFormDeleted(String name);

  /// No description provided for @linkOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'The link could not be opened.'**
  String get linkOpenFailed;

  /// Disclaimer on the goal page and the about page
  ///
  /// In en, this message translates to:
  /// **'These are estimates for healthy adults. If you are ill, pregnant, breastfeeding or unsure, talk to a doctor or a registered dietitian.'**
  String get disclaimerGoals;

  /// No description provided for @helpEdTitle.
  ///
  /// In en, this message translates to:
  /// **'Help with eating disorders'**
  String get helpEdTitle;

  /// English: generic sentence plus the German service (there is no English helpline in the app)
  ///
  /// In en, this message translates to:
  /// **'If food or weight is weighing heavily on you, talk to someone you trust or a doctor. In Germany, the eating disorder helpline of the BIÖG (Federal Institute for Public Health) gives anonymous advice in German:'**
  String get helpEdText;

  /// Button that calls the helpline
  ///
  /// In en, this message translates to:
  /// **'Call {number}'**
  String helpEdCall(String number);

  /// Opening hours of the BIÖG helpline
  ///
  /// In en, this message translates to:
  /// **'Mon–Thu 10 am–10 pm, Fri–Sun 10 am–6 pm (German time)'**
  String get helpEdHours;

  /// No description provided for @helpEdWebsite.
  ///
  /// In en, this message translates to:
  /// **'Website: {address}'**
  String helpEdWebsite(String address);

  /// No description provided for @goalTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily goal'**
  String get goalTitle;

  /// No description provided for @goalModeCalculate.
  ///
  /// In en, this message translates to:
  /// **'Calculate'**
  String get goalModeCalculate;

  /// No description provided for @goalModeManual.
  ///
  /// In en, this message translates to:
  /// **'Enter myself'**
  String get goalModeManual;

  /// No description provided for @goalSexLabel.
  ///
  /// In en, this message translates to:
  /// **'Sex'**
  String get goalSexLabel;

  /// No description provided for @goalSexMale.
  ///
  /// In en, this message translates to:
  /// **'male'**
  String get goalSexMale;

  /// No description provided for @goalSexFemale.
  ///
  /// In en, this message translates to:
  /// **'female'**
  String get goalSexFemale;

  /// No description provided for @goalSexUnspecified.
  ///
  /// In en, this message translates to:
  /// **'not specified'**
  String get goalSexUnspecified;

  /// No description provided for @goalAgeLabel.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get goalAgeLabel;

  /// No description provided for @goalAgeSuffix.
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get goalAgeSuffix;

  /// No description provided for @goalHeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get goalHeightLabel;

  /// No description provided for @goalWeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get goalWeightLabel;

  /// No description provided for @goalAgeInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter an age from 1 to 120 years.'**
  String get goalAgeInvalid;

  /// No description provided for @goalHeightInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a height from 100 to 250 cm.'**
  String get goalHeightInvalid;

  /// No description provided for @goalWeightInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a weight from 30 to 300 kg.'**
  String get goalWeightInvalid;

  /// No description provided for @goalActivityLabel.
  ///
  /// In en, this message translates to:
  /// **'How active are you?'**
  String get goalActivityLabel;

  /// No description provided for @goalActivityLow.
  ///
  /// In en, this message translates to:
  /// **'Not very active'**
  String get goalActivityLow;

  /// No description provided for @goalActivityLowText.
  ///
  /// In en, this message translates to:
  /// **'Mostly sitting, little exercise in your free time'**
  String get goalActivityLowText;

  /// No description provided for @goalActivityLight.
  ///
  /// In en, this message translates to:
  /// **'Somewhat active'**
  String get goalActivityLight;

  /// No description provided for @goalActivityLightText.
  ///
  /// In en, this message translates to:
  /// **'Sitting, but regularly walking or cycling, or sport 1–2 times a week'**
  String get goalActivityLightText;

  /// No description provided for @goalActivityActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get goalActivityActive;

  /// No description provided for @goalActivityActiveText.
  ///
  /// In en, this message translates to:
  /// **'A lot of standing or walking at work, or sport 3–5 times a week'**
  String get goalActivityActiveText;

  /// No description provided for @goalActivityVeryActive.
  ///
  /// In en, this message translates to:
  /// **'Very active'**
  String get goalActivityVeryActive;

  /// No description provided for @goalActivityVeryActiveText.
  ///
  /// In en, this message translates to:
  /// **'Hard physical work or a lot of sport'**
  String get goalActivityVeryActiveText;

  /// No description provided for @goalTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Your goal'**
  String get goalTypeLabel;

  /// No description provided for @goalTypeMaintain.
  ///
  /// In en, this message translates to:
  /// **'Keep my weight'**
  String get goalTypeMaintain;

  /// No description provided for @goalTypeLoseSlow.
  ///
  /// In en, this message translates to:
  /// **'Lose slowly (0.25 kg/week)'**
  String get goalTypeLoseSlow;

  /// No description provided for @goalTypeLose.
  ///
  /// In en, this message translates to:
  /// **'Lose weight (0.5 kg/week)'**
  String get goalTypeLose;

  /// No description provided for @goalTypeGainSlow.
  ///
  /// In en, this message translates to:
  /// **'Gain slowly (0.25 kg/week)'**
  String get goalTypeGainSlow;

  /// No description provided for @goalResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Your result'**
  String get goalResultTitle;

  /// No description provided for @goalResultMissing.
  ///
  /// In en, this message translates to:
  /// **'Fill in age, height and weight to see your result here.'**
  String get goalResultMissing;

  /// Energy used at complete rest
  ///
  /// In en, this message translates to:
  /// **'Basal metabolic rate'**
  String get goalResultBmr;

  /// Basal rate × activity
  ///
  /// In en, this message translates to:
  /// **'Total need'**
  String get goalResultTotal;

  /// No description provided for @goalResultGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily goal'**
  String get goalResultGoal;

  /// A rounded estimate
  ///
  /// In en, this message translates to:
  /// **'approx. {kcal} kcal'**
  String goalApprox(String kcal);

  /// No description provided for @goalEstimateNote.
  ///
  /// In en, this message translates to:
  /// **'These are estimates. Your body adapts over time, so your weight usually changes more slowly than calculated.'**
  String get goalEstimateNote;

  /// Shown when the calculated goal was raised to the lower bound
  ///
  /// In en, this message translates to:
  /// **'We do not suggest less than {kcal} kcal per day.'**
  String goalFloorNote(String kcal);

  /// No description provided for @goalMinorTitle.
  ///
  /// In en, this message translates to:
  /// **'Note for under-18s'**
  String get goalMinorTitle;

  /// No description provided for @goalMinorText.
  ///
  /// In en, this message translates to:
  /// **'The formula was developed for adults. While you are still growing, you often need more energy. If you have questions, talk to your paediatrician or family doctor.'**
  String get goalMinorText;

  /// No description provided for @goalApply.
  ///
  /// In en, this message translates to:
  /// **'Use this goal'**
  String get goalApply;

  /// No description provided for @goalSaved.
  ///
  /// In en, this message translates to:
  /// **'Your daily goal has been saved.'**
  String get goalSaved;

  /// No description provided for @goalManualKcal.
  ///
  /// In en, this message translates to:
  /// **'Calories per day'**
  String get goalManualKcal;

  /// No description provided for @goalManualKcalInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a value from 1 to {max} kcal.'**
  String goalManualKcalInvalid(String max);

  /// No description provided for @goalManualMacrosTitle.
  ///
  /// In en, this message translates to:
  /// **'Macronutrients (optional)'**
  String get goalManualMacrosTitle;

  /// No description provided for @goalManualMacrosHint.
  ///
  /// In en, this message translates to:
  /// **'Empty fields are filled with defaults: 15 % protein, 30 % fat and the rest carbohydrates.'**
  String get goalManualMacrosHint;

  /// No description provided for @goalMacroInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a value from 0 to {max} g.'**
  String goalMacroInvalid(String max);

  /// No description provided for @goalBelowFloorTitle.
  ///
  /// In en, this message translates to:
  /// **'Less than {kcal} kcal?'**
  String goalBelowFloorTitle(String kcal);

  /// Gentle confirm dialog for a manual goal below the lower bound
  ///
  /// In en, this message translates to:
  /// **'Your goal is below {kcal} kcal per day. Eating this little for a longer time is best done with medical support. Do you want to save it anyway?'**
  String goalBelowFloorText(String kcal);

  /// No description provided for @goalBelowFloorChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get goalBelowFloorChange;

  /// No description provided for @goalBelowFloorSave.
  ///
  /// In en, this message translates to:
  /// **'Save anyway'**
  String get goalBelowFloorSave;

  /// No description provided for @profileSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileSettingsTitle;

  /// No description provided for @profileInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Help & info'**
  String get profileInfoTitle;

  /// No description provided for @profileGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Your daily goal'**
  String get profileGoalTitle;

  /// No description provided for @profileGoalNone.
  ///
  /// In en, this message translates to:
  /// **'No goal yet'**
  String get profileGoalNone;

  /// No description provided for @profileGoalNoneText.
  ///
  /// In en, this message translates to:
  /// **'With a goal, the ring on “Today” shows how much is left.'**
  String get profileGoalNoneText;

  /// No description provided for @profileGoalSet.
  ///
  /// In en, this message translates to:
  /// **'Set a goal'**
  String get profileGoalSet;

  /// No description provided for @profileGoalChange.
  ///
  /// In en, this message translates to:
  /// **'Change goal'**
  String get profileGoalChange;

  /// No description provided for @profileGoalKcal.
  ///
  /// In en, this message translates to:
  /// **'{kcal} kcal per day'**
  String profileGoalKcal(String kcal);

  /// No description provided for @profileTheme.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get profileTheme;

  /// No description provided for @profileLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguage;

  /// Theme or language follows the device setting
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get settingSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// Always written in German
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get languageGerman;

  /// Always written in English
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @profileAbout.
  ///
  /// In en, this message translates to:
  /// **'About the app & licences'**
  String get profileAbout;

  /// No description provided for @profileDeleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete all data'**
  String get profileDeleteAll;

  /// No description provided for @profileDeleteAllTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all data?'**
  String get profileDeleteAllTitle;

  /// No description provided for @profileDeleteAllText.
  ///
  /// In en, this message translates to:
  /// **'Your diary, your own and saved foods, your goal and your settings will be deleted, and the meals are reset. This cannot be undone.'**
  String get profileDeleteAllText;

  /// No description provided for @profileDeleteAllConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete everything'**
  String get profileDeleteAllConfirm;

  /// No description provided for @profileDeleteAllDone.
  ///
  /// In en, this message translates to:
  /// **'All data has been deleted.'**
  String get profileDeleteAllDone;

  /// No description provided for @mealsTitle.
  ///
  /// In en, this message translates to:
  /// **'Meals'**
  String get mealsTitle;

  /// Subtitle of the meals entry on the profile tab
  ///
  /// In en, this message translates to:
  /// **'Rename, hide, reorder'**
  String get mealsSubtitle;

  /// No description provided for @mealsHint.
  ///
  /// In en, this message translates to:
  /// **'Drag the handle to change the order. The time decides which meal is suggested when you add food.'**
  String get mealsHint;

  /// Start time of a meal, e.g. "ab 11:00"
  ///
  /// In en, this message translates to:
  /// **'from {time}'**
  String mealsStartTime(String time);

  /// No description provided for @mealsNoStartTime.
  ///
  /// In en, this message translates to:
  /// **'no time'**
  String get mealsNoStartTime;

  /// No description provided for @mealsHidden.
  ///
  /// In en, this message translates to:
  /// **'hidden'**
  String get mealsHidden;

  /// Screen reader label of the visibility switch
  ///
  /// In en, this message translates to:
  /// **'Show {meal}'**
  String mealsShow(String meal);

  /// Screen reader label of the drag handle
  ///
  /// In en, this message translates to:
  /// **'Move {meal}'**
  String mealsMove(String meal);

  /// No description provided for @mealsAdd.
  ///
  /// In en, this message translates to:
  /// **'Add meal'**
  String get mealsAdd;

  /// No description provided for @mealsEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit meal'**
  String get mealsEditTitle;

  /// No description provided for @mealsNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New meal'**
  String get mealsNewTitle;

  /// No description provided for @mealsNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get mealsNameLabel;

  /// Hint for built-in meals: an empty name restores the default
  ///
  /// In en, this message translates to:
  /// **'Leave empty for “{name}”'**
  String mealsNameDefaultHint(String name);

  /// No description provided for @mealsNameMissing.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name.'**
  String get mealsNameMissing;

  /// No description provided for @mealsStartTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Suggested from'**
  String get mealsStartTimeLabel;

  /// No description provided for @mealsPickTime.
  ///
  /// In en, this message translates to:
  /// **'Choose time'**
  String get mealsPickTime;

  /// No description provided for @mealsClearTime.
  ///
  /// In en, this message translates to:
  /// **'No time'**
  String get mealsClearTime;

  /// No description provided for @mealsLastVisible.
  ///
  /// In en, this message translates to:
  /// **'At least one meal must stay visible.'**
  String get mealsLastVisible;

  /// No description provided for @mealsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete “{meal}”?'**
  String mealsDeleteTitle(String meal);

  /// No description provided for @mealsDeleteText.
  ///
  /// In en, this message translates to:
  /// **'This meal has no diary entries and will be removed.'**
  String get mealsDeleteText;

  /// No description provided for @mealsDeleted.
  ///
  /// In en, this message translates to:
  /// **'“{meal}” deleted'**
  String mealsDeleted(String meal);

  /// No description provided for @mealsInUseTitle.
  ///
  /// In en, this message translates to:
  /// **'This meal is in use'**
  String get mealsInUseTitle;

  /// No description provided for @mealsInUseText.
  ///
  /// In en, this message translates to:
  /// **'Your diary has entries in “{meal}”. So that past days stay complete, it cannot be deleted – but you can hide it.'**
  String mealsInUseText(String meal);

  /// No description provided for @mealsInUseHide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get mealsInUseHide;

  /// No description provided for @myFoodsTitle.
  ///
  /// In en, this message translates to:
  /// **'My foods'**
  String get myFoodsTitle;

  /// No description provided for @myFoodsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No own foods yet'**
  String get myFoodsEmpty;

  /// No description provided for @myFoodsEmptyText.
  ///
  /// In en, this message translates to:
  /// **'Create foods that Open Food Facts does not know – for example something you cooked yourself.'**
  String get myFoodsEmptyText;

  /// No description provided for @myFoodsCreate.
  ///
  /// In en, this message translates to:
  /// **'Create own food'**
  String get myFoodsCreate;

  /// Tooltip of the menu button of one own food
  ///
  /// In en, this message translates to:
  /// **'More for {name}'**
  String myFoodsMore(String name);

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About the app'**
  String get aboutTitle;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String aboutVersion(String version);

  /// No description provided for @aboutOpenSource.
  ///
  /// In en, this message translates to:
  /// **'Open source (MIT)'**
  String get aboutOpenSource;

  /// No description provided for @aboutOpenSourceText.
  ///
  /// In en, this message translates to:
  /// **'The source code is public. You may read it, improve it and share it.'**
  String get aboutOpenSourceText;

  /// No description provided for @aboutSourceCode.
  ///
  /// In en, this message translates to:
  /// **'Source code on GitHub'**
  String get aboutSourceCode;

  /// No description provided for @aboutDataSourceTitle.
  ///
  /// In en, this message translates to:
  /// **'Data source'**
  String get aboutDataSourceTitle;

  /// Full Open Food Facts attribution (required by the licence)
  ///
  /// In en, this message translates to:
  /// **'Product data comes from Open Food Facts (openfoodfacts.org) and is available under the Open Database License (ODbL); individual contents under the Database Contents License (DbCL), product photos under Creative Commons BY-SA. The data is maintained by volunteers and may be incomplete or wrong – when in doubt, check the package.'**
  String get aboutDataSourceText;

  /// No description provided for @aboutOpenOff.
  ///
  /// In en, this message translates to:
  /// **'Open openfoodfacts.org'**
  String get aboutOpenOff;

  /// No description provided for @aboutNotesTitle.
  ///
  /// In en, this message translates to:
  /// **'Good to know'**
  String get aboutNotesTitle;

  /// No description provided for @aboutPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get aboutPrivacyTitle;

  /// No description provided for @aboutPrivacyText.
  ///
  /// In en, this message translates to:
  /// **'All data stays on your device. The app has no account, no ads and no tracking. Only product searches are sent to Open Food Facts.'**
  String get aboutPrivacyText;

  /// No description provided for @aboutLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open-source licences'**
  String get aboutLicenses;

  /// Title of the statistics page for the current week
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get statsThisWeek;

  /// Title of a past week; week = ISO week number, range like 'Nov 2–8'
  ///
  /// In en, this message translates to:
  /// **'Week {week} · {range}'**
  String statsWeekTitle(String week, String range);

  /// Title of a week of another year, e.g. 'KW 46/2025 · 10.–16. Nov.'
  ///
  /// In en, this message translates to:
  /// **'Week {week}/{year} · {range}'**
  String statsWeekTitleWithYear(String week, String year, String range);

  /// Days of a week inside one month; first/last = day numbers, month = short month name ('Nov' / 'Nov.')
  ///
  /// In en, this message translates to:
  /// **'{month} {first}–{last}'**
  String statsRangeSameMonth(String first, String last, String month);

  /// Days of a week across two months; first/last like 'Oct 26' / '26. Okt.'
  ///
  /// In en, this message translates to:
  /// **'{first} – {last}'**
  String statsRangeTwoMonths(String first, String last);

  /// Tooltip of the left arrow on the statistics page
  ///
  /// In en, this message translates to:
  /// **'Previous week'**
  String get statsPreviousWeek;

  /// Tooltip of the right arrow on the statistics page
  ///
  /// In en, this message translates to:
  /// **'Next week'**
  String get statsNextWeek;

  /// No description provided for @statsChartTitle.
  ///
  /// In en, this message translates to:
  /// **'Calories per day'**
  String get statsChartTitle;

  /// Legend under the week chart
  ///
  /// In en, this message translates to:
  /// **'Line: your daily goal ({goal} kcal)'**
  String statsGoalLine(String goal);

  /// Screen reader text of the week chart; days = comma-separated list of statsDay* texts
  ///
  /// In en, this message translates to:
  /// **'Calories per day: {days}.'**
  String statsChartSemantics(String days);

  /// Added to the screen reader text of the week chart when a goal is set
  ///
  /// In en, this message translates to:
  /// **'Daily goal: {goal} kcal.'**
  String statsChartSemanticsGoal(String goal);

  /// One day in the screen reader text of the week chart, e.g. 'Montag 1.850 kcal'
  ///
  /// In en, this message translates to:
  /// **'{day} {kcal} kcal'**
  String statsDayKcal(String day, String kcal);

  /// No description provided for @statsDayNoEntries.
  ///
  /// In en, this message translates to:
  /// **'{day} no entries'**
  String statsDayNoEntries(String day);

  /// A day whose entries all have no kcal value
  ///
  /// In en, this message translates to:
  /// **'{day} kcal unknown'**
  String statsDayKcalUnknown(String day);

  /// Tile title; Ø means average
  ///
  /// In en, this message translates to:
  /// **'Ø kcal per day'**
  String get statsAverageKcalTitle;

  /// Screen reader text of the average tile (Ø is not read well)
  ///
  /// In en, this message translates to:
  /// **'Average: {value} kcal per day'**
  String statsAverageKcalSemantics(String value);

  /// No description provided for @statsDaysLoggedTitle.
  ///
  /// In en, this message translates to:
  /// **'Days with entries'**
  String get statsDaysLoggedTitle;

  /// Number of days in the week with at least one entry
  ///
  /// In en, this message translates to:
  /// **'{count} of 7'**
  String statsDaysLoggedValue(String count);

  /// Title of the card with average protein, carbs and fat
  ///
  /// In en, this message translates to:
  /// **'Ø per day'**
  String get statsAverageMacrosTitle;

  /// No description provided for @statsAverageMacroSemantics.
  ///
  /// In en, this message translates to:
  /// **'Average {nutrient}: {value} per day'**
  String statsAverageMacroSemantics(String nutrient, String value);

  /// No description provided for @statsAverageNote.
  ///
  /// In en, this message translates to:
  /// **'Averages only count the days with entries.'**
  String get statsAverageNote;

  /// No description provided for @statsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No entries this week'**
  String get statsEmptyTitle;

  /// No description provided for @statsEmptyText.
  ///
  /// In en, this message translates to:
  /// **'As soon as you log something, you\'ll see your week here.'**
  String get statsEmptyText;
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
