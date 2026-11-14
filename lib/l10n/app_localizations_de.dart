// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Food Tracker';

  @override
  String get tabToday => 'Heute';

  @override
  String get tabScan => 'Scannen';

  @override
  String get tabStats => 'Statistik';

  @override
  String get tabProfile => 'Profil';

  @override
  String get actionRetry => 'Nochmal versuchen';

  @override
  String get actionCancel => 'Abbrechen';

  @override
  String get actionSave => 'Speichern';

  @override
  String get actionDelete => 'Löschen';

  @override
  String get actionUndo => 'Rückgängig';

  @override
  String get actionAdd => 'Hinzufügen';

  @override
  String get actionEdit => 'Bearbeiten';

  @override
  String get actionClose => 'Schließen';

  @override
  String get actionOk => 'OK';

  @override
  String get mealBreakfast => 'Frühstück';

  @override
  String get mealLunch => 'Mittagessen';

  @override
  String get mealDinner => 'Abendessen';

  @override
  String get mealSnacks => 'Snacks';

  @override
  String get failureInvalidBarcode =>
      'Dieser Barcode sieht ungültig aus. Scanne ihn bitte noch einmal.';

  @override
  String get failureNotFound =>
      'Dieses Produkt kennen wir noch nicht. Du kannst es selbst eintragen.';

  @override
  String get failureNotFood => 'Das scheint kein Lebensmittel zu sein.';

  @override
  String get failureIncomplete =>
      'Für dieses Produkt fehlen Nährwerte. Du kannst sie selbst ergänzen.';

  @override
  String get failureOffline =>
      'Du bist offline. Dein Tagebuch funktioniert weiter – für die Produktsuche brauchst du Internet.';

  @override
  String get failureTimeout =>
      'Open Food Facts antwortet gerade nicht. Versuch es gleich noch mal.';

  @override
  String get failureRateLimited =>
      'Zu viele Anfragen in kurzer Zeit. Warte eine Minute und versuch es dann noch mal.';

  @override
  String get failureServer =>
      'Bei Open Food Facts gibt es gerade ein Problem. Versuch es später noch mal.';

  @override
  String get failureMaintenance =>
      'Open Food Facts ist gerade nicht erreichbar (Wartung oder Überlastung). Versuch es später noch mal.';

  @override
  String get errorGeneric => 'Etwas ist schiefgelaufen.';

  @override
  String get productUnknownName => 'Unbekanntes Produkt';

  @override
  String get placeholderComingSoon => 'Dieser Bildschirm entsteht gerade.';

  @override
  String get mealUnnamed => 'Mahlzeit';

  @override
  String mealAddTooltip(String meal) {
    return 'Zu $meal hinzufügen';
  }

  @override
  String dayTitleToday(String date) {
    return 'Heute, $date';
  }

  @override
  String dayTitleYesterday(String date) {
    return 'Gestern, $date';
  }

  @override
  String dayTitleTomorrow(String date) {
    return 'Morgen, $date';
  }

  @override
  String get dayPrevious => 'Vorheriger Tag';

  @override
  String get dayNext => 'Nächster Tag';

  @override
  String get dayPick => 'Tag auswählen';

  @override
  String get dayJumpToday => 'Heute';

  @override
  String get todayGoalCardTitle => 'Ziel festlegen';

  @override
  String get todayGoalCardText =>
      'Mit einem Tagesziel zeigt dir der Ring, wie viel heute noch übrig ist.';

  @override
  String get todayGoalCardButton => 'Ziel festlegen';

  @override
  String get todayGoalCardDismiss => 'Hinweis ausblenden';

  @override
  String get todayRingLeft => 'kcal übrig';

  @override
  String get todayRingEaten => 'kcal gegessen';

  @override
  String get todayRingOver => 'kcal über deinem Ziel';

  @override
  String todayRingOfGoal(String goal) {
    return 'von $goal';
  }

  @override
  String todayRingSemanticsLeft(String left, String goal, String eaten) {
    return '$left kcal übrig von $goal kcal. Gegessen: $eaten kcal.';
  }

  @override
  String todayRingSemanticsOver(String over, String goal, String eaten) {
    return '$over kcal über deinem Ziel von $goal kcal. Gegessen: $eaten kcal.';
  }

  @override
  String todayRingSemanticsEaten(String eaten) {
    return '$eaten kcal gegessen. Kein Tagesziel festgelegt.';
  }

  @override
  String todayEatenLine(String eaten) {
    return 'Gegessen: $eaten kcal';
  }

  @override
  String todayMissingValues(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Für $count Einträge fehlen Angaben',
      one: 'Für 1 Eintrag fehlen Angaben',
    );
    return '$_temp0';
  }

  @override
  String get todayEmptyDay =>
      'Noch nichts eingetragen. Tippe bei einer Mahlzeit auf +, um etwas hinzuzufügen.';

  @override
  String todayMacroOfGoal(String eaten, String goal) {
    return '$eaten von $goal g';
  }

  @override
  String nutrientWithValue(String nutrient, String value) {
    return '$nutrient: $value';
  }

  @override
  String totalAtLeast(String value) {
    return 'mind. $value';
  }

  @override
  String totalAtMost(String value) {
    return 'höchstens $value';
  }

  @override
  String unitGrams(String value) {
    return '$value g';
  }

  @override
  String unitKcal(String value) {
    return '$value kcal';
  }

  @override
  String get diaryEntryDeleted => 'Eintrag gelöscht';

  @override
  String get entryAmountLabel => 'Menge';

  @override
  String get entryMealLabel => 'Mahlzeit';

  @override
  String get amountInvalid => 'Bitte gib eine Menge zwischen 0 und 10.000 ein.';

  @override
  String get nutrientKcal => 'Energie';

  @override
  String get nutrientFat => 'Fett';

  @override
  String get nutrientSaturatedFat => 'gesättigte Fettsäuren';

  @override
  String get nutrientCarbs => 'Kohlenhydrate';

  @override
  String get nutrientSugars => 'Zucker';

  @override
  String get nutrientFibre => 'Ballaststoffe';

  @override
  String get nutrientProtein => 'Eiweiß';

  @override
  String get nutrientSalt => 'Salz';

  @override
  String get ratingLevelLow => 'niedrig';

  @override
  String get ratingLevelMedium => 'mittel';

  @override
  String get ratingLevelHigh => 'hoch';

  @override
  String get ratingNoData => 'keine Angabe';

  @override
  String get ratingTitle => 'Bewertung';

  @override
  String get ratingTitleFood => 'Bewertung pro 100 g';

  @override
  String get ratingTitleDrink => 'Bewertung pro 100 ml';

  @override
  String ratingRowSemantics(String nutrient, String level, String value) {
    return '$nutrient: $level, $value';
  }

  @override
  String get ratingNotRated =>
      'Für diese Produktart gibt es keine Ampel-Bewertung (z. B. Wasser, Kaffee, Tee, Gewürze, Babynahrung, Alkohol). Die Nährwerte siehst du unten.';

  @override
  String get ratingNoCategory =>
      'Die Produktart ist unbekannt, deshalb gibt es keine Ampel-Bewertung.';

  @override
  String get ratingSuspicious =>
      'Diese Angaben wirken unstimmig und könnten fehlerhaft sein.';

  @override
  String get plusFibreSource => 'Ballaststoffquelle';

  @override
  String get plusFibreHigh => 'hoher Ballaststoffgehalt';

  @override
  String get plusProteinSource => 'Proteinquelle';

  @override
  String get plusProteinHigh => 'hoher Proteingehalt';

  @override
  String plusPointRow(String label, String value) {
    return '$label · $value';
  }

  @override
  String productNutriScore(String grade) {
    return 'Nutri-Score: $grade (laut Open Food Facts)';
  }

  @override
  String get productImageCaption =>
      'Foto: Open Food Facts-Mitwirkende, CC BY-SA';

  @override
  String get productFavouriteAdd => 'Zu Favoriten hinzufügen';

  @override
  String get productFavouriteRemove => 'Aus Favoriten entfernen';

  @override
  String get productAmountTitle => 'Wie viel?';

  @override
  String productServingChip(String amount) {
    return '1 Portion ($amount)';
  }

  @override
  String productLastAmountChip(String amount) {
    return 'Zuletzt: $amount';
  }

  @override
  String productDay(String day) {
    return 'Tag: $day';
  }

  @override
  String productAdded(String meal) {
    return 'Zu $meal hinzugefügt';
  }

  @override
  String get productNutritionTitle => 'Nährwerte';

  @override
  String get productPer100g => 'pro 100 g';

  @override
  String get productPer100ml => 'pro 100 ml';

  @override
  String productPerServing(String amount) {
    return 'pro Portion ($amount)';
  }

  @override
  String get productAttribution => 'Daten: Open Food Facts (ODbL)';

  @override
  String get productCorrectHint =>
      'Daten falsch? Auf Open Food Facts kannst du sie korrigieren.';

  @override
  String get productOpenOff => 'Auf Open Food Facts ansehen';

  @override
  String get productLinkFailed => 'Der Link konnte nicht geöffnet werden.';

  @override
  String get productCreateOwn => 'Selbst eintragen';

  @override
  String get productCompleteValues => 'Werte ergänzen';

  @override
  String get productGone => 'Dieses Lebensmittel gibt es nicht mehr.';

  @override
  String get disclaimerShort =>
      'Daten von Open Food Facts. Werte können fehlerhaft sein. Die Bewertung ist eine Orientierung und keine medizinische Beratung.';

  @override
  String get disclaimerRating =>
      'Die Bewertung ist eine Orientierung und keine medizinische Beratung.';

  @override
  String get searchFieldHint => 'Produkt suchen';

  @override
  String get searchSubmit => 'Suchen';

  @override
  String get scanRecentlyViewedTitle => 'Zuletzt angesehen';

  @override
  String get scanRecentlyViewedEmpty =>
      'Hier erscheinen Produkte, die du gescannt oder gesucht hast.';

  @override
  String get scannerTitle => 'Barcode scannen';

  @override
  String get scannerHint => 'Halte die Kamera auf einen Barcode.';

  @override
  String get scannerPreviewLabel => 'Kamera zum Scannen von Barcodes';

  @override
  String get scannerTorchOn => 'Licht einschalten';

  @override
  String get scannerTorchOff => 'Licht ausschalten';

  @override
  String get scannerPermissionTitle => 'Kein Zugriff auf die Kamera';

  @override
  String get scannerPermissionText =>
      'Zum Scannen erlaube den Kamerazugriff in den Einstellungen deines Geräts (Einstellungen › Food Tracker › Kamera). Bis dahin kannst du die Suche nutzen.';

  @override
  String get scannerUnsupported =>
      'Hier gibt es keine Kamera. Nutze die Suche.';

  @override
  String get scannerError =>
      'Die Kamera konnte nicht starten. Versuch es noch mal oder nutze die Suche.';

  @override
  String searchResultsTitle(String query) {
    return 'Suche: $query';
  }

  @override
  String get searchEmptyQuery => 'Gib ein, was du suchst.';

  @override
  String get searchLocalTitle => 'Auf deinem Gerät';

  @override
  String get searchOnlineTitle => 'Online-Ergebnisse';

  @override
  String get searchNoOnlineResults => 'Keine Treffer bei Open Food Facts.';

  @override
  String get searchNoResultsHint =>
      'Prüf die Schreibweise oder trag das Lebensmittel selbst ein.';

  @override
  String get searchLoadMore => 'Mehr laden';

  @override
  String searchNutriScore(String grade) {
    return 'Nutri-Score: $grade';
  }

  @override
  String foodKcalPer100g(String kcal) {
    return '$kcal kcal pro 100 g';
  }

  @override
  String foodKcalPer100ml(String kcal) {
    return '$kcal kcal pro 100 ml';
  }

  @override
  String get foodKcalUnknown => 'Kalorien unbekannt';

  @override
  String addFoodTitle(String meal, String day) {
    return '$meal · $day';
  }

  @override
  String get addFoodSearchHint => 'Lebensmittel suchen';

  @override
  String get addFoodScan => 'Scannen';

  @override
  String get addFoodCreateOwn => 'Eigenes Lebensmittel';

  @override
  String get addFoodSegmentRecent => 'Zuletzt';

  @override
  String get addFoodSegmentFavourites => 'Favoriten';

  @override
  String get addFoodSegmentOwn => 'Eigene';

  @override
  String get addFoodRecentEmpty =>
      'Noch leer. Was du in dein Tagebuch einträgst, erscheint hier.';

  @override
  String get addFoodFavouritesEmpty =>
      'Noch keine Favoriten. Tippe auf einer Produktseite auf den Stern.';

  @override
  String get addFoodOwnEmpty =>
      'Noch keine eigenen Lebensmittel. Leg eins mit „Eigenes Lebensmittel“ an.';

  @override
  String get addFoodNoLocalMatches =>
      'Auf deinem Gerät nichts gefunden. Tippe auf der Tastatur auf „Suchen“, um online zu suchen.';

  @override
  String get foodFormNewTitle => 'Neues Lebensmittel';

  @override
  String get foodFormEditTitle => 'Lebensmittel bearbeiten';

  @override
  String foodFormRequired(String label) {
    return '$label *';
  }

  @override
  String get foodFormRequiredHint => '* Pflichtfeld';

  @override
  String get foodFormName => 'Name';

  @override
  String get foodFormBrand => 'Marke (optional)';

  @override
  String get foodFormBarcode => 'Barcode';

  @override
  String get foodFormIsLiquid => 'Getränk (pro 100 ml)';

  @override
  String get foodFormNutrientsPer100g => 'Nährwerte pro 100 g';

  @override
  String get foodFormNutrientsPer100ml => 'Nährwerte pro 100 ml';

  @override
  String get foodFormPortionTitle => 'Portion (optional)';

  @override
  String get foodFormPortionSize => 'Menge einer Portion';

  @override
  String get foodFormPortionLabel => 'Bezeichnung der Portion';

  @override
  String get foodFormPortionLabelHint => 'z. B. 1 Scheibe';

  @override
  String get foodFormNameMissing => 'Bitte gib einen Namen ein.';

  @override
  String get foodFormKcalMissing => 'Bitte gib die Kalorien ein.';

  @override
  String get foodFormNotANumber => 'Bitte gib eine Zahl ein.';

  @override
  String foodFormOutOfRange(String max) {
    return 'Erlaubt: 0 bis $max';
  }

  @override
  String get foodFormSaturatesAboveFat => 'Kann nicht mehr sein als Fett.';

  @override
  String get foodFormSugarsAboveCarbs =>
      'Kann nicht mehr sein als Kohlenhydrate.';

  @override
  String get foodFormPortionSizeMissing =>
      'Gib dazu auch die Menge einer Portion an.';

  @override
  String foodFormDeleteTitle(String name) {
    return '„$name“ löschen?';
  }

  @override
  String get foodFormDeleteText =>
      'Einträge in deinem Tagebuch bleiben erhalten.';

  @override
  String foodFormDeleted(String name) {
    return '„$name“ gelöscht';
  }
}
