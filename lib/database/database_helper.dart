/* 
 * Githo – An app that helps you form long-lasting habits, one step at a time.
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
import 'package:githo/models/progress_data.dart';
import 'package:githo/models/settings_data.dart';

/// Used for interacting with the database.

class DatabaseHelper {
  const DatabaseHelper._privateConstructor();

  /// The singleton-instance of DatabaseHelper.
  static const DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _db;

  static const String _dbVersionTable = 'dbVersionTable';
  static const String _colVersion = 'version';
  // ignore: unused_field
  static const int _version = 1;

  static const String _habitPlansTable = 'habitPlansTable';
  static const String _colId = 'id';
  static const String _colHabitIsActive = 'isActive';
  static const String _colHabitFullyCompleted = 'fullyCompleted';
  static const String _colGoal = 'goal';
  static const String _colRequiredReps = 'requiredReps';
  static const String _colSteps = 'steps';
  static const String _colComments = 'comments';
  static const String _colTrainingTimeIndex = 'trainingTimeIndex';
  static const String _colRequiredTrainings = 'requiredTrainings';
  static const String _colRequiredTrainingPeriods = 'requiredTrainingPeriods';
  static const String _colLastChanged = 'lastChanged';

  static const String _colHabitPlanId = 'habitPlanId';
  static const String _colProgIsActive = 'isActive';
  static const String _colProgFullyCompleted = 'fullyCompleted';
  static const String _progressDataTable = 'progressDataTable';
  static const String _colLastActiveDate = 'lastActiveDate';
  static const String _colCurrentStartingDate = 'currentStartingDate';
  static const String _colProgGoal = 'goal';
  static const String _colProgSteps = 'steps';

  static const String _settingsTable = 'settingsTable';
  static const String _colShowIntroduction = 'showIntroduction';
  static const String _colPaused = 'paused';

  /// Returns the database.
  ///
  /// **Never** directly touch [_db].
  Future<Database> get _getDb async {
    _db ??= await _initDb();
    return _db!;
  }

  /// Load or newly create database.
  Future<Database?> _initDb() async {
    final Directory dir = await getApplicationDocumentsDirectory();
    final String path = '${dir.path}/githoDatabase.db';

    Database? habitPlanDb;
    try {
      habitPlanDb = await openDatabase(
        path,
        version: 1,
        onCreate: _createDb,
      );
    } catch (error) {
      print(error);
    }

    return habitPlanDb;
  }

  /// Create the database from scratch.
  Future<void> _createDb(final Database db, final int version) async {
    String commandString;

    // Initalize the database-version
    commandString = '';
    commandString += 'CREATE TABLE $_dbVersionTable';
    commandString += '($_colVersion INTEGER)';
    await db.execute(commandString);
    db.insert(
      _dbVersionTable,
      <String, Object>{_colVersion: version},
    );

    // Initialize habitPlan-table
    commandString = '';
    commandString += 'CREATE TABLE $_habitPlansTable';
    commandString += '(';
    commandString += '$_colId INTEGER PRIMARY KEY AUTOINCREMENT, ';
    commandString += '$_colHabitIsActive INTEGER, ';
    commandString += '$_colHabitFullyCompleted INTEGER, ';
    commandString += '$_colGoal TEXT, ';
    commandString += '$_colRequiredReps INTEGER, ';
    commandString += '$_colSteps TEXT, ';
    commandString += '$_colComments TEXT, ';
    commandString += '$_colTrainingTimeIndex INTEGER, ';
    commandString += '$_colRequiredTrainings INTEGER, ';
    commandString += '$_colRequiredTrainingPeriods INTEGER, ';
    commandString += '$_colLastChanged TEXT';
    commandString += ')';
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
    commandString = '';
    commandString += 'CREATE TABLE $_progressDataTable';
    commandString += '(';
    commandString += '$_colHabitPlanId INTEGER, ';
    commandString += '$_colProgIsActive INTEGER, ';
    commandString += '$_colProgFullyCompleted INTEGER, ';
    commandString += '$_colLastActiveDate TEXT, ';
    commandString += '$_colCurrentStartingDate TEXT, ';
    commandString += '$_colProgGoal TEXT, ';
    commandString += '$_colProgSteps TEXT';
    commandString += ')';
    await db.execute(commandString);

    db.insert(
      // Initialize default values
      _progressDataTable,
      ProgressData.emptyData().toMap(),
    );

    // Initialize settings-table
    commandString = '';
    commandString += 'CREATE TABLE $_settingsTable';
    commandString += '(';
    commandString += '$_colShowIntroduction INTEGER, ';
    commandString += '$_colPaused INTEGER';
    commandString += ')';
    await db.execute(commandString);

    db.insert(
      // Initialize default values
      _settingsTable,
      SettingsData(
        showIntroduction: true,
        paused: false,
      ).toMap(),
    );
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
