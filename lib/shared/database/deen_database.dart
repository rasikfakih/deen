import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'deen_database.g.dart';

/// Drift tables - v1 subset per task spec.
/// Full v1 will later add HasanatLedger, Bookmarks, Favorites, etc.
/// All writes are offline-first; heavy work should be run off main isolate
/// via NativeDatabase.createInBackground where used.

class UserGoals extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get dailyTargetMinutes =>
      integer().withDefault(const Constant(15))();
  IntColumn get dailyTargetAyahs => integer().withDefault(const Constant(5))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
}

class DailyReads extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get date => text().customConstraint('NOT NULL UNIQUE')();
  IntColumn get minutesRead => integer().withDefault(const Constant(0))();
  IntColumn get ayahsRead => integer().withDefault(const Constant(0))();
  IntColumn get hasanatEarned => integer().withDefault(const Constant(0))();
}

class Streaks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get currentStreak => integer().withDefault(const Constant(0))();
  IntColumn get longestStreak => integer().withDefault(const Constant(0))();
  IntColumn get availableFreezes => integer().withDefault(const Constant(0))();
  TextColumn get lastReadDate => text().nullable()();
}

class SettingsCache extends Table {
  TextColumn get key => text()();
  TextColumn get value => text().nullable()();

  @override
  Set<Column> get primaryKey => {key};
}

class Bookmarks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get surahId => integer()();
  IntColumn get ayahId => integer()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {surahId, ayahId},
  ];
}

class LastRead extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  IntColumn get surahId => integer()();
  IntColumn get ayahId => integer()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [UserGoals, DailyReads, Streaks, SettingsCache, Bookmarks, LastRead],
)
class DeenDatabase extends _$DeenDatabase {
  DeenDatabase() : super(_openConnection());

  /// Constructor for tests - in-memory database (fakes over mocks, DEEN 14).
  DeenDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from == 1) {
        await m.createTable(bookmarks);
        await m.createTable(lastRead);
      }
    },
  );

  // Helpers for repository convenience.
  Future<UserGoal?> get activeGoal => (select(
    userGoals,
  )..where((t) => t.isActive.equals(true))).getSingleOrNull();

  Future<DailyRead?> getDailyReadByDate(String date) =>
      (select(dailyReads)..where((t) => t.date.equals(date))).getSingleOrNull();

  Future<Streak?> get streak =>
      (select(streaks)..where((t) => t.id.equals(1))).getSingleOrNull();

  Future<Streak> getOrCreateStreak() async {
    final existing = await streak;
    if (existing != null) return existing;
    return into(streaks).insertReturning(
      const StreaksCompanion(
        id: Value(1),
        currentStreak: Value(0),
        longestStreak: Value(0),
        availableFreezes: Value(0),
        lastReadDate: Value.absent(),
      ),
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'deen.sqlite'));
    // Off main isolate per DEEN 7.
    return NativeDatabase.createInBackground(file);
  });
}
