import 'package:clock/clock.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/clock.dart';
import '../../data/database.dart';
import 'goal_enums.dart';

/// Reads and stores the user's daily goal (one row with id 1, or none).
class GoalsRepository {
  GoalsRepository(this._db, this._clock);

  /// The goal table has at most this one row.
  static const _goalId = 1;

  final AppDatabase _db;
  final Clock _clock;

  /// The goal; emits again when it changes, and `null` when none is set.
  Stream<UserGoalRow?> watchGoal() => (_db.select(
    _db.userGoal,
  )..where((g) => g.id.equals(_goalId))).watchSingleOrNull();

  Future<UserGoalRow?> getGoal() => (_db.select(
    _db.userGoal,
  )..where((g) => g.id.equals(_goalId))).getSingleOrNull();

  /// Saves the goal and replaces any previous one.
  ///
  /// Macro goals are grams per day. The calculator inputs ([sex] … [goalType])
  /// are kept so the calculator can show them again; leave them `null` for a
  /// goal typed in by hand (old inputs are then removed).
  Future<void> saveGoal({
    required int kcal,
    double? protein,
    double? carbs,
    double? fat,
    Sex? sex,
    int? age,
    double? heightCm,
    double? weightKg,
    ActivityLevel? activity,
    GoalType? goalType,
  }) {
    if (kcal <= 0) throw ArgumentError.value(kcal, 'kcal', 'must be > 0');
    // Every column is written explicitly (also with null). Otherwise an
    // update would keep old calculator inputs next to a manual goal.
    return _db
        .into(_db.userGoal)
        .insertOnConflictUpdate(
          UserGoalCompanion(
            id: const Value(_goalId),
            kcal: Value(kcal),
            protein: Value(protein),
            carbs: Value(carbs),
            fat: Value(fat),
            sex: Value(sex),
            age: Value(age),
            heightCm: Value(heightCm),
            weightKg: Value(weightKg),
            activity: Value(activity),
            goalType: Value(goalType),
            updatedAt: Value(_clock.now()),
          ),
        );
  }

  /// Removes the goal (the Today screen then shows "kcal gegessen").
  Future<void> clearGoal() => _db.delete(_db.userGoal).go();
}

final goalsRepositoryProvider = Provider<GoalsRepository>((ref) {
  return GoalsRepository(ref.watch(databaseProvider), ref.watch(clockProvider));
});

/// The current goal, or `null` when none is set.
final goalProvider = StreamProvider<UserGoalRow?>(
  (ref) => ref.watch(goalsRepositoryProvider).watchGoal(),
);
