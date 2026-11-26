import 'dart:math' as math;

import 'package:clock/clock.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/clock.dart';
import '../../core/format.dart';
import '../../data/database.dart';
import '../../l10n/app_localizations.dart';
import '../products/nutrients.dart';

/// One diary entry together with the meal it belongs to.
typedef DayEntry = ({DiaryEntry entry, MealSlot slot});

/// What happened when the user tried to delete a meal.
enum MealSlotDeleteResult {
  deleted,

  /// Not deleted: diary entries use this meal (it can only be hidden).
  hasEntries,

  /// Not deleted: it is the only visible meal.
  lastVisible,
}

/// All access to the diary (what was eaten when) and to the meal slots.
/// The UI never touches the `DiaryEntries` table directly.
class DiaryRepository {
  DiaryRepository(this._db, this._clock);

  /// Largest amount (g or ml) one entry may have. Protects against typos
  /// like "15000" instead of "150".
  static const maxAmount = 10000.0;

  final AppDatabase _db;
  final Clock _clock;

  // ---------------------------------------------------------------------------
  // Reading

  /// The entries of one [day] with their meal, in display order: by meal
  /// position, then in the order they were added.
  ///
  /// Emits again whenever an entry or a meal changes.
  Stream<List<DayEntry>> watchDay(String day) {
    final entries = _db.diaryEntries;
    final slots = _db.mealSlots;
    final query =
        _db.select(entries).join([
            innerJoin(slots, slots.id.equalsExp(entries.mealSlotId)),
          ])
          ..where(entries.day.equals(day))
          ..orderBy([
            OrderingTerm.asc(slots.position),
            OrderingTerm.asc(entries.createdAt),
            // Same timestamp (fast taps): keep the insert order.
            OrderingTerm.asc(entries.id),
          ]);
    return query.watch().map(
      (rows) => [
        for (final row in rows)
          (entry: row.readTable(entries), slot: row.readTable(slots)),
      ],
    );
  }

  /// The entries from day [first] to day [last] (both included, keys
  /// `yyyy-MM-dd`), for the week statistics. One query for the whole range.
  ///
  /// Day keys sort like dates, so a text comparison finds the right days.
  Stream<List<DiaryEntry>> watchEntriesBetween(String first, String last) {
    _checkDay(first);
    _checkDay(last);
    return (_db.select(
      _db.diaryEntries,
    )..where((e) => e.day.isBetweenValues(first, last))).watch();
  }

  /// All meals (also hidden ones), sorted by their position.
  Stream<List<MealSlot>> watchMealSlots() =>
      (_db.select(_db.mealSlots)..orderBy([
            (s) => OrderingTerm.asc(s.position),
            (s) => OrderingTerm.asc(s.id),
          ]))
          .watch();

  /// The amount used the last time [foodId] was logged, or `null` if it was
  /// never logged. Used for the "Zuletzt: 45 g" chip on the product page.
  Future<double?> lastAmountFor(int foodId) async {
    final latest =
        await (_db.select(_db.diaryEntries)
              ..where((e) => e.foodId.equals(foodId))
              ..orderBy([
                (e) => OrderingTerm.desc(e.createdAt),
                (e) => OrderingTerm.desc(e.id),
              ])
              ..limit(1))
            .getSingleOrNull();
    return latest?.amount;
  }

  // ---------------------------------------------------------------------------
  // Changing

  /// Logs [amount] g (or ml) of [food] in meal [mealSlotId] on [day] and
  /// returns the new entry's id.
  ///
  /// The entry keeps a *copy* of the name and the values per 100 g, so the
  /// day never changes when the food is edited or deleted later.
  /// It also sets the food's "last used" time ("Zuletzt gegessen").
  Future<int> addEntry({
    required Food food,
    required double amount,
    required String day,
    required int mealSlotId,
  }) {
    _checkAmount(amount);
    _checkDay(day);
    return _db.transaction(() async {
      final now = _clock.now();
      final id = await _db
          .into(_db.diaryEntries)
          .insert(
            DiaryEntriesCompanion.insert(
              day: day,
              mealSlotId: mealSlotId,
              foodId: Value(food.id),
              name: food.name,
              brand: Value(food.brand),
              amount: amount,
              isLiquid: Value(food.isLiquid),
              servingLabel: Value(food.servingLabel),
              kcal: Value(food.kcal),
              fat: Value(food.fat),
              saturatedFat: Value(food.saturatedFat),
              carbs: Value(food.carbs),
              sugars: Value(food.sugars),
              fibre: Value(food.fibre),
              protein: Value(food.protein),
              salt: Value(food.salt),
              createdAt: now,
            ),
          );
      // Written here (not via ProductRepository.markUsed) so the entry and
      // the "last used" time are saved together in one transaction, and the
      // diary does not need the Open Food Facts client.
      await (_db.update(_db.foods)..where((f) => f.id.equals(food.id))).write(
        FoodsCompanion(lastUsedAt: Value(now)),
      );
      return id;
    });
  }

  /// Changes the amount and the meal of an entry. The copied values stay.
  Future<void> updateEntry(
    int id, {
    required double amount,
    required int mealSlotId,
  }) {
    _checkAmount(amount);
    return (_db.update(_db.diaryEntries)..where((e) => e.id.equals(id))).write(
      DiaryEntriesCompanion(
        amount: Value(amount),
        mealSlotId: Value(mealSlotId),
      ),
    );
  }

  /// Deletes an entry. Keep the [DiaryEntry] to undo it with [restoreEntry].
  Future<void> deleteEntry(int id) =>
      (_db.delete(_db.diaryEntries)..where((e) => e.id.equals(id))).go();

  /// Puts a deleted [entry] back, with its old id ("Rückgängig").
  Future<void> restoreEntry(DiaryEntry entry) {
    return _db.transaction(() async {
      var restored = entry;
      final foodId = entry.foodId;
      // The food may have been deleted in the meantime; the entry has its own
      // copy of the values, so it simply loses the link.
      if (foodId != null) {
        final food = await (_db.select(
          _db.foods,
        )..where((f) => f.id.equals(foodId))).getSingleOrNull();
        if (food == null) restored = entry.copyWith(foodId: const Value(null));
      }
      await _db
          .into(_db.diaryEntries)
          .insert(restored, mode: InsertMode.insertOrReplace);
    });
  }

  // ---------------------------------------------------------------------------
  // Meal slots (settings page "Mahlzeiten")

  /// Whether any diary entry (on any day) belongs to meal [slotId].
  Future<bool> mealSlotHasEntries(int slotId) async {
    final first =
        await (_db.select(_db.diaryEntries)
              ..where((e) => e.mealSlotId.equals(slotId))
              ..limit(1))
            .getSingleOrNull();
    return first != null;
  }

  /// Adds a meal at the end of the list and returns its id.
  Future<int> addMealSlot({required String name, int? startMinute}) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) throw ArgumentError.value(name, 'name', 'empty');
    _checkStartMinute(startMinute);
    return _db.transaction(() async {
      final positions = (await _db.select(_db.mealSlots).get()).map(
        (s) => s.position,
      );
      final nextPosition = positions.isEmpty
          ? 0
          : positions.reduce(math.max) + 1;
      return _db
          .into(_db.mealSlots)
          .insert(
            MealSlotsCompanion.insert(
              customName: Value(trimmed),
              position: nextPosition,
              startMinute: Value(startMinute),
            ),
          );
    });
  }

  /// Changes the name and the start time of a meal.
  ///
  /// An empty [customName] removes the own name, so the four built-in meals
  /// show their translated default name again ("Frühstück", …).
  /// [startMinute] is minutes after midnight, `null` = no start time.
  Future<void> updateMealSlot(
    int id, {
    required String? customName,
    required int? startMinute,
  }) {
    _checkStartMinute(startMinute);
    final trimmed = customName?.trim();
    return (_db.update(_db.mealSlots)..where((s) => s.id.equals(id))).write(
      MealSlotsCompanion(
        customName: Value(trimmed == null || trimmed.isEmpty ? null : trimmed),
        startMinute: Value(startMinute),
      ),
    );
  }

  /// Hides or shows a meal. Returns `false` (and changes nothing) when it is
  /// the last visible meal: there must always be a meal to add food to.
  Future<bool> setMealSlotHidden(int id, {required bool hidden}) {
    return _db.transaction(() async {
      if (hidden && await _isLastVisibleSlot(id)) return false;
      await (_db.update(_db.mealSlots)..where((s) => s.id.equals(id))).write(
        MealSlotsCompanion(isHidden: Value(hidden)),
      );
      return true;
    });
  }

  /// Deletes a meal, but only if no diary entry uses it (past days must stay
  /// complete) and it is not the last visible meal.
  Future<MealSlotDeleteResult> deleteMealSlot(int id) {
    return _db.transaction(() async {
      if (await mealSlotHasEntries(id)) return MealSlotDeleteResult.hasEntries;
      if (await _isLastVisibleSlot(id)) return MealSlotDeleteResult.lastVisible;
      await (_db.delete(_db.mealSlots)..where((s) => s.id.equals(id))).go();
      return MealSlotDeleteResult.deleted;
    });
  }

  /// Saves a new order: [idsInOrder] lists every meal id from top to bottom.
  Future<void> reorderMealSlots(List<int> idsInOrder) {
    return _db.batch((b) {
      for (final (position, id) in idsInOrder.indexed) {
        b.update(
          _db.mealSlots,
          MealSlotsCompanion(position: Value(position)),
          where: (s) => s.id.equals(id),
        );
      }
    });
  }

  /// True when [id] is visible and no other meal is.
  Future<bool> _isLastVisibleSlot(int id) async {
    final visible = await (_db.select(
      _db.mealSlots,
    )..where((s) => s.isHidden.equals(false))).get();
    return visible.length == 1 && visible.single.id == id;
  }

  static void _checkStartMinute(int? minute) {
    if (minute != null && (minute < 0 || minute >= 24 * 60)) {
      throw ArgumentError.value(minute, 'startMinute', 'must be 0–1439');
    }
  }

  static void _checkAmount(double amount) {
    if (!amount.isFinite || amount <= 0 || amount > maxAmount) {
      throw ArgumentError.value(amount, 'amount', 'must be > 0 and ≤ 10000');
    }
  }

  static void _checkDay(String day) {
    if (!isDayKey(day)) throw ArgumentError.value(day, 'day', 'not yyyy-MM-dd');
  }
}

// -----------------------------------------------------------------------------
// Totals

/// The sums of one day: all entries together and per meal.
@immutable
class DayTotals {
  const DayTotals._(this.all, this._byMeal);

  /// Adds up [entries] (for example the list from [DiaryRepository.watchDay]).
  factory DayTotals.of(List<DayEntry> entries) {
    final bySlot = <int, List<Nutrients>>{};
    for (final item in entries) {
      bySlot.putIfAbsent(item.slot.id, () => []).add(item.entry.nutrients);
    }
    return DayTotals._(
      NutrientTotals.sum(entries.map((item) => item.entry.nutrients)),
      {
        for (final slot in bySlot.entries)
          slot.key: NutrientTotals.sum(slot.value),
      },
    );
  }

  /// The whole day.
  final NutrientTotals all;
  final Map<int, NutrientTotals> _byMeal;

  /// One meal; complete zeros when it has no entries.
  NutrientTotals forMeal(int slotId) =>
      _byMeal[slotId] ?? NutrientTotals.sum(const []);
}

// -----------------------------------------------------------------------------
// Meal slots (pure helpers)

/// The name of a meal in the current language: the user's own name if set,
/// otherwise the translated default ("Frühstück", "Breakfast", …).
String mealSlotName(MealSlot slot, AppLocalizations l10n) {
  final custom = slot.customName?.trim();
  if (custom != null && custom.isNotEmpty) return custom;
  return switch (slot.builtIn) {
    'breakfast' => l10n.mealBreakfast,
    'lunch' => l10n.mealLunch,
    'dinner' => l10n.mealDinner,
    'snacks' => l10n.mealSnacks,
    _ => l10n.mealUnnamed,
  };
}

/// Which meal a text with a German article means: `breakfast`, `lunch`,
/// `dinner` or `snacks` for the built-in meals ("zum Frühstück", "zu den
/// Snacks"), `other` for renamed and own meals ("zu {meal}"). For the ARB
/// texts with `{slot, select, …}`.
String mealSlotTextKey(MealSlot slot) {
  final custom = slot.customName?.trim();
  if (custom != null && custom.isNotEmpty) return 'other';
  return switch (slot.builtIn) {
    final builtIn?
        when const {
          'breakfast',
          'lunch',
          'dinner',
          'snacks',
        }.contains(builtIn) =>
      builtIn,
    _ => 'other',
  };
}

/// Minutes after midnight of [time], for [preselectMealSlot].
int minuteOfDay(DateTime time) => time.hour * 60 + time.minute;

/// The meal that fits the time of day [minuteOfDay] (0–1439).
///
/// Among the visible meals with a start time, the one that started last
/// before (or at) that time. Before the earliest start time (for example at
/// 02:00) the day "wraps around" and the meal with the latest start time is
/// used. Meals without a start time are never chosen automatically; if no
/// meal has one, the first visible meal is used. `null` only when no meal is
/// visible.
///
/// [slots] must be sorted by position (as [DiaryRepository.watchMealSlots]
/// returns them); on equal start times the first one wins.
MealSlot? preselectMealSlot(List<MealSlot> slots, int minuteOfDay) {
  final visible = slots.where((s) => !s.isHidden).toList();
  if (visible.isEmpty) return null;

  MealSlot? latestBefore;
  MealSlot? latestOverall;
  for (final slot in visible) {
    final start = slot.startMinute;
    if (start == null) continue;
    if (start <= minuteOfDay &&
        (latestBefore == null || start > latestBefore.startMinute!)) {
      latestBefore = slot;
    }
    if (latestOverall == null || start > latestOverall.startMinute!) {
      latestOverall = slot;
    }
  }
  return latestBefore ?? latestOverall ?? visible.first;
}

// -----------------------------------------------------------------------------
// Providers

final diaryRepositoryProvider = Provider<DiaryRepository>((ref) {
  return DiaryRepository(ref.watch(databaseProvider), ref.watch(clockProvider));
});

/// The entries of one day (key `yyyy-MM-dd`) with their meals.
final dayEntriesProvider = StreamProvider.autoDispose
    .family<List<DayEntry>, String>((ref, day) {
      return ref.watch(diaryRepositoryProvider).watchDay(day);
    });

/// The entries of the day shown on "Heute" ([selectedDayProvider]).
///
/// One provider for every day (not one per day like [dayEntriesProvider]):
/// when the user switches the day, Riverpod keeps the old entries as the
/// value of the loading state until the new ones arrive. So the page shows
/// no spinner in between, and the ring moves from the old to the new total.
final selectedDayEntriesProvider = StreamProvider.autoDispose<List<DayEntry>>(
  (ref) => ref
      .watch(diaryRepositoryProvider)
      .watchDay(ref.watch(selectedDayProvider)),
);

/// All meals (also hidden ones), sorted by position.
final mealSlotsProvider = StreamProvider.autoDispose<List<MealSlot>>(
  (ref) => ref.watch(diaryRepositoryProvider).watchMealSlots(),
);

/// The amount used the last time a food (by id) was logged.
final lastAmountProvider = FutureProvider.autoDispose.family<double?, int>(
  (ref, foodId) => ref.watch(diaryRepositoryProvider).lastAmountFor(foodId),
);

/// The first day the "Heute" tab can show. The date picker needs limits, and
/// ‹ › stop at the same ones.
const firstSelectableDay = '2000-01-01';

/// The last day the "Heute" tab can show: 31 December of next year.
String lastSelectableDay(Clock clock) => '${clock.now().year + 1}-12-31';

/// [day], moved into the range from [firstSelectableDay] to
/// [lastSelectableDay]. Day keys sort like dates, so text comparison works.
String clampSelectableDay(String day, Clock clock) {
  if (day.compareTo(firstSelectableDay) < 0) return firstSelectableDay;
  final last = lastSelectableDay(clock);
  return day.compareTo(last) > 0 ? last : day;
}

/// The day shown on the "Heute" tab (key `yyyy-MM-dd`). Starts at today and
/// stays between [firstSelectableDay] and [lastSelectableDay].
class SelectedDay extends Notifier<String> {
  @override
  String build() {
    // After midnight "today" moves on (see todayProvider). The page follows
    // only when it still shows the old today – not a day the user picked.
    ref.listen(todayProvider, (previous, next) {
      if (previous != null && state == previous) state = next;
    });
    return ref.read(todayProvider);
  }

  /// Whether ‹ can go one day back.
  bool get canGoBack => state.compareTo(firstSelectableDay) > 0;

  /// Whether › can go one day forward.
  bool get canGoForward =>
      state.compareTo(lastSelectableDay(ref.read(clockProvider))) < 0;

  void previous() {
    if (canGoBack) state = addDays(state, -1);
  }

  void next() {
    if (canGoForward) state = addDays(state, 1);
  }

  void today() => state = todayKey(ref.read(clockProvider));

  void set(String day) {
    if (!isDayKey(day)) throw ArgumentError.value(day, 'day');
    state = clampSelectableDay(day, ref.read(clockProvider));
  }
}

final selectedDayProvider = NotifierProvider<SelectedDay, String>(
  SelectedDay.new,
);

/// Reads an amount the user typed in the language [locale] (`45`, `12,5`,
/// `12.5`, `1.000` in German, see [parseUserNumber]). `null` when it is
/// empty, not a number, 0 or less, or above [DiaryRepository.maxAmount].
double? parseEntryAmount(String text, String locale) {
  final value = parseUserNumber(text, locale);
  if (value == null || value <= 0 || value > DiaryRepository.maxAmount) {
    return null;
  }
  return value;
}
