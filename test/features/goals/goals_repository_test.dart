import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_tracker/core/clock.dart';
import 'package:food_tracker/data/database.dart';
import 'package:food_tracker/features/goals/goal_enums.dart';
import 'package:food_tracker/features/goals/goals_repository.dart';

import '../../helpers/pump_app.dart';

void main() {
  late AppDatabase db;
  late GoalsRepository repo;

  setUp(() {
    db = newTestDatabase();
    repo = GoalsRepository(db, Clock.fixed(testNow));
  });

  tearDown(() => db.close());

  test('there is no goal at first', () async {
    expect(await repo.getGoal(), isNull);
    expect(await repo.watchGoal().first, isNull);
  });

  test('saves a calculated goal with its inputs', () async {
    await repo.saveGoal(
      kcal: 2490,
      protein: 60,
      carbs: 330,
      fat: 83,
      sex: Sex.female,
      age: 30,
      heightCm: 168,
      weightKg: 62,
      activity: ActivityLevel.active,
      goalType: GoalType.maintain,
    );

    final goal = await repo.getGoal();
    expect(goal, isNotNull);
    expect(goal!.id, 1);
    expect(goal.kcal, 2490);
    expect(goal.protein, 60);
    expect(goal.sex, Sex.female);
    expect(goal.activity, ActivityLevel.active);
    expect(goal.updatedAt, testNow);
  });

  test(
    'a manual goal replaces the old one and clears calculator inputs',
    () async {
      await repo.saveGoal(
        kcal: 2490,
        sex: Sex.male,
        age: 40,
        heightCm: 180,
        weightKg: 80,
        activity: ActivityLevel.low,
        goalType: GoalType.lose,
      );
      await repo.saveGoal(kcal: 1800, protein: 70);

      final rows = await db.select(db.userGoal).get();
      expect(rows, hasLength(1));
      final goal = rows.single;
      expect(goal.kcal, 1800);
      expect(goal.protein, 70);
      expect(goal.carbs, isNull);
      expect(goal.sex, isNull);
      expect(goal.age, isNull);
      expect(goal.goalType, isNull);
    },
  );

  test('clearGoal removes it; watchGoal follows the changes', () async {
    final values = repo.watchGoal().map((goal) => goal?.kcal);
    final expectation = expectLater(values, emitsInOrder([null, 2000, null]));
    await Future<void>.delayed(Duration.zero);
    await repo.saveGoal(kcal: 2000);
    await Future<void>.delayed(Duration.zero);
    await repo.clearGoal();
    await expectation;
  });

  test('rejects a goal of 0 kcal or less', () {
    expect(() => repo.saveGoal(kcal: 0), throwsArgumentError);
  });

  test('goalProvider reads from the database', () async {
    final container = ProviderContainer.test(
      overrides: [
        databaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(Clock.fixed(testNow)),
      ],
    );
    await container.read(goalsRepositoryProvider).saveGoal(kcal: 2100);
    // Riverpod 3 pauses providers nobody listens to, so listen first.
    final subscription = container.listen(goalProvider.future, (_, _) {});
    final goal = await subscription.read();
    expect(goal?.kcal, 2100);
  });
}
