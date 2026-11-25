import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/goals/goal_enums.dart';
import '../features/products/food_source.dart';

part 'database.g.dart';

// The local SQLite database of the app (via the drift package).
//
// Each class below is one table. After changing a table, run
//   dart run build_runner build
// to regenerate `database.g.dart`. The app is already installed on phones, so
// every change also needs a higher `schemaVersion` and a step in `onUpgrade`
// (see `migration` below and test/data/migration_test.dart).
//
// All nutrient columns hold values PER 100 g (or per 100 ml for drinks).
// NULL means "unknown" – it is never treated as 0.

/// Foods the app knows: products cached from Open Food Facts, basic foods
/// from the BLS and the user's own foods. One table, so search, favourites
/// and "recently used" work the same for all of them.
///
/// The unique index keeps one row per BLS food (rows without an [externalId]
/// do not count: SQLite treats NULLs as different).
@TableIndex(
  name: 'foods_source_external_id',
  columns: {#source, #externalId},
  unique: true,
)
class Foods extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get source => intEnum<FoodSource>()();

  /// Normalised barcode (GTIN). NULL for own foods without a barcode.
  TextColumn get barcode => text().nullable().unique()();

  /// The food's key in its source, for example the BLS code "B782100".
  /// NULL for Open Food Facts products (their key is [barcode]) and own
  /// foods. Added in schema version 2.
  TextColumn get externalId => text().nullable()();
  TextColumn get name => text()();
  TextColumn get brand => text().nullable()();

  /// Package size for display, for example "175 g".
  TextColumn get quantityLabel => text().nullable()();

  /// True for drinks: values are per 100 ml and amounts are in ml.
  BoolColumn get isLiquid => boolean().withDefault(const Constant(false))();

  /// Size of one portion in g (or ml), for example 30.
  RealColumn get servingSize => real().nullable()();

  /// Text for one portion, for example "1 Riegel (30 g)".
  TextColumn get servingLabel => text().nullable()();

  RealColumn get kcal => real().nullable()();
  RealColumn get fat => real().nullable()();
  RealColumn get saturatedFat => real().nullable()();
  RealColumn get carbs => real().nullable()();
  RealColumn get sugars => real().nullable()();
  RealColumn get fibre => real().nullable()();
  RealColumn get protein => real().nullable()();
  RealColumn get salt => real().nullable()();

  /// Nutri-Score grade "A" … "E" as reported by Open Food Facts.
  TextColumn get nutriScore => text().nullable()();
  IntColumn get novaGroup => integer().nullable()();

  /// Open Food Facts category tags, joined with commas
  /// (for example "en:snacks,en:chips"). Used by the health rating.
  TextColumn get categories => text().nullable()();
  TextColumn get imageUrl => text().nullable()();

  /// How complete the Open Food Facts entry is (0.0 – 1.0).
  RealColumn get completeness => real().nullable()();

  BoolColumn get isFavourite => boolean().withDefault(const Constant(false))();

  /// Last time this food was added to the diary ("Zuletzt gegessen").
  DateTimeColumn get lastUsedAt => dateTime().nullable()();

  /// Last time the product page was opened ("Zuletzt angesehen").
  DateTimeColumn get lastViewedAt => dateTime().nullable()();

  /// When the data was downloaded from Open Food Facts (cache age).
  DateTimeColumn get fetchedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

/// The meals of a day. The user can rename, add, hide and reorder them.
@DataClassName('MealSlot')
class MealSlots extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// `breakfast`, `lunch`, `dinner` or `snacks` for the four meals the app
  /// starts with (their names are translated). NULL for meals the user added.
  TextColumn get builtIn => text().nullable()();

  /// Name chosen by the user. If set, it is shown instead of the default name.
  TextColumn get customName => text().nullable()();

  /// Display order, 0 first.
  IntColumn get position => integer()();
  BoolColumn get isHidden => boolean().withDefault(const Constant(false))();

  /// Time of day in minutes after midnight from which this meal is suggested
  /// (for example 660 = 11:00). NULL = never suggested automatically.
  IntColumn get startMinute => integer().nullable()();
}

/// One food eaten on one day in one meal.
///
/// The name and nutrient values are a *copy* taken when the entry is made, so
/// past days never change when a product's data changes later.
@DataClassName('DiaryEntry')
class DiaryEntries extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Local calendar day, for example "2026-11-14" (see core/clock.dart).
  TextColumn get day => text().withLength(min: 10, max: 10)();
  IntColumn get mealSlotId => integer().references(MealSlots, #id)();

  /// The food this entry came from (NULL if that food was deleted).
  IntColumn get foodId => integer().nullable().references(
    Foods,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get name => text()();
  TextColumn get brand => text().nullable()();

  /// How much was eaten, in g (or ml when [isLiquid]).
  RealColumn get amount => real()();
  BoolColumn get isLiquid => boolean().withDefault(const Constant(false))();
  TextColumn get servingLabel => text().nullable()();

  RealColumn get kcal => real().nullable()();
  RealColumn get fat => real().nullable()();
  RealColumn get saturatedFat => real().nullable()();
  RealColumn get carbs => real().nullable()();
  RealColumn get sugars => real().nullable()();
  RealColumn get fibre => real().nullable()();
  RealColumn get protein => real().nullable()();
  RealColumn get salt => real().nullable()();

  DateTimeColumn get createdAt => dateTime()();
}

/// The user's daily goal. At most one row (id = 1). No row = no goal yet.
@DataClassName('UserGoalRow')
class UserGoal extends Table {
  IntColumn get id => integer()();
  IntColumn get kcal => integer()();

  /// Daily macro goals in grams (NULL = not set).
  RealColumn get protein => real().nullable()();
  RealColumn get carbs => real().nullable()();
  RealColumn get fat => real().nullable()();

  // The calculator inputs, so the form can be shown again. All NULL when the
  // goal was typed in by hand.
  IntColumn get sex => intEnum<Sex>().nullable()();
  IntColumn get age => integer().nullable()();
  RealColumn get heightCm => real().nullable()();
  RealColumn get weightKg => real().nullable()();
  IntColumn get activity => intEnum<ActivityLevel>().nullable()();
  IntColumn get goalType => intEnum<GoalType>().nullable()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// The four meals every new installation starts with.
const defaultMealSlots = [
  (builtIn: 'breakfast', position: 0, startMinute: 4 * 60),
  (builtIn: 'lunch', position: 1, startMinute: 11 * 60),
  (builtIn: 'dinner', position: 2, startMinute: 17 * 60 + 30),
  (builtIn: 'snacks', position: 3, startMinute: 15 * 60),
];

@DriftDatabase(tables: [Foods, MealSlots, DiaryEntries, UserGoal])
class AppDatabase extends _$AppDatabase {
  /// Opens the database file on the device. Tests pass
  /// `NativeDatabase.memory()` instead.
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'food_tracker'));

  /// 1: first release. 2: basic foods from the BLS (`Foods.externalId` and
  /// its unique index).
  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await insertDefaultMealSlots();
    },
    // Runs once when an installed app with an older database starts after an
    // update. Each step brings the database one version further, so phones
    // that skipped an update are migrated too.
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(foods, foods.externalId);
        await m.createIndex(foodsSourceExternalId);
      }
    },
    beforeOpen: (details) async {
      // SQLite ignores foreign keys unless they are switched on.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// Adds the four default meals (used on first start and after "delete all").
  Future<void> insertDefaultMealSlots() async {
    await batch((b) {
      b.insertAll(mealSlots, [
        for (final slot in defaultMealSlots)
          MealSlotsCompanion.insert(
            builtIn: Value(slot.builtIn),
            position: slot.position,
            startMinute: Value(slot.startMinute),
          ),
      ]);
    });
  }

  /// Deletes everything the user entered and restores the default meals.
  Future<void> deleteAllData() {
    return transaction(() async {
      await delete(diaryEntries).go();
      await delete(foods).go();
      await delete(userGoal).go();
      await delete(mealSlots).go();
      await insertDefaultMealSlots();
    });
  }
}

/// The single database of the app. Tests override it with an in-memory one.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
