import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/clock.dart';
import '../diary/diary_repository.dart';
import 'week_stats.dart';

/// The statistics of the week that starts on a Monday (`yyyy-MM-dd`).
///
/// Loads all entries of the seven days with one database query and updates
/// itself when an entry is added, changed or deleted.
final weekStatsProvider = StreamProvider.autoDispose.family<WeekStats, String>((
  ref,
  monday,
) {
  return ref
      .watch(diaryRepositoryProvider)
      .watchEntriesBetween(monday, addDays(monday, 6))
      .map((entries) => WeekStats.of(monday, entries));
});

/// The week shown on the "Statistik" tab, as its Monday (`yyyy-MM-dd`).
/// Starts at the current week; future weeks cannot be chosen (they are
/// always empty).
class SelectedWeek extends Notifier<String> {
  @override
  String build() {
    // On a new week (the app was in the background over Sunday midnight)
    // the tab follows – but only when it still shows the old current week.
    ref.listen(todayProvider, (previous, next) {
      if (previous != null && state == mondayOf(previous)) {
        state = mondayOf(next);
      }
    });
    return mondayOf(ref.read(todayProvider));
  }

  /// Whether the shown week is the current one (then there is no "next").
  bool get isCurrentWeek => state == mondayOf(ref.read(todayProvider));

  void previous() => state = addDays(state, -DateTime.daysPerWeek);

  /// One week later, but never past the current week.
  void next() {
    if (!isCurrentWeek) state = addDays(state, DateTime.daysPerWeek);
  }
}

final selectedWeekProvider = NotifierProvider<SelectedWeek, String>(
  SelectedWeek.new,
);
