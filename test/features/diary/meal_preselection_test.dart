import 'package:flutter_test/flutter_test.dart';
import 'package:food_tracker/data/database.dart';
import 'package:food_tracker/features/diary/diary_repository.dart';

/// Minutes after midnight, for readable tests: `at(17, 30)`.
int at(int hour, [int minute = 0]) => hour * 60 + minute;

MealSlot meal(int id, String name, {int? start, bool hidden = false}) =>
    MealSlot(
      id: id,
      customName: name,
      position: id,
      isHidden: hidden,
      startMinute: start,
    );

/// The four default meals (same start times as `defaultMealSlots`).
final defaults = [
  meal(0, 'Frühstück', start: at(4)),
  meal(1, 'Mittagessen', start: at(11)),
  meal(2, 'Abendessen', start: at(17, 30)),
  meal(3, 'Snacks', start: at(15)),
];

String? pick(List<MealSlot> slots, int minute) =>
    preselectMealSlot(slots, minute)?.customName;

void main() {
  group('default meals', () {
    final cases = {
      at(4): 'Frühstück',
      at(7, 15): 'Frühstück',
      at(10, 59): 'Frühstück',
      at(11): 'Mittagessen',
      at(14, 59): 'Mittagessen',
      at(15): 'Snacks',
      at(17, 29): 'Snacks',
      at(17, 30): 'Abendessen',
      at(23, 59): 'Abendessen',
      // Before the earliest meal (04:00) the day wraps around to the meal
      // with the latest start time.
      at(0): 'Abendessen',
      at(3, 59): 'Abendessen',
    };
    cases.forEach((minute, expected) {
      test('${minute ~/ 60}:${(minute % 60).toString().padLeft(2, '0')} '
          '→ $expected', () {
        expect(pick(defaults, minute), expected);
      });
    });
  });

  test('hidden meals are never chosen', () {
    final slots = [
      meal(0, 'Frühstück', start: at(4), hidden: true),
      ...defaults.skip(1),
    ];
    // 08:00: breakfast is hidden, nothing else started yet → wrap around.
    expect(pick(slots, at(8)), 'Abendessen');
    final dinnerHidden = [
      ...defaults.take(2),
      meal(2, 'Abendessen', start: at(17, 30), hidden: true),
      defaults[3],
    ];
    expect(pick(dinnerHidden, at(20)), 'Snacks');
    // Wrap-around also skips the hidden dinner.
    expect(pick(dinnerHidden, at(2)), 'Snacks');
  });

  test('meals without start time are never chosen automatically', () {
    final slots = [
      meal(0, 'Frühstück', start: at(4)),
      meal(1, 'Zweites Frühstück'),
      meal(2, 'Mittagessen', start: at(11)),
    ];
    expect(pick(slots, at(9)), 'Frühstück');
    expect(pick(slots, at(13)), 'Mittagessen');
  });

  test('no start times at all → the first visible meal', () {
    final slots = [
      meal(0, 'Versteckt', hidden: true),
      meal(1, 'Erste'),
      meal(2, 'Zweite'),
    ];
    expect(pick(slots, at(12)), 'Erste');
  });

  test('same start time → the first one by position wins', () {
    final slots = [meal(0, 'A', start: at(12)), meal(1, 'B', start: at(12))];
    expect(pick(slots, at(13)), 'A');
    expect(pick(slots, at(1)), 'A');
  });

  test('no visible meal → null', () {
    expect(preselectMealSlot(const [], at(12)), isNull);
    expect(pick([meal(0, 'Weg', start: at(4), hidden: true)], at(12)), isNull);
  });

  test('minuteOfDay', () {
    expect(minuteOfDay(DateTime(2026, 11, 14, 17, 30)), 1050);
    expect(minuteOfDay(DateTime(2026, 11, 14)), 0);
  });
}
