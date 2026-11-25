import 'dart:io';

import 'package:clock/clock.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_tracker/data/database.dart';
import 'package:food_tracker/features/products/basic_foods.dart';
import 'package:food_tracker/features/products/food_source.dart';
import 'package:food_tracker/features/products/nutrients.dart';
import 'package:food_tracker/features/products/off_client.dart';
import 'package:food_tracker/features/products/product_repository.dart';

import '../helpers/pump_app.dart';

// The app is already installed with schema version 1. These tests create
// such an old database (from the real version 1 schema) and check that
// opening it with the current app upgrades it without losing data.

/// An in-memory database as a phone with schema version 1 has it: the four
/// tables, one meal, one cached product (a favourite) and one diary entry.
AppDatabase _openVersion1Database() => AppDatabase(
  NativeDatabase.memory(
    // Runs before drift looks at the version, like an old file on a phone.
    setup: (raw) {
      raw
        ..execute(File('test/fixtures/db/schema_v1.sql').readAsStringSync())
        ..execute(
          'INSERT INTO meal_slots (id, built_in, position, is_hidden, '
          "start_minute) VALUES (1, 'breakfast', 0, 0, 240)",
        )
        ..execute(
          'INSERT INTO foods (id, source, barcode, name, is_liquid, kcal, '
          "is_favourite, created_at) VALUES (1, 0, '4003586100313', "
          "'chipsfrisch ungarisch', 0, 533, 1, 1763118000)",
        )
        ..execute(
          'INSERT INTO diary_entries (day, meal_slot_id, food_id, name, '
          "amount, is_liquid, kcal, created_at) VALUES ('2026-11-14', 1, 1, "
          "'chipsfrisch ungarisch', 30, 0, 533, 1763118000)",
        )
        ..execute('PRAGMA user_version = 1');
    },
  ),
);

const _flatbread = BasicFood(
  code: 'B782100',
  nameDe: 'Weizenfladenbrot',
  nameEn: 'Wheat flatbread',
  nutrients: Nutrients(kcal: 248),
);

void main() {
  late AppDatabase db;

  setUp(() => db = _openVersion1Database());
  tearDown(() => db.close());

  Future<int> userVersion(AppDatabase db) async =>
      (await db.customSelect('PRAGMA user_version').getSingle()).read<int>(
        'user_version',
      );

  test('version 1 → 2 keeps every row and adds Foods.externalId', () async {
    final food = (await db.select(db.foods).get()).single;
    expect(food.name, 'chipsfrisch ungarisch');
    expect(food.source, FoodSource.openFoodFacts);
    expect(food.barcode, '4003586100313');
    expect(food.isFavourite, isTrue);
    expect(food.externalId, isNull);

    final entry = (await db.select(db.diaryEntries).get()).single;
    expect(entry.foodId, food.id);
    expect(entry.amount, 30);
    // No second set of default meals: onCreate did not run.
    expect(await db.select(db.mealSlots).get(), hasLength(1));
    expect(await userVersion(db), 2);
  });

  test('the upgraded schema is the same as a new installation', () async {
    final fresh = AppDatabase(NativeDatabase.memory());
    addTearDown(fresh.close);

    // Column order may differ (ALTER TABLE adds at the end), so compare
    // each table's columns by name.
    Future<Map<String, String>> columns(AppDatabase db, String table) async {
      final rows = await db.customSelect('PRAGMA table_info($table)').get();
      return {
        for (final row in rows)
          row.read<String>('name'): [
            row.read<String>('type'),
            row.read<int>('notnull'),
            row.readNullable<String>('dflt_value'),
            row.read<int>('pk'),
          ].join(' '),
      };
    }

    Future<Map<String, String?>> indexes(AppDatabase db) async {
      final rows = await db
          .customSelect(
            "SELECT name, sql FROM sqlite_master WHERE type = 'index' "
            'ORDER BY name',
          )
          .get();
      return {
        for (final row in rows)
          row.read<String>('name'): row.readNullable<String>('sql'),
      };
    }

    for (final table in ['foods', 'meal_slots', 'diary_entries', 'user_goal']) {
      expect(
        await columns(db, table),
        await columns(fresh, table),
        reason: table,
      );
    }
    expect(await indexes(db), await indexes(fresh));
    expect((await indexes(db))['foods_source_external_id'], contains('UNIQUE'));
    expect(await userVersion(fresh), 2);
  });

  test('after the upgrade a basic food can be stored once', () async {
    final repository = ProductRepository(
      db,
      OpenFoodFactsClient(offlineClient(), userAgent: 'test'),
      Clock.fixed(testNow),
    );
    final id = await repository.saveBasicFood(_flatbread, languageCode: 'de');
    expect(await repository.saveBasicFood(_flatbread, languageCode: 'de'), id);
    expect(await db.select(db.foods).get(), hasLength(2));

    // The unique index forbids a second row for the same BLS food …
    await expectLater(
      db
          .into(db.foods)
          .insert(
            FoodsCompanion.insert(
              source: FoodSource.bls,
              externalId: const Value('B782100'),
              name: 'Doppelt',
              createdAt: testNow,
            ),
          ),
      throwsA(isA<SqliteException>()),
    );
    // … but not several rows without an externalId (own foods).
    for (final name in ['Eigenes A', 'Eigenes B']) {
      await db
          .into(db.foods)
          .insert(
            FoodsCompanion.insert(
              source: FoodSource.user,
              name: name,
              createdAt: testNow,
            ),
          );
    }
    expect(await db.select(db.foods).get(), hasLength(4));
  });

  test('"Alle Daten löschen" still works on an upgraded database', () async {
    await db.deleteAllData();
    expect(await db.select(db.foods).get(), isEmpty);
    expect(await db.select(db.diaryEntries).get(), isEmpty);
    expect(await db.select(db.mealSlots).get(), hasLength(4));
  });
}
