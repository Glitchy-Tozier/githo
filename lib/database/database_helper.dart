/* 
 * Githo – An app that helps you gradually form long-lasting habits.
 * Copyright (C) 2021 Florian Thaler
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:githo/config/data_shortcut.dart';
import 'package:githo/database/default_habit_plans.dart';

import 'package:githo/models/habit_plan.dart';
import 'package:githo/models/notification_data.dart';
import 'package:githo/models/progress_data.dart';
import 'package:githo/models/settings_data.dart';

/// Used for interacting with the database.

class DatabaseHelper {
  const DatabaseHelper._privateConstructor();

  /// The singleton-instance of DatabaseHelper.
  static const DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _db;
  static const int version = 4;

  static const String _habitPlansTable = 'habitPlansTable';
  static const String _colId = 'id';
  static const String _colHabitIsActive = 'isActive';
  static const String _colHabitFullyCompleted = 'fullyCompleted';
  static const String _colHabit = 'habit';
  static const String _colRequiredReps = 'requiredReps';
  static const String _colLevels = 'levels';
  static const String _colComments = 'comments';
  static const String _colTrainingTimeIndex = 'trainingTimeIndex';
  static const String _colRequiredTrainings = 'requiredTrainings';
  static const String _colRequiredTrainingPeriods = 'requiredTrainingPeriods';
  static const String _colLastChanged = 'lastChanged';

  static const String _notificationDataTable = 'notificationDataTable';
  static const String _colNotificationsIsActive = 'isActive';
  static const String _colNextActivationDate = 'nextActivationDate';
  static const String _colHoursBetweenNotifications =
      'hoursBetweenNotifications';

  static const String _progressDataTable = 'progressDataTable';
  static const String _colHabitPlanId = 'habitPlanId';
  static const String _colProgIsActive = 'isActive';
  static const String _colProgFullyCompleted = 'fullyCompleted';
  static const String _colCurrentStartingDate = 'currentStartingDate';
  static const String _colProgHabit = 'habit';
  static const String _colProgLevels = 'levels';

  static const String _settingsTable = 'settingsTable';
  static const String _colShowIntroduction = 'showIntroduction';
  static const String _colAdaptThemeToSystem = 'adaptThemeToSystem';
  static const String _colLightTheme = 'lightTheme';
  static const String _colDarkTheme = 'darkTheme';

  /// Returns the [Database].
  ///
  /// Use this function instead of directly touching [_db].
  Future<Database> get _getDb async {
    _db ??= await _initDb();
    return _db!;
  }

  /// Load or newly create the [Database].
  Future<Database> _initDb() async {
    final Directory dir = await getApplicationDocumentsDirectory();
    final String path = '${dir.path}/githoDatabase.db';

    Database? db;
    try {
      db = await openDatabase(
        path,
        version: version,
        onCreate: _createDb,
        onUpgrade: _upgradeDb,
      );
    } catch (error) {
      print(error);
    }

    return db!;
  }

  /// Create the database from scratch.
  Future<void> _createDb(final Database db, final int version) async {
    String commandString;

    // Initialize habitPlan-table
    commandString = '''
CREATE TABLE $_habitPlansTable(
  $_colId INTEGER PRIMARY KEY AUTOINCREMENT,
  $_colHabitIsActive INTEGER,
  $_colHabitFullyCompleted INTEGER,
  $_colHabit TEXT,
  $_colRequiredReps INTEGER,
  $_colLevels TEXT,
  $_colComments TEXT,
  $_colTrainingTimeIndex INTEGER,
  $_colRequiredTrainings INTEGER,
  $_colRequiredTrainingPeriods INTEGER,
$_colLastChanged TEXT
)''';
    await db.execute(commandString);

    final List<HabitPlan> defaultHabitPlans = DefaultHabitPlans.habitPlanList;
    for (final HabitPlan habitPlan in defaultHabitPlans) {
      // Initialize default values
      db.insert(
        _habitPlansTable,
        habitPlan.toMap(),
      );
    }
    if (DataShortcut.testing == true) {
      final List<HabitPlan> testingHabitPlans =
          DefaultHabitPlans.testingHabitPlanList;
      for (final HabitPlan habitPlan in testingHabitPlans) {
        // Initialize default values
        db.insert(
          _habitPlansTable,
          habitPlan.toMap(),
        );
      }
    }

    // Initialize progress-table
    commandString = '''
CREATE TABLE $_progressDataTable(
  $_colHabitPlanId INTEGER,
  $_colProgIsActive INTEGER,
  $_colProgFullyCompleted INTEGER,
  $_colCurrentStartingDate TEXT,
  $_colProgHabit TEXT,
  $_colProgLevels TEXT
)''';
    await db.execute(commandString);

    db.insert(
      // Initialize default values
      _progressDataTable,
      ProgressData.emptyData().toMap(),
    );

    // Initialize settings-table
    commandString = '''
CREATE TABLE $_settingsTable(
  $_colShowIntroduction INTEGER,
  $_colAdaptThemeToSystem INTEGER,
  $_colLightTheme TEXT,
  $_colDarkTheme TEXT
)''';
    await db.execute(commandString);

    db.insert(
      // Initialize default values
      _settingsTable,
      SettingsData.initialValues().toMap(),
    );

    // Initialize notifications-table
    commandString = '''
CREATE TABLE $_notificationDataTable(
  $_colNotificationsIsActive INTEGER,
  $_colNextActivationDate TEXT,
  $_colHoursBetweenNotifications INTEGER
)''';
    await db.execute(commandString);

    db.insert(
      // Initialize default values
      _notificationDataTable,
      NotificationData.initialValues().toMap(),
    );
  }

  /// Adapts the [Database] to make it work in the new version of the app.
  void _upgradeDb(Database db, final int oldVersion, final int newVersion) {
    int currentVersion = oldVersion;
    if (currentVersion == 1) {
      // Rename all "goal"-columns to "habit
      // and all "steps" to "levels".
      // The new, pretty SQLite commands can't be used because Android-versions
      // <=10 don't support them.

      db.execute('''
CREATE TABLE newHabitPlansTable(
  $_colId INTEGER PRIMARY KEY AUTOINCREMENT,
  $_colHabitIsActive INTEGER,
  $_colHabitFullyCompleted INTEGER,
  $_colHabit TEXT,
  $_colRequiredReps INTEGER,
  $_colLevels TEXT,
  $_colComments TEXT,
  $_colTrainingTimeIndex INTEGER,
  $_colRequiredTrainings INTEGER,
  $_colRequiredTrainingPeriods INTEGER,
  $_colLastChanged TEXT
);
''');
      db.execute('''
INSERT INTO newHabitPlansTable(
  $_colId,
  $_colHabitIsActive,
  $_colHabitFullyCompleted,
  $_colHabit,
  $_colRequiredReps,
  $_colLevels,
  $_colComments,
  $_colTrainingTimeIndex,
  $_colRequiredTrainings,
  $_colRequiredTrainingPeriods,
  $_colLastChanged
) SELECT 
  id,
  isActive,
  fullyCompleted,
  goal,
  requiredReps,
  steps,
  comments,
  trainingTimeIndex,
  requiredTrainings,
  requiredTrainingPeriods,
  lastChanged
FROM $_habitPlansTable;
''');
      db.execute('''
DROP TABLE $_habitPlansTable;
''');
      db.execute('''
ALTER TABLE newHabitPlansTable RENAME TO $_habitPlansTable;
''');

      // Do the same thing for the ProgressDataTable.
      db.execute('''
CREATE TABLE newProgressDataTable(
  $_colHabitPlanId INTEGER,
  $_colProgIsActive INTEGER,
  $_colProgFullyCompleted INTEGER,
  $_colCurrentStartingDate TEXT,
  $_colProgHabit TEXT,
  $_colProgLevels TEXT
);
''');
      db.execute('''
INSERT INTO newProgressDataTable(
  $_colHabitPlanId,
  $_colProgIsActive,
  $_colProgFullyCompleted,
  $_colCurrentStartingDate,
  $_colProgHabit,
  $_colProgLevels
) SELECT 
  habitPlanId,
  isActive,
  fullyCompleted,
  currentStartingDate,
  goal,
  steps
FROM $_progressDataTable;
''');
      db.execute('''
DROP TABLE $_progressDataTable;
''');
      db.execute('''
ALTER TABLE newProgressDataTable RENAME TO $_progressDataTable;
''');

      // Delete unused Table.
      db.execute('DROP TABLE dbVersionTable');

      // Update the version-number.
      currentVersion = 2;
    }

    if (currentVersion == 2) {
      // Add the dark-theme-column to the settings-table.
      db.execute('''
ALTER TABLE $_settingsTable ADD $_colAdaptThemeToSystem INTEGER;
''');
      // Add the light-theme-column to the settings-table.
      db.execute('''
ALTER TABLE $_settingsTable ADD $_colLightTheme TEXT;
''');
      // Add the dark-theme-column to the settings-table.
      db.execute('''
ALTER TABLE $_settingsTable ADD $_colDarkTheme TEXT;
''');

      // Fill the columns with their default values.
      final Map<String, dynamic> initialSettings =
          SettingsData.initialValues().toMap();
      db.update(_settingsTable, <String, dynamic>{
        _colAdaptThemeToSystem: initialSettings[_colAdaptThemeToSystem] as int,
        _colLightTheme: initialSettings[_colLightTheme] as String,
        _colDarkTheme: initialSettings[_colDarkTheme] as String,
      });

      // Update the version-number.
      currentVersion = 3;
    }

    if (currentVersion == 3) {
      // Create the notifications-table
      db.execute('''
CREATE TABLE $_notificationDataTable(
  $_colNotificationsIsActive INTEGER,
  $_colNextActivationDate TEXT,
  $_colHoursBetweenNotifications INTEGER
)''');

      db.insert(
        // Initialize default values
        _notificationDataTable,
        NotificationData.initialValues().toMap(),
      );

      // Update the version-number.
      currentVersion = 4;
    }
  }

  /// Returns the items found in a table.
  ///
  /// It will always return a list.
  Future<List<Map<String, dynamic>>> getDataMapList(
    final String tableName,
  ) async {
    final Database db = await _getDb;

    final List<Map<String, dynamic>> result = await db.query(tableName);
    return result;
  }

  /// Extracts all [HabitPlan]s from the database.
  Future<List<HabitPlan>> getHabitPlanList() async {
    final List<Map<String, dynamic>> habitPlanMapList =
        await getDataMapList(_habitPlansTable);

    final List<HabitPlan> habitPlanList = <HabitPlan>[];

    for (final Map<String, dynamic> habitPlanMap in habitPlanMapList) {
      habitPlanList.add(HabitPlan.fromMap(habitPlanMap));
    }

    return habitPlanList;
  }

  /// Retuns the [HabitPlan] that matches with the [id].
  Future<HabitPlan?> getHabitPlan(final int id) async {
    final Database db = await _getDb;

    final List<Map<String, Object?>> resultsMap;
    resultsMap = await db.query(
      _habitPlansTable,
      where: '$_colId = ?',
      whereArgs: <int>[id],
    );

    if (resultsMap.length > 1) {
      print(
        'Something went wrong in getActiveHabitPlan(). '
        'Multiple HabitPlans have the same ID.',
      );
    }

    if (resultsMap.isNotEmpty) {
      // A hacky solution to null-issues
      final HabitPlan habitPlan = HabitPlan.fromMap(resultsMap[0]);

      return habitPlan;
    }
  }

  /// Returns the HabitPlan that currently is active.
  Future<List<HabitPlan>> getActiveHabitPlan() async {
    final Database db = await _getDb;

    final List<Map<String, Object?>> resultsMap;
    resultsMap = await db.query(
      _habitPlansTable,
      where: '$_colHabitIsActive = ?',
      whereArgs: const <int>[1],
    );

    if (resultsMap.length > 1) {
      print(
        'Something went wrong in getActiveHabitPlan(). '
        'Multiple HabitPlans are active.',
      );
    }

    if (resultsMap.isEmpty) {
      return const <HabitPlan>[];
    } else {
      // A hacky solution to null-issues
      final List<HabitPlan> activeHabitPlan = <HabitPlan>[
        HabitPlan.fromMap(resultsMap[0]),
      ];
      return activeHabitPlan;
    }
  }

  /// Inserts a new [HabitPlan] into the database.
  Future<int> insertHabitPlan(final HabitPlan habitPlan) async {
    final Database db = await _getDb;
    final int result = await db.insert(_habitPlansTable, habitPlan.toMap());
    return result;
  }

  /// Updates a [HabitPlan] in the database.
  Future<int> updateHabitPlan(final HabitPlan habitPlan) async {
    final Database db = await _getDb;
    final int result = await db.update(
      _habitPlansTable,
      habitPlan.toMap(),
      where: '$_colId = ?',
      whereArgs: <int?>[habitPlan.id],
    );
    return result;
  }

  /// Deletes a [HabitPlan] from the database.
  Future<int> deleteHabitPlan(final int id) async {
    final Database db = await _getDb;
    final int result = await db.delete(
      _habitPlansTable,
      where: '$_colId = ?',
      whereArgs: <int>[id],
    );
    return result;
  }

  /// Extracts [NotificationData] from the database and returns it.
  Future<NotificationData> getNotificationData() async {
    final List<Map<String, Object?>> queryResultList =
        await getDataMapList(_notificationDataTable);
    final Map<String, Object?> queryResult = queryResultList[0];

    final NotificationData result = NotificationData.fromMap(queryResult);
    return result;
  }

  /// Updates the [notificationData] in the database.
  Future<int> updateNotificationData(
    final NotificationData notificationData,
  ) async {
    final Database db = await _getDb;
    final int result = await db.update(
      _notificationDataTable,
      notificationData.toMap(),
    );
    return result;
  }

  /// Extracts [ProgressData] from the database and returns it.
  Future<ProgressData> getProgressData() async {
    final List<Map<String, Object?>> queryResultList =
        await getDataMapList(_progressDataTable);
    final Map<String, Object?> queryResult = queryResultList[0];

    final ProgressData result = ProgressData.fromMap(queryResult);
    return result;
  }

  /// Updates the [progressData] in the database.
  Future<int> updateProgressData(final ProgressData progressData) async {
    final Database db = await _getDb;
    final int result = await db.update(
      _progressDataTable,
      progressData.toMap(),
    );
    return result;
  }

  /// Extracts [SettingsData] from the database and returns it.
  Future<SettingsData> getSettings() async {
    final List<Map<String, Object?>> queryResultList =
        await getDataMapList(_settingsTable);
    final Map<String, Object?> queryResult = queryResultList[0];

    final SettingsData result = SettingsData.fromMap(queryResult);
    return result;
  }

  /// Updates the [settings] in the database.
  Future<int> updateSettings(final SettingsData settings) async {
    final Database db = await _getDb;
    final int result = await db.update(
      _settingsTable,
      settings.toMap(),
    );
    return result;
  }
}
