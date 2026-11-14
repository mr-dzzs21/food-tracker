import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';

import '../../core/clock.dart';
import '../../data/database.dart';
import '../products/nutrients.dart';

/// The numbers of one calendar week (Monday to Sunday) for the "Statistik"
/// tab. Pure Dart: built from a list of diary entries, no database.
///
/// Averages are taken over the days **with entries** only. A day the user
/// did not log is unknown, not a day with 0 kcal – counting it would make
/// the average look much lower than what was really eaten.
@immutable
class WeekStats {
  const WeekStats._(this.monday, this.days, this.dayTotals, this.weekTotals);

  /// Groups [entries] by day. Entries outside the week are ignored.
  ///
  /// Throws an [ArgumentError] when [monday] is not a Monday.
  factory WeekStats.of(String monday, Iterable<DiaryEntry> entries) {
    if (mondayOf(monday) != monday) {
      throw ArgumentError.value(monday, 'monday', 'not a Monday');
    }
    final days = weekDays(monday);
    final byDay = {for (final day in days) day: <Nutrients>[]};
    for (final entry in entries) {
      byDay[entry.day]?.add(entry.nutrients);
    }
    return WeekStats._(
      monday,
      days,
      List.unmodifiable([
        for (final day in days) NutrientTotals.sum(byDay[day]!),
      ]),
      NutrientTotals.sum(byDay.values.expand((list) => list)),
    );
  }

  /// The week's Monday (`yyyy-MM-dd`).
  final String monday;

  /// The seven day keys, Monday first.
  final List<String> days;

  /// The sums of each day, in the same order as [days]. A day without
  /// entries has `entryCount == 0`.
  final List<NutrientTotals> dayTotals;

  /// All entries of the week added up (also counts the missing values).
  final NutrientTotals weekTotals;

  /// How many of the seven days have at least one entry.
  int get daysLogged => dayTotals.where((day) => day.entryCount > 0).length;

  /// No entry on any day of the week.
  bool get isEmpty => daysLogged == 0;

  /// Average of [nutrient] per day with entries; `null` for an empty week.
  ///
  /// Use [averageState] to know whether it is exact ("1.850"), only a lower
  /// bound because some entries had no value ("mind. 1.850"), or unknown.
  double? average(Nutrient nutrient) {
    final days = daysLogged;
    return days == 0 ? null : weekTotals[nutrient].value / days;
  }

  /// Whether every entry of the week knew [nutrient] (see [average]).
  TotalState averageState(Nutrient nutrient) => weekTotals.stateOf(nutrient);
}

/// The seven day keys of the week that starts on [monday].
List<String> weekDays(String monday) => [
  for (var i = 0; i < DateTime.daysPerWeek; i++) addDays(monday, i),
];

/// The Monday of the week that contains today.
String currentMonday(Clock clock) => mondayOf(todayKey(clock));

/// The year an ISO week belongs to: the year of its Thursday. The week from
/// 28 Dec 2026 to 3 Jan 2027 is week 53 of 2026, for example.
int isoWeekYear(String key) => parseDayKey(addDays(mondayOf(key), 3)).year;
