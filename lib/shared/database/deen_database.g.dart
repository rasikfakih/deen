// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deen_database.dart';

// ignore_for_file: type=lint
class $UserGoalsTable extends UserGoals
    with TableInfo<$UserGoalsTable, UserGoal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserGoalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dailyTargetMinutesMeta =
      const VerificationMeta('dailyTargetMinutes');
  @override
  late final GeneratedColumn<int> dailyTargetMinutes = GeneratedColumn<int>(
    'daily_target_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(15),
  );
  static const VerificationMeta _dailyTargetAyahsMeta = const VerificationMeta(
    'dailyTargetAyahs',
  );
  @override
  late final GeneratedColumn<int> dailyTargetAyahs = GeneratedColumn<int>(
    'daily_target_ayahs',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(5),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    dailyTargetMinutes,
    dailyTargetAyahs,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_goals';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserGoal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('daily_target_minutes')) {
      context.handle(
        _dailyTargetMinutesMeta,
        dailyTargetMinutes.isAcceptableOrUnknown(
          data['daily_target_minutes']!,
          _dailyTargetMinutesMeta,
        ),
      );
    }
    if (data.containsKey('daily_target_ayahs')) {
      context.handle(
        _dailyTargetAyahsMeta,
        dailyTargetAyahs.isAcceptableOrUnknown(
          data['daily_target_ayahs']!,
          _dailyTargetAyahsMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserGoal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserGoal(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      dailyTargetMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}daily_target_minutes'],
      )!,
      dailyTargetAyahs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}daily_target_ayahs'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $UserGoalsTable createAlias(String alias) {
    return $UserGoalsTable(attachedDatabase, alias);
  }
}

class UserGoal extends DataClass implements Insertable<UserGoal> {
  final int id;
  final int dailyTargetMinutes;
  final int dailyTargetAyahs;
  final bool isActive;
  const UserGoal({
    required this.id,
    required this.dailyTargetMinutes,
    required this.dailyTargetAyahs,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['daily_target_minutes'] = Variable<int>(dailyTargetMinutes);
    map['daily_target_ayahs'] = Variable<int>(dailyTargetAyahs);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  UserGoalsCompanion toCompanion(bool nullToAbsent) {
    return UserGoalsCompanion(
      id: Value(id),
      dailyTargetMinutes: Value(dailyTargetMinutes),
      dailyTargetAyahs: Value(dailyTargetAyahs),
      isActive: Value(isActive),
    );
  }

  factory UserGoal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserGoal(
      id: serializer.fromJson<int>(json['id']),
      dailyTargetMinutes: serializer.fromJson<int>(json['dailyTargetMinutes']),
      dailyTargetAyahs: serializer.fromJson<int>(json['dailyTargetAyahs']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'dailyTargetMinutes': serializer.toJson<int>(dailyTargetMinutes),
      'dailyTargetAyahs': serializer.toJson<int>(dailyTargetAyahs),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  UserGoal copyWith({
    int? id,
    int? dailyTargetMinutes,
    int? dailyTargetAyahs,
    bool? isActive,
  }) => UserGoal(
    id: id ?? this.id,
    dailyTargetMinutes: dailyTargetMinutes ?? this.dailyTargetMinutes,
    dailyTargetAyahs: dailyTargetAyahs ?? this.dailyTargetAyahs,
    isActive: isActive ?? this.isActive,
  );
  UserGoal copyWithCompanion(UserGoalsCompanion data) {
    return UserGoal(
      id: data.id.present ? data.id.value : this.id,
      dailyTargetMinutes: data.dailyTargetMinutes.present
          ? data.dailyTargetMinutes.value
          : this.dailyTargetMinutes,
      dailyTargetAyahs: data.dailyTargetAyahs.present
          ? data.dailyTargetAyahs.value
          : this.dailyTargetAyahs,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserGoal(')
          ..write('id: $id, ')
          ..write('dailyTargetMinutes: $dailyTargetMinutes, ')
          ..write('dailyTargetAyahs: $dailyTargetAyahs, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, dailyTargetMinutes, dailyTargetAyahs, isActive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserGoal &&
          other.id == this.id &&
          other.dailyTargetMinutes == this.dailyTargetMinutes &&
          other.dailyTargetAyahs == this.dailyTargetAyahs &&
          other.isActive == this.isActive);
}

class UserGoalsCompanion extends UpdateCompanion<UserGoal> {
  final Value<int> id;
  final Value<int> dailyTargetMinutes;
  final Value<int> dailyTargetAyahs;
  final Value<bool> isActive;
  const UserGoalsCompanion({
    this.id = const Value.absent(),
    this.dailyTargetMinutes = const Value.absent(),
    this.dailyTargetAyahs = const Value.absent(),
    this.isActive = const Value.absent(),
  });
  UserGoalsCompanion.insert({
    this.id = const Value.absent(),
    this.dailyTargetMinutes = const Value.absent(),
    this.dailyTargetAyahs = const Value.absent(),
    this.isActive = const Value.absent(),
  });
  static Insertable<UserGoal> custom({
    Expression<int>? id,
    Expression<int>? dailyTargetMinutes,
    Expression<int>? dailyTargetAyahs,
    Expression<bool>? isActive,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dailyTargetMinutes != null)
        'daily_target_minutes': dailyTargetMinutes,
      if (dailyTargetAyahs != null) 'daily_target_ayahs': dailyTargetAyahs,
      if (isActive != null) 'is_active': isActive,
    });
  }

  UserGoalsCompanion copyWith({
    Value<int>? id,
    Value<int>? dailyTargetMinutes,
    Value<int>? dailyTargetAyahs,
    Value<bool>? isActive,
  }) {
    return UserGoalsCompanion(
      id: id ?? this.id,
      dailyTargetMinutes: dailyTargetMinutes ?? this.dailyTargetMinutes,
      dailyTargetAyahs: dailyTargetAyahs ?? this.dailyTargetAyahs,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (dailyTargetMinutes.present) {
      map['daily_target_minutes'] = Variable<int>(dailyTargetMinutes.value);
    }
    if (dailyTargetAyahs.present) {
      map['daily_target_ayahs'] = Variable<int>(dailyTargetAyahs.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserGoalsCompanion(')
          ..write('id: $id, ')
          ..write('dailyTargetMinutes: $dailyTargetMinutes, ')
          ..write('dailyTargetAyahs: $dailyTargetAyahs, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }
}

class $DailyReadsTable extends DailyReads
    with TableInfo<$DailyReadsTable, DailyRead> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyReadsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL UNIQUE',
  );
  static const VerificationMeta _minutesReadMeta = const VerificationMeta(
    'minutesRead',
  );
  @override
  late final GeneratedColumn<int> minutesRead = GeneratedColumn<int>(
    'minutes_read',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _ayahsReadMeta = const VerificationMeta(
    'ayahsRead',
  );
  @override
  late final GeneratedColumn<int> ayahsRead = GeneratedColumn<int>(
    'ayahs_read',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _hasanatEarnedMeta = const VerificationMeta(
    'hasanatEarned',
  );
  @override
  late final GeneratedColumn<int> hasanatEarned = GeneratedColumn<int>(
    'hasanat_earned',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    minutesRead,
    ayahsRead,
    hasanatEarned,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_reads';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyRead> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('minutes_read')) {
      context.handle(
        _minutesReadMeta,
        minutesRead.isAcceptableOrUnknown(
          data['minutes_read']!,
          _minutesReadMeta,
        ),
      );
    }
    if (data.containsKey('ayahs_read')) {
      context.handle(
        _ayahsReadMeta,
        ayahsRead.isAcceptableOrUnknown(data['ayahs_read']!, _ayahsReadMeta),
      );
    }
    if (data.containsKey('hasanat_earned')) {
      context.handle(
        _hasanatEarnedMeta,
        hasanatEarned.isAcceptableOrUnknown(
          data['hasanat_earned']!,
          _hasanatEarnedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DailyRead map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyRead(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      minutesRead: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minutes_read'],
      )!,
      ayahsRead: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ayahs_read'],
      )!,
      hasanatEarned: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hasanat_earned'],
      )!,
    );
  }

  @override
  $DailyReadsTable createAlias(String alias) {
    return $DailyReadsTable(attachedDatabase, alias);
  }
}

class DailyRead extends DataClass implements Insertable<DailyRead> {
  final int id;
  final String date;
  final int minutesRead;
  final int ayahsRead;
  final int hasanatEarned;
  const DailyRead({
    required this.id,
    required this.date,
    required this.minutesRead,
    required this.ayahsRead,
    required this.hasanatEarned,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<String>(date);
    map['minutes_read'] = Variable<int>(minutesRead);
    map['ayahs_read'] = Variable<int>(ayahsRead);
    map['hasanat_earned'] = Variable<int>(hasanatEarned);
    return map;
  }

  DailyReadsCompanion toCompanion(bool nullToAbsent) {
    return DailyReadsCompanion(
      id: Value(id),
      date: Value(date),
      minutesRead: Value(minutesRead),
      ayahsRead: Value(ayahsRead),
      hasanatEarned: Value(hasanatEarned),
    );
  }

  factory DailyRead.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyRead(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<String>(json['date']),
      minutesRead: serializer.fromJson<int>(json['minutesRead']),
      ayahsRead: serializer.fromJson<int>(json['ayahsRead']),
      hasanatEarned: serializer.fromJson<int>(json['hasanatEarned']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<String>(date),
      'minutesRead': serializer.toJson<int>(minutesRead),
      'ayahsRead': serializer.toJson<int>(ayahsRead),
      'hasanatEarned': serializer.toJson<int>(hasanatEarned),
    };
  }

  DailyRead copyWith({
    int? id,
    String? date,
    int? minutesRead,
    int? ayahsRead,
    int? hasanatEarned,
  }) => DailyRead(
    id: id ?? this.id,
    date: date ?? this.date,
    minutesRead: minutesRead ?? this.minutesRead,
    ayahsRead: ayahsRead ?? this.ayahsRead,
    hasanatEarned: hasanatEarned ?? this.hasanatEarned,
  );
  DailyRead copyWithCompanion(DailyReadsCompanion data) {
    return DailyRead(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      minutesRead: data.minutesRead.present
          ? data.minutesRead.value
          : this.minutesRead,
      ayahsRead: data.ayahsRead.present ? data.ayahsRead.value : this.ayahsRead,
      hasanatEarned: data.hasanatEarned.present
          ? data.hasanatEarned.value
          : this.hasanatEarned,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyRead(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('minutesRead: $minutesRead, ')
          ..write('ayahsRead: $ayahsRead, ')
          ..write('hasanatEarned: $hasanatEarned')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, date, minutesRead, ayahsRead, hasanatEarned);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyRead &&
          other.id == this.id &&
          other.date == this.date &&
          other.minutesRead == this.minutesRead &&
          other.ayahsRead == this.ayahsRead &&
          other.hasanatEarned == this.hasanatEarned);
}

class DailyReadsCompanion extends UpdateCompanion<DailyRead> {
  final Value<int> id;
  final Value<String> date;
  final Value<int> minutesRead;
  final Value<int> ayahsRead;
  final Value<int> hasanatEarned;
  const DailyReadsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.minutesRead = const Value.absent(),
    this.ayahsRead = const Value.absent(),
    this.hasanatEarned = const Value.absent(),
  });
  DailyReadsCompanion.insert({
    this.id = const Value.absent(),
    required String date,
    this.minutesRead = const Value.absent(),
    this.ayahsRead = const Value.absent(),
    this.hasanatEarned = const Value.absent(),
  }) : date = Value(date);
  static Insertable<DailyRead> custom({
    Expression<int>? id,
    Expression<String>? date,
    Expression<int>? minutesRead,
    Expression<int>? ayahsRead,
    Expression<int>? hasanatEarned,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (minutesRead != null) 'minutes_read': minutesRead,
      if (ayahsRead != null) 'ayahs_read': ayahsRead,
      if (hasanatEarned != null) 'hasanat_earned': hasanatEarned,
    });
  }

  DailyReadsCompanion copyWith({
    Value<int>? id,
    Value<String>? date,
    Value<int>? minutesRead,
    Value<int>? ayahsRead,
    Value<int>? hasanatEarned,
  }) {
    return DailyReadsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      minutesRead: minutesRead ?? this.minutesRead,
      ayahsRead: ayahsRead ?? this.ayahsRead,
      hasanatEarned: hasanatEarned ?? this.hasanatEarned,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (minutesRead.present) {
      map['minutes_read'] = Variable<int>(minutesRead.value);
    }
    if (ayahsRead.present) {
      map['ayahs_read'] = Variable<int>(ayahsRead.value);
    }
    if (hasanatEarned.present) {
      map['hasanat_earned'] = Variable<int>(hasanatEarned.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyReadsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('minutesRead: $minutesRead, ')
          ..write('ayahsRead: $ayahsRead, ')
          ..write('hasanatEarned: $hasanatEarned')
          ..write(')'))
        .toString();
  }
}

class $StreaksTable extends Streaks with TableInfo<$StreaksTable, Streak> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StreaksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _currentStreakMeta = const VerificationMeta(
    'currentStreak',
  );
  @override
  late final GeneratedColumn<int> currentStreak = GeneratedColumn<int>(
    'current_streak',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _longestStreakMeta = const VerificationMeta(
    'longestStreak',
  );
  @override
  late final GeneratedColumn<int> longestStreak = GeneratedColumn<int>(
    'longest_streak',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _availableFreezesMeta = const VerificationMeta(
    'availableFreezes',
  );
  @override
  late final GeneratedColumn<int> availableFreezes = GeneratedColumn<int>(
    'available_freezes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastReadDateMeta = const VerificationMeta(
    'lastReadDate',
  );
  @override
  late final GeneratedColumn<String> lastReadDate = GeneratedColumn<String>(
    'last_read_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    currentStreak,
    longestStreak,
    availableFreezes,
    lastReadDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'streaks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Streak> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('current_streak')) {
      context.handle(
        _currentStreakMeta,
        currentStreak.isAcceptableOrUnknown(
          data['current_streak']!,
          _currentStreakMeta,
        ),
      );
    }
    if (data.containsKey('longest_streak')) {
      context.handle(
        _longestStreakMeta,
        longestStreak.isAcceptableOrUnknown(
          data['longest_streak']!,
          _longestStreakMeta,
        ),
      );
    }
    if (data.containsKey('available_freezes')) {
      context.handle(
        _availableFreezesMeta,
        availableFreezes.isAcceptableOrUnknown(
          data['available_freezes']!,
          _availableFreezesMeta,
        ),
      );
    }
    if (data.containsKey('last_read_date')) {
      context.handle(
        _lastReadDateMeta,
        lastReadDate.isAcceptableOrUnknown(
          data['last_read_date']!,
          _lastReadDateMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Streak map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Streak(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      currentStreak: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_streak'],
      )!,
      longestStreak: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}longest_streak'],
      )!,
      availableFreezes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}available_freezes'],
      )!,
      lastReadDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_read_date'],
      ),
    );
  }

  @override
  $StreaksTable createAlias(String alias) {
    return $StreaksTable(attachedDatabase, alias);
  }
}

class Streak extends DataClass implements Insertable<Streak> {
  final int id;
  final int currentStreak;
  final int longestStreak;
  final int availableFreezes;
  final String? lastReadDate;
  const Streak({
    required this.id,
    required this.currentStreak,
    required this.longestStreak,
    required this.availableFreezes,
    this.lastReadDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['current_streak'] = Variable<int>(currentStreak);
    map['longest_streak'] = Variable<int>(longestStreak);
    map['available_freezes'] = Variable<int>(availableFreezes);
    if (!nullToAbsent || lastReadDate != null) {
      map['last_read_date'] = Variable<String>(lastReadDate);
    }
    return map;
  }

  StreaksCompanion toCompanion(bool nullToAbsent) {
    return StreaksCompanion(
      id: Value(id),
      currentStreak: Value(currentStreak),
      longestStreak: Value(longestStreak),
      availableFreezes: Value(availableFreezes),
      lastReadDate: lastReadDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReadDate),
    );
  }

  factory Streak.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Streak(
      id: serializer.fromJson<int>(json['id']),
      currentStreak: serializer.fromJson<int>(json['currentStreak']),
      longestStreak: serializer.fromJson<int>(json['longestStreak']),
      availableFreezes: serializer.fromJson<int>(json['availableFreezes']),
      lastReadDate: serializer.fromJson<String?>(json['lastReadDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'currentStreak': serializer.toJson<int>(currentStreak),
      'longestStreak': serializer.toJson<int>(longestStreak),
      'availableFreezes': serializer.toJson<int>(availableFreezes),
      'lastReadDate': serializer.toJson<String?>(lastReadDate),
    };
  }

  Streak copyWith({
    int? id,
    int? currentStreak,
    int? longestStreak,
    int? availableFreezes,
    Value<String?> lastReadDate = const Value.absent(),
  }) => Streak(
    id: id ?? this.id,
    currentStreak: currentStreak ?? this.currentStreak,
    longestStreak: longestStreak ?? this.longestStreak,
    availableFreezes: availableFreezes ?? this.availableFreezes,
    lastReadDate: lastReadDate.present ? lastReadDate.value : this.lastReadDate,
  );
  Streak copyWithCompanion(StreaksCompanion data) {
    return Streak(
      id: data.id.present ? data.id.value : this.id,
      currentStreak: data.currentStreak.present
          ? data.currentStreak.value
          : this.currentStreak,
      longestStreak: data.longestStreak.present
          ? data.longestStreak.value
          : this.longestStreak,
      availableFreezes: data.availableFreezes.present
          ? data.availableFreezes.value
          : this.availableFreezes,
      lastReadDate: data.lastReadDate.present
          ? data.lastReadDate.value
          : this.lastReadDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Streak(')
          ..write('id: $id, ')
          ..write('currentStreak: $currentStreak, ')
          ..write('longestStreak: $longestStreak, ')
          ..write('availableFreezes: $availableFreezes, ')
          ..write('lastReadDate: $lastReadDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    currentStreak,
    longestStreak,
    availableFreezes,
    lastReadDate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Streak &&
          other.id == this.id &&
          other.currentStreak == this.currentStreak &&
          other.longestStreak == this.longestStreak &&
          other.availableFreezes == this.availableFreezes &&
          other.lastReadDate == this.lastReadDate);
}

class StreaksCompanion extends UpdateCompanion<Streak> {
  final Value<int> id;
  final Value<int> currentStreak;
  final Value<int> longestStreak;
  final Value<int> availableFreezes;
  final Value<String?> lastReadDate;
  const StreaksCompanion({
    this.id = const Value.absent(),
    this.currentStreak = const Value.absent(),
    this.longestStreak = const Value.absent(),
    this.availableFreezes = const Value.absent(),
    this.lastReadDate = const Value.absent(),
  });
  StreaksCompanion.insert({
    this.id = const Value.absent(),
    this.currentStreak = const Value.absent(),
    this.longestStreak = const Value.absent(),
    this.availableFreezes = const Value.absent(),
    this.lastReadDate = const Value.absent(),
  });
  static Insertable<Streak> custom({
    Expression<int>? id,
    Expression<int>? currentStreak,
    Expression<int>? longestStreak,
    Expression<int>? availableFreezes,
    Expression<String>? lastReadDate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (currentStreak != null) 'current_streak': currentStreak,
      if (longestStreak != null) 'longest_streak': longestStreak,
      if (availableFreezes != null) 'available_freezes': availableFreezes,
      if (lastReadDate != null) 'last_read_date': lastReadDate,
    });
  }

  StreaksCompanion copyWith({
    Value<int>? id,
    Value<int>? currentStreak,
    Value<int>? longestStreak,
    Value<int>? availableFreezes,
    Value<String?>? lastReadDate,
  }) {
    return StreaksCompanion(
      id: id ?? this.id,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      availableFreezes: availableFreezes ?? this.availableFreezes,
      lastReadDate: lastReadDate ?? this.lastReadDate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (currentStreak.present) {
      map['current_streak'] = Variable<int>(currentStreak.value);
    }
    if (longestStreak.present) {
      map['longest_streak'] = Variable<int>(longestStreak.value);
    }
    if (availableFreezes.present) {
      map['available_freezes'] = Variable<int>(availableFreezes.value);
    }
    if (lastReadDate.present) {
      map['last_read_date'] = Variable<String>(lastReadDate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StreaksCompanion(')
          ..write('id: $id, ')
          ..write('currentStreak: $currentStreak, ')
          ..write('longestStreak: $longestStreak, ')
          ..write('availableFreezes: $availableFreezes, ')
          ..write('lastReadDate: $lastReadDate')
          ..write(')'))
        .toString();
  }
}

class $SettingsCacheTable extends SettingsCache
    with TableInfo<$SettingsCacheTable, SettingsCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingsCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingsCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingsCacheData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      ),
    );
  }

  @override
  $SettingsCacheTable createAlias(String alias) {
    return $SettingsCacheTable(attachedDatabase, alias);
  }
}

class SettingsCacheData extends DataClass
    implements Insertable<SettingsCacheData> {
  final String key;
  final String? value;
  const SettingsCacheData({required this.key, this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<String>(value);
    }
    return map;
  }

  SettingsCacheCompanion toCompanion(bool nullToAbsent) {
    return SettingsCacheCompanion(
      key: Value(key),
      value: value == null && nullToAbsent
          ? const Value.absent()
          : Value(value),
    );
  }

  factory SettingsCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingsCacheData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String?>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String?>(value),
    };
  }

  SettingsCacheData copyWith({
    String? key,
    Value<String?> value = const Value.absent(),
  }) => SettingsCacheData(
    key: key ?? this.key,
    value: value.present ? value.value : this.value,
  );
  SettingsCacheData copyWithCompanion(SettingsCacheCompanion data) {
    return SettingsCacheData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCacheData(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingsCacheData &&
          other.key == this.key &&
          other.value == this.value);
}

class SettingsCacheCompanion extends UpdateCompanion<SettingsCacheData> {
  final Value<String> key;
  final Value<String?> value;
  final Value<int> rowid;
  const SettingsCacheCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCacheCompanion.insert({
    required String key,
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key);
  static Insertable<SettingsCacheData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCacheCompanion copyWith({
    Value<String>? key,
    Value<String?>? value,
    Value<int>? rowid,
  }) {
    return SettingsCacheCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCacheCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BookmarksTable extends Bookmarks
    with TableInfo<$BookmarksTable, Bookmark> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookmarksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _surahIdMeta = const VerificationMeta(
    'surahId',
  );
  @override
  late final GeneratedColumn<int> surahId = GeneratedColumn<int>(
    'surah_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ayahIdMeta = const VerificationMeta('ayahId');
  @override
  late final GeneratedColumn<int> ayahId = GeneratedColumn<int>(
    'ayah_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, surahId, ayahId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bookmarks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Bookmark> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('surah_id')) {
      context.handle(
        _surahIdMeta,
        surahId.isAcceptableOrUnknown(data['surah_id']!, _surahIdMeta),
      );
    } else if (isInserting) {
      context.missing(_surahIdMeta);
    }
    if (data.containsKey('ayah_id')) {
      context.handle(
        _ayahIdMeta,
        ayahId.isAcceptableOrUnknown(data['ayah_id']!, _ayahIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ayahIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {surahId, ayahId},
  ];
  @override
  Bookmark map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Bookmark(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      surahId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}surah_id'],
      )!,
      ayahId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ayah_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $BookmarksTable createAlias(String alias) {
    return $BookmarksTable(attachedDatabase, alias);
  }
}

class Bookmark extends DataClass implements Insertable<Bookmark> {
  final int id;
  final int surahId;
  final int ayahId;
  final DateTime createdAt;
  const Bookmark({
    required this.id,
    required this.surahId,
    required this.ayahId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['surah_id'] = Variable<int>(surahId);
    map['ayah_id'] = Variable<int>(ayahId);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BookmarksCompanion toCompanion(bool nullToAbsent) {
    return BookmarksCompanion(
      id: Value(id),
      surahId: Value(surahId),
      ayahId: Value(ayahId),
      createdAt: Value(createdAt),
    );
  }

  factory Bookmark.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Bookmark(
      id: serializer.fromJson<int>(json['id']),
      surahId: serializer.fromJson<int>(json['surahId']),
      ayahId: serializer.fromJson<int>(json['ayahId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'surahId': serializer.toJson<int>(surahId),
      'ayahId': serializer.toJson<int>(ayahId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Bookmark copyWith({
    int? id,
    int? surahId,
    int? ayahId,
    DateTime? createdAt,
  }) => Bookmark(
    id: id ?? this.id,
    surahId: surahId ?? this.surahId,
    ayahId: ayahId ?? this.ayahId,
    createdAt: createdAt ?? this.createdAt,
  );
  Bookmark copyWithCompanion(BookmarksCompanion data) {
    return Bookmark(
      id: data.id.present ? data.id.value : this.id,
      surahId: data.surahId.present ? data.surahId.value : this.surahId,
      ayahId: data.ayahId.present ? data.ayahId.value : this.ayahId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Bookmark(')
          ..write('id: $id, ')
          ..write('surahId: $surahId, ')
          ..write('ayahId: $ayahId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, surahId, ayahId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Bookmark &&
          other.id == this.id &&
          other.surahId == this.surahId &&
          other.ayahId == this.ayahId &&
          other.createdAt == this.createdAt);
}

class BookmarksCompanion extends UpdateCompanion<Bookmark> {
  final Value<int> id;
  final Value<int> surahId;
  final Value<int> ayahId;
  final Value<DateTime> createdAt;
  const BookmarksCompanion({
    this.id = const Value.absent(),
    this.surahId = const Value.absent(),
    this.ayahId = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  BookmarksCompanion.insert({
    this.id = const Value.absent(),
    required int surahId,
    required int ayahId,
    this.createdAt = const Value.absent(),
  }) : surahId = Value(surahId),
       ayahId = Value(ayahId);
  static Insertable<Bookmark> custom({
    Expression<int>? id,
    Expression<int>? surahId,
    Expression<int>? ayahId,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (surahId != null) 'surah_id': surahId,
      if (ayahId != null) 'ayah_id': ayahId,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  BookmarksCompanion copyWith({
    Value<int>? id,
    Value<int>? surahId,
    Value<int>? ayahId,
    Value<DateTime>? createdAt,
  }) {
    return BookmarksCompanion(
      id: id ?? this.id,
      surahId: surahId ?? this.surahId,
      ayahId: ayahId ?? this.ayahId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (surahId.present) {
      map['surah_id'] = Variable<int>(surahId.value);
    }
    if (ayahId.present) {
      map['ayah_id'] = Variable<int>(ayahId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookmarksCompanion(')
          ..write('id: $id, ')
          ..write('surahId: $surahId, ')
          ..write('ayahId: $ayahId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $LastReadTable extends LastRead
    with TableInfo<$LastReadTable, LastReadData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LastReadTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _surahIdMeta = const VerificationMeta(
    'surahId',
  );
  @override
  late final GeneratedColumn<int> surahId = GeneratedColumn<int>(
    'surah_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ayahIdMeta = const VerificationMeta('ayahId');
  @override
  late final GeneratedColumn<int> ayahId = GeneratedColumn<int>(
    'ayah_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, surahId, ayahId, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'last_read';
  @override
  VerificationContext validateIntegrity(
    Insertable<LastReadData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('surah_id')) {
      context.handle(
        _surahIdMeta,
        surahId.isAcceptableOrUnknown(data['surah_id']!, _surahIdMeta),
      );
    } else if (isInserting) {
      context.missing(_surahIdMeta);
    }
    if (data.containsKey('ayah_id')) {
      context.handle(
        _ayahIdMeta,
        ayahId.isAcceptableOrUnknown(data['ayah_id']!, _ayahIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ayahIdMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LastReadData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LastReadData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      surahId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}surah_id'],
      )!,
      ayahId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ayah_id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LastReadTable createAlias(String alias) {
    return $LastReadTable(attachedDatabase, alias);
  }
}

class LastReadData extends DataClass implements Insertable<LastReadData> {
  final int id;
  final int surahId;
  final int ayahId;
  final DateTime updatedAt;
  const LastReadData({
    required this.id,
    required this.surahId,
    required this.ayahId,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['surah_id'] = Variable<int>(surahId);
    map['ayah_id'] = Variable<int>(ayahId);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LastReadCompanion toCompanion(bool nullToAbsent) {
    return LastReadCompanion(
      id: Value(id),
      surahId: Value(surahId),
      ayahId: Value(ayahId),
      updatedAt: Value(updatedAt),
    );
  }

  factory LastReadData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LastReadData(
      id: serializer.fromJson<int>(json['id']),
      surahId: serializer.fromJson<int>(json['surahId']),
      ayahId: serializer.fromJson<int>(json['ayahId']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'surahId': serializer.toJson<int>(surahId),
      'ayahId': serializer.toJson<int>(ayahId),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LastReadData copyWith({
    int? id,
    int? surahId,
    int? ayahId,
    DateTime? updatedAt,
  }) => LastReadData(
    id: id ?? this.id,
    surahId: surahId ?? this.surahId,
    ayahId: ayahId ?? this.ayahId,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LastReadData copyWithCompanion(LastReadCompanion data) {
    return LastReadData(
      id: data.id.present ? data.id.value : this.id,
      surahId: data.surahId.present ? data.surahId.value : this.surahId,
      ayahId: data.ayahId.present ? data.ayahId.value : this.ayahId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LastReadData(')
          ..write('id: $id, ')
          ..write('surahId: $surahId, ')
          ..write('ayahId: $ayahId, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, surahId, ayahId, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LastReadData &&
          other.id == this.id &&
          other.surahId == this.surahId &&
          other.ayahId == this.ayahId &&
          other.updatedAt == this.updatedAt);
}

class LastReadCompanion extends UpdateCompanion<LastReadData> {
  final Value<int> id;
  final Value<int> surahId;
  final Value<int> ayahId;
  final Value<DateTime> updatedAt;
  const LastReadCompanion({
    this.id = const Value.absent(),
    this.surahId = const Value.absent(),
    this.ayahId = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  LastReadCompanion.insert({
    this.id = const Value.absent(),
    required int surahId,
    required int ayahId,
    this.updatedAt = const Value.absent(),
  }) : surahId = Value(surahId),
       ayahId = Value(ayahId);
  static Insertable<LastReadData> custom({
    Expression<int>? id,
    Expression<int>? surahId,
    Expression<int>? ayahId,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (surahId != null) 'surah_id': surahId,
      if (ayahId != null) 'ayah_id': ayahId,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  LastReadCompanion copyWith({
    Value<int>? id,
    Value<int>? surahId,
    Value<int>? ayahId,
    Value<DateTime>? updatedAt,
  }) {
    return LastReadCompanion(
      id: id ?? this.id,
      surahId: surahId ?? this.surahId,
      ayahId: ayahId ?? this.ayahId,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (surahId.present) {
      map['surah_id'] = Variable<int>(surahId.value);
    }
    if (ayahId.present) {
      map['ayah_id'] = Variable<int>(ayahId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LastReadCompanion(')
          ..write('id: $id, ')
          ..write('surahId: $surahId, ')
          ..write('ayahId: $ayahId, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$DeenDatabase extends GeneratedDatabase {
  _$DeenDatabase(QueryExecutor e) : super(e);
  $DeenDatabaseManager get managers => $DeenDatabaseManager(this);
  late final $UserGoalsTable userGoals = $UserGoalsTable(this);
  late final $DailyReadsTable dailyReads = $DailyReadsTable(this);
  late final $StreaksTable streaks = $StreaksTable(this);
  late final $SettingsCacheTable settingsCache = $SettingsCacheTable(this);
  late final $BookmarksTable bookmarks = $BookmarksTable(this);
  late final $LastReadTable lastRead = $LastReadTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    userGoals,
    dailyReads,
    streaks,
    settingsCache,
    bookmarks,
    lastRead,
  ];
}

typedef $$UserGoalsTableCreateCompanionBuilder = UserGoalsCompanion Function({
  Value<int> id,
  Value<int> dailyTargetMinutes,
  Value<int> dailyTargetAyahs,
  Value<bool> isActive,
});
typedef $$UserGoalsTableUpdateCompanionBuilder = UserGoalsCompanion Function({
  Value<int> id,
  Value<int> dailyTargetMinutes,
  Value<int> dailyTargetAyahs,
  Value<bool> isActive,
});

class $$UserGoalsTableFilterComposer
    extends Composer<_$DeenDatabase, $UserGoalsTable> {
  $$UserGoalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dailyTargetMinutes => $composableBuilder(
    column: $table.dailyTargetMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dailyTargetAyahs => $composableBuilder(
    column: $table.dailyTargetAyahs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserGoalsTableOrderingComposer
    extends Composer<_$DeenDatabase, $UserGoalsTable> {
  $$UserGoalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dailyTargetMinutes => $composableBuilder(
    column: $table.dailyTargetMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dailyTargetAyahs => $composableBuilder(
    column: $table.dailyTargetAyahs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserGoalsTableAnnotationComposer
    extends Composer<_$DeenDatabase, $UserGoalsTable> {
  $$UserGoalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get dailyTargetMinutes => $composableBuilder(
    column: $table.dailyTargetMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dailyTargetAyahs => $composableBuilder(
    column: $table.dailyTargetAyahs,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$UserGoalsTableTableManager
    extends
        RootTableManager<
          _$DeenDatabase,
          $UserGoalsTable,
          UserGoal,
          $$UserGoalsTableFilterComposer,
          $$UserGoalsTableOrderingComposer,
          $$UserGoalsTableAnnotationComposer,
          $$UserGoalsTableCreateCompanionBuilder,
          $$UserGoalsTableUpdateCompanionBuilder,
          (UserGoal, BaseReferences<_$DeenDatabase, $UserGoalsTable, UserGoal>),
          UserGoal,
          PrefetchHooks Function()
        > {
  $$UserGoalsTableTableManager(_$DeenDatabase db, $UserGoalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserGoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserGoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserGoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> dailyTargetMinutes = const Value.absent(),
                Value<int> dailyTargetAyahs = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
              }) => UserGoalsCompanion(
                id: id,
                dailyTargetMinutes: dailyTargetMinutes,
                dailyTargetAyahs: dailyTargetAyahs,
                isActive: isActive,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> dailyTargetMinutes = const Value.absent(),
                Value<int> dailyTargetAyahs = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
              }) => UserGoalsCompanion.insert(
                id: id,
                dailyTargetMinutes: dailyTargetMinutes,
                dailyTargetAyahs: dailyTargetAyahs,
                isActive: isActive,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserGoalsTableProcessedTableManager =
    ProcessedTableManager<
      _$DeenDatabase,
      $UserGoalsTable,
      UserGoal,
      $$UserGoalsTableFilterComposer,
      $$UserGoalsTableOrderingComposer,
      $$UserGoalsTableAnnotationComposer,
      $$UserGoalsTableCreateCompanionBuilder,
      $$UserGoalsTableUpdateCompanionBuilder,
      (UserGoal, BaseReferences<_$DeenDatabase, $UserGoalsTable, UserGoal>),
      UserGoal,
      PrefetchHooks Function()
    >;
typedef $$DailyReadsTableCreateCompanionBuilder = DailyReadsCompanion Function({
  Value<int> id,
  required String date,
  Value<int> minutesRead,
  Value<int> ayahsRead,
  Value<int> hasanatEarned,
});
typedef $$DailyReadsTableUpdateCompanionBuilder = DailyReadsCompanion Function({
  Value<int> id,
  Value<String> date,
  Value<int> minutesRead,
  Value<int> ayahsRead,
  Value<int> hasanatEarned,
});

class $$DailyReadsTableFilterComposer
    extends Composer<_$DeenDatabase, $DailyReadsTable> {
  $$DailyReadsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minutesRead => $composableBuilder(
    column: $table.minutesRead,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ayahsRead => $composableBuilder(
    column: $table.ayahsRead,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hasanatEarned => $composableBuilder(
    column: $table.hasanatEarned,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailyReadsTableOrderingComposer
    extends Composer<_$DeenDatabase, $DailyReadsTable> {
  $$DailyReadsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minutesRead => $composableBuilder(
    column: $table.minutesRead,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ayahsRead => $composableBuilder(
    column: $table.ayahsRead,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hasanatEarned => $composableBuilder(
    column: $table.hasanatEarned,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailyReadsTableAnnotationComposer
    extends Composer<_$DeenDatabase, $DailyReadsTable> {
  $$DailyReadsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get minutesRead => $composableBuilder(
    column: $table.minutesRead,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ayahsRead =>
      $composableBuilder(column: $table.ayahsRead, builder: (column) => column);

  GeneratedColumn<int> get hasanatEarned => $composableBuilder(
    column: $table.hasanatEarned,
    builder: (column) => column,
  );
}

class $$DailyReadsTableTableManager
    extends
        RootTableManager<
          _$DeenDatabase,
          $DailyReadsTable,
          DailyRead,
          $$DailyReadsTableFilterComposer,
          $$DailyReadsTableOrderingComposer,
          $$DailyReadsTableAnnotationComposer,
          $$DailyReadsTableCreateCompanionBuilder,
          $$DailyReadsTableUpdateCompanionBuilder,
          (
            DailyRead,
            BaseReferences<_$DeenDatabase, $DailyReadsTable, DailyRead>,
          ),
          DailyRead,
          PrefetchHooks Function()
        > {
  $$DailyReadsTableTableManager(_$DeenDatabase db, $DailyReadsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyReadsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyReadsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyReadsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<int> minutesRead = const Value.absent(),
                Value<int> ayahsRead = const Value.absent(),
                Value<int> hasanatEarned = const Value.absent(),
              }) => DailyReadsCompanion(
                id: id,
                date: date,
                minutesRead: minutesRead,
                ayahsRead: ayahsRead,
                hasanatEarned: hasanatEarned,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String date,
                Value<int> minutesRead = const Value.absent(),
                Value<int> ayahsRead = const Value.absent(),
                Value<int> hasanatEarned = const Value.absent(),
              }) => DailyReadsCompanion.insert(
                id: id,
                date: date,
                minutesRead: minutesRead,
                ayahsRead: ayahsRead,
                hasanatEarned: hasanatEarned,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailyReadsTableProcessedTableManager =
    ProcessedTableManager<
      _$DeenDatabase,
      $DailyReadsTable,
      DailyRead,
      $$DailyReadsTableFilterComposer,
      $$DailyReadsTableOrderingComposer,
      $$DailyReadsTableAnnotationComposer,
      $$DailyReadsTableCreateCompanionBuilder,
      $$DailyReadsTableUpdateCompanionBuilder,
      (DailyRead, BaseReferences<_$DeenDatabase, $DailyReadsTable, DailyRead>),
      DailyRead,
      PrefetchHooks Function()
    >;
typedef $$StreaksTableCreateCompanionBuilder = StreaksCompanion Function({
  Value<int> id,
  Value<int> currentStreak,
  Value<int> longestStreak,
  Value<int> availableFreezes,
  Value<String?> lastReadDate,
});
typedef $$StreaksTableUpdateCompanionBuilder = StreaksCompanion Function({
  Value<int> id,
  Value<int> currentStreak,
  Value<int> longestStreak,
  Value<int> availableFreezes,
  Value<String?> lastReadDate,
});

class $$StreaksTableFilterComposer
    extends Composer<_$DeenDatabase, $StreaksTable> {
  $$StreaksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentStreak => $composableBuilder(
    column: $table.currentStreak,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get longestStreak => $composableBuilder(
    column: $table.longestStreak,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get availableFreezes => $composableBuilder(
    column: $table.availableFreezes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastReadDate => $composableBuilder(
    column: $table.lastReadDate,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StreaksTableOrderingComposer
    extends Composer<_$DeenDatabase, $StreaksTable> {
  $$StreaksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentStreak => $composableBuilder(
    column: $table.currentStreak,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get longestStreak => $composableBuilder(
    column: $table.longestStreak,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get availableFreezes => $composableBuilder(
    column: $table.availableFreezes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastReadDate => $composableBuilder(
    column: $table.lastReadDate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StreaksTableAnnotationComposer
    extends Composer<_$DeenDatabase, $StreaksTable> {
  $$StreaksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get currentStreak => $composableBuilder(
    column: $table.currentStreak,
    builder: (column) => column,
  );

  GeneratedColumn<int> get longestStreak => $composableBuilder(
    column: $table.longestStreak,
    builder: (column) => column,
  );

  GeneratedColumn<int> get availableFreezes => $composableBuilder(
    column: $table.availableFreezes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastReadDate => $composableBuilder(
    column: $table.lastReadDate,
    builder: (column) => column,
  );
}

class $$StreaksTableTableManager
    extends
        RootTableManager<
          _$DeenDatabase,
          $StreaksTable,
          Streak,
          $$StreaksTableFilterComposer,
          $$StreaksTableOrderingComposer,
          $$StreaksTableAnnotationComposer,
          $$StreaksTableCreateCompanionBuilder,
          $$StreaksTableUpdateCompanionBuilder,
          (Streak, BaseReferences<_$DeenDatabase, $StreaksTable, Streak>),
          Streak,
          PrefetchHooks Function()
        > {
  $$StreaksTableTableManager(_$DeenDatabase db, $StreaksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StreaksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StreaksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StreaksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> currentStreak = const Value.absent(),
                Value<int> longestStreak = const Value.absent(),
                Value<int> availableFreezes = const Value.absent(),
                Value<String?> lastReadDate = const Value.absent(),
              }) => StreaksCompanion(
                id: id,
                currentStreak: currentStreak,
                longestStreak: longestStreak,
                availableFreezes: availableFreezes,
                lastReadDate: lastReadDate,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> currentStreak = const Value.absent(),
                Value<int> longestStreak = const Value.absent(),
                Value<int> availableFreezes = const Value.absent(),
                Value<String?> lastReadDate = const Value.absent(),
              }) => StreaksCompanion.insert(
                id: id,
                currentStreak: currentStreak,
                longestStreak: longestStreak,
                availableFreezes: availableFreezes,
                lastReadDate: lastReadDate,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StreaksTableProcessedTableManager =
    ProcessedTableManager<
      _$DeenDatabase,
      $StreaksTable,
      Streak,
      $$StreaksTableFilterComposer,
      $$StreaksTableOrderingComposer,
      $$StreaksTableAnnotationComposer,
      $$StreaksTableCreateCompanionBuilder,
      $$StreaksTableUpdateCompanionBuilder,
      (Streak, BaseReferences<_$DeenDatabase, $StreaksTable, Streak>),
      Streak,
      PrefetchHooks Function()
    >;
typedef $$SettingsCacheTableCreateCompanionBuilder =
    SettingsCacheCompanion Function({
      required String key,
      Value<String?> value,
      Value<int> rowid,
    });
typedef $$SettingsCacheTableUpdateCompanionBuilder =
    SettingsCacheCompanion Function({
      Value<String> key,
      Value<String?> value,
      Value<int> rowid,
    });

class $$SettingsCacheTableFilterComposer
    extends Composer<_$DeenDatabase, $SettingsCacheTable> {
  $$SettingsCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsCacheTableOrderingComposer
    extends Composer<_$DeenDatabase, $SettingsCacheTable> {
  $$SettingsCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsCacheTableAnnotationComposer
    extends Composer<_$DeenDatabase, $SettingsCacheTable> {
  $$SettingsCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsCacheTableTableManager
    extends
        RootTableManager<
          _$DeenDatabase,
          $SettingsCacheTable,
          SettingsCacheData,
          $$SettingsCacheTableFilterComposer,
          $$SettingsCacheTableOrderingComposer,
          $$SettingsCacheTableAnnotationComposer,
          $$SettingsCacheTableCreateCompanionBuilder,
          $$SettingsCacheTableUpdateCompanionBuilder,
          (
            SettingsCacheData,
            BaseReferences<
              _$DeenDatabase,
              $SettingsCacheTable,
              SettingsCacheData
            >,
          ),
          SettingsCacheData,
          PrefetchHooks Function()
        > {
  $$SettingsCacheTableTableManager(_$DeenDatabase db, $SettingsCacheTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String?> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SettingsCacheCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                Value<String?> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsCacheCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$DeenDatabase,
      $SettingsCacheTable,
      SettingsCacheData,
      $$SettingsCacheTableFilterComposer,
      $$SettingsCacheTableOrderingComposer,
      $$SettingsCacheTableAnnotationComposer,
      $$SettingsCacheTableCreateCompanionBuilder,
      $$SettingsCacheTableUpdateCompanionBuilder,
      (
        SettingsCacheData,
        BaseReferences<_$DeenDatabase, $SettingsCacheTable, SettingsCacheData>,
      ),
      SettingsCacheData,
      PrefetchHooks Function()
    >;
typedef $$BookmarksTableCreateCompanionBuilder = BookmarksCompanion Function({
  Value<int> id,
  required int surahId,
  required int ayahId,
  Value<DateTime> createdAt,
});
typedef $$BookmarksTableUpdateCompanionBuilder = BookmarksCompanion Function({
  Value<int> id,
  Value<int> surahId,
  Value<int> ayahId,
  Value<DateTime> createdAt,
});

class $$BookmarksTableFilterComposer
    extends Composer<_$DeenDatabase, $BookmarksTable> {
  $$BookmarksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get surahId => $composableBuilder(
    column: $table.surahId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ayahId => $composableBuilder(
    column: $table.ayahId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BookmarksTableOrderingComposer
    extends Composer<_$DeenDatabase, $BookmarksTable> {
  $$BookmarksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get surahId => $composableBuilder(
    column: $table.surahId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ayahId => $composableBuilder(
    column: $table.ayahId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BookmarksTableAnnotationComposer
    extends Composer<_$DeenDatabase, $BookmarksTable> {
  $$BookmarksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get surahId =>
      $composableBuilder(column: $table.surahId, builder: (column) => column);

  GeneratedColumn<int> get ayahId =>
      $composableBuilder(column: $table.ayahId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$BookmarksTableTableManager
    extends
        RootTableManager<
          _$DeenDatabase,
          $BookmarksTable,
          Bookmark,
          $$BookmarksTableFilterComposer,
          $$BookmarksTableOrderingComposer,
          $$BookmarksTableAnnotationComposer,
          $$BookmarksTableCreateCompanionBuilder,
          $$BookmarksTableUpdateCompanionBuilder,
          (Bookmark, BaseReferences<_$DeenDatabase, $BookmarksTable, Bookmark>),
          Bookmark,
          PrefetchHooks Function()
        > {
  $$BookmarksTableTableManager(_$DeenDatabase db, $BookmarksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookmarksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookmarksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookmarksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> surahId = const Value.absent(),
                Value<int> ayahId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => BookmarksCompanion(
                id: id,
                surahId: surahId,
                ayahId: ayahId,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int surahId,
                required int ayahId,
                Value<DateTime> createdAt = const Value.absent(),
              }) => BookmarksCompanion.insert(
                id: id,
                surahId: surahId,
                ayahId: ayahId,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BookmarksTableProcessedTableManager =
    ProcessedTableManager<
      _$DeenDatabase,
      $BookmarksTable,
      Bookmark,
      $$BookmarksTableFilterComposer,
      $$BookmarksTableOrderingComposer,
      $$BookmarksTableAnnotationComposer,
      $$BookmarksTableCreateCompanionBuilder,
      $$BookmarksTableUpdateCompanionBuilder,
      (Bookmark, BaseReferences<_$DeenDatabase, $BookmarksTable, Bookmark>),
      Bookmark,
      PrefetchHooks Function()
    >;
typedef $$LastReadTableCreateCompanionBuilder = LastReadCompanion Function({
  Value<int> id,
  required int surahId,
  required int ayahId,
  Value<DateTime> updatedAt,
});
typedef $$LastReadTableUpdateCompanionBuilder = LastReadCompanion Function({
  Value<int> id,
  Value<int> surahId,
  Value<int> ayahId,
  Value<DateTime> updatedAt,
});

class $$LastReadTableFilterComposer
    extends Composer<_$DeenDatabase, $LastReadTable> {
  $$LastReadTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get surahId => $composableBuilder(
    column: $table.surahId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ayahId => $composableBuilder(
    column: $table.ayahId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LastReadTableOrderingComposer
    extends Composer<_$DeenDatabase, $LastReadTable> {
  $$LastReadTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get surahId => $composableBuilder(
    column: $table.surahId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ayahId => $composableBuilder(
    column: $table.ayahId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LastReadTableAnnotationComposer
    extends Composer<_$DeenDatabase, $LastReadTable> {
  $$LastReadTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get surahId =>
      $composableBuilder(column: $table.surahId, builder: (column) => column);

  GeneratedColumn<int> get ayahId =>
      $composableBuilder(column: $table.ayahId, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LastReadTableTableManager
    extends
        RootTableManager<
          _$DeenDatabase,
          $LastReadTable,
          LastReadData,
          $$LastReadTableFilterComposer,
          $$LastReadTableOrderingComposer,
          $$LastReadTableAnnotationComposer,
          $$LastReadTableCreateCompanionBuilder,
          $$LastReadTableUpdateCompanionBuilder,
          (
            LastReadData,
            BaseReferences<_$DeenDatabase, $LastReadTable, LastReadData>,
          ),
          LastReadData,
          PrefetchHooks Function()
        > {
  $$LastReadTableTableManager(_$DeenDatabase db, $LastReadTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LastReadTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LastReadTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LastReadTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> surahId = const Value.absent(),
                Value<int> ayahId = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => LastReadCompanion(
                id: id,
                surahId: surahId,
                ayahId: ayahId,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int surahId,
                required int ayahId,
                Value<DateTime> updatedAt = const Value.absent(),
              }) => LastReadCompanion.insert(
                id: id,
                surahId: surahId,
                ayahId: ayahId,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LastReadTableProcessedTableManager =
    ProcessedTableManager<
      _$DeenDatabase,
      $LastReadTable,
      LastReadData,
      $$LastReadTableFilterComposer,
      $$LastReadTableOrderingComposer,
      $$LastReadTableAnnotationComposer,
      $$LastReadTableCreateCompanionBuilder,
      $$LastReadTableUpdateCompanionBuilder,
      (
        LastReadData,
        BaseReferences<_$DeenDatabase, $LastReadTable, LastReadData>,
      ),
      LastReadData,
      PrefetchHooks Function()
    >;

class $DeenDatabaseManager {
  final _$DeenDatabase _db;
  $DeenDatabaseManager(this._db);
  $$UserGoalsTableTableManager get userGoals =>
      $$UserGoalsTableTableManager(_db, _db.userGoals);
  $$DailyReadsTableTableManager get dailyReads =>
      $$DailyReadsTableTableManager(_db, _db.dailyReads);
  $$StreaksTableTableManager get streaks =>
      $$StreaksTableTableManager(_db, _db.streaks);
  $$SettingsCacheTableTableManager get settingsCache =>
      $$SettingsCacheTableTableManager(_db, _db.settingsCache);
  $$BookmarksTableTableManager get bookmarks =>
      $$BookmarksTableTableManager(_db, _db.bookmarks);
  $$LastReadTableTableManager get lastRead =>
      $$LastReadTableTableManager(_db, _db.lastRead);
}
