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

import 'package:githo/extracted_data/dataShortcut.dart';
import 'package:githo/extracted_data/defaultHabitPlans.dart';

import 'package:githo/models/habitPlanModel.dart';
import 'package:githo/models/progressDataModel.dart';
import 'package:githo/models/settingsModel.dart';

class DatabaseHelper {
  // Used for interacting with the database.

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _db;

  const DatabaseHelper._privateConstructor();

  static const String dbVersionTable = "dbVersionTable";
  static const String colVersion = "version";
  static const int version = 1;

  static const String habitPlansTable = "habitPlansTable";
  static const String colId = "id";
  static const String colHabitIsActive = "isActive";
  static const String colHabitFullyCompleted = "fullyCompleted";
  static const String colGoal = "goal";
  static const String colRequiredReps = "requiredReps";
  static const String colSteps = "steps";
  static const String colComments = "comments";
  static const String colTrainingTimeIndex = "trainingTimeIndex";
  static const String colRequiredTrainings = "requiredTrainings";
  static const String colRequiredTrainingPeriods = "requiredTrainingPeriods";
  static const String colLastChanged = "lastChanged";

  static const String colHabitPlanId = "habitPlanId";
  static const String colProgIsActive = "isActive";
  static const String colProgFullyCompleted = "fullyCompleted";
  static const String progressDataTable = "progressDataTable";
  static const String colLastActiveDate = "lastActiveDate";
  static const String colCurrentStartingDate = "currentStartingDate";
  static const String colProgGoal = "goal";
  static const String colProgSteps = "steps";

  static const String settingsTable = "settingsTable";
  static const String colShowIntroduction = "showIntroduction";
  static const String colPaused = "paused";

  Future<Database> get _getDb async {
    if (_db == null) {
      _db = await _initDb();
    }
    return _db!;
  }

  Future<Database> _initDb() async {
    final Directory dir = await getApplicationDocumentsDirectory();
    final String path = dir.path + "/githoDatabase.db";

    var habitPlanDb;
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

  void _createDb(final Database db, final int version) async {
    String commandString;

    // Initalize the database-version
    commandString = "";
    commandString += "CREATE TABLE $dbVersionTable";
    commandString += "($colVersion INTEGER)";
    await db.execute(commandString);
    db.insert(
      dbVersionTable,
      {"$colVersion": version},
    );

    // Initialize habitPlan-table
    commandString = "";
    commandString += "CREATE TABLE $habitPlansTable";
    commandString += "(";
    commandString += "$colId INTEGER PRIMARY KEY AUTOINCREMENT, ";
    commandString += "$colHabitIsActive INTEGER, ";
    commandString += "$colHabitFullyCompleted INTEGER, ";
    commandString += "$colGoal TEXT, ";
    commandString += "$colRequiredReps INTEGER, ";
    commandString += "$colSteps TEXT, ";
    commandString += "$colComments TEXT, ";
    commandString += "$colTrainingTimeIndex INTEGER, ";
    commandString += "$colRequiredTrainings INTEGER, ";
    commandString += "$colRequiredTrainingPeriods INTEGER, ";
    commandString += "$colLastChanged TEXT";
    commandString += ")";
    await db.execute(commandString);

    final List<HabitPlan> defaultHabitPlans = DefaultHabitPlans.habitPlanList;
    for (final HabitPlan habitPlan in defaultHabitPlans) {
      // Initialize default values
      db.insert(
        habitPlansTable,
        habitPlan.toMap(),
      );
    }
    if (DataShortcut.testing == true) {
      final List<HabitPlan> testingHabitPlans =
          DefaultHabitPlans.testingHabitPlanList;
      for (final HabitPlan habitPlan in testingHabitPlans) {
        // Initialize default values
        db.insert(
          habitPlansTable,
          habitPlan.toMap(),
        );
      }
    }

    // Initialize progress-table
    commandString = "";
    commandString += "CREATE TABLE $progressDataTable";
    commandString += "(";
    commandString += "$colHabitPlanId INTEGER, ";
    commandString += "$colProgIsActive INTEGER, ";
    commandString += "$colProgFullyCompleted INTEGER, ";
    commandString += "$colLastActiveDate TEXT, ";
    commandString += "$colCurrentStartingDate TEXT, ";
    commandString += "$colProgGoal TEXT, ";
    commandString += "$colProgSteps TEXT";
    commandString += ")";
    await db.execute(commandString);

    db.insert(
      // Initialize default values
      progressDataTable,
      ProgressData.emptyData().toMap(),
    );

    // Initialize settings-table
    commandString = "";
    commandString += "CREATE TABLE $settingsTable";
    commandString += "(";
    commandString += "$colShowIntroduction INTEGER, ";
    commandString += "$colPaused INTEGER";
    commandString += ")";
    await db.execute(commandString);

    db.insert(
      // Initialize default values
      settingsTable,
      SettingsData(
        showIntroduction: true,
        paused: false,
      ).toMap(),
    );
  }

  Future<List<Map<String, dynamic>>> getDataMapList(
      final String tableName) async {
    final Database db = await this._getDb;

    final List<Map<String, dynamic>> result = await db.query(tableName);
    return result;
  }

  Future<List<HabitPlan>> getHabitPlanList() async {
    final List<Map<String, dynamic>> habitPlanMapList =
        await getDataMapList(habitPlansTable);

    final List<HabitPlan> habitPlanList = [];

    for (final Map<String, dynamic> habitPlanMap in habitPlanMapList) {
      habitPlanList.add(HabitPlan.fromMap(habitPlanMap));
    }

    return habitPlanList;
  }

  Future<HabitPlan?> getHabitPlan(final int id) async {
    final Database db = await this._getDb;

    final List<Map<String, Object?>> resultsMap;
    resultsMap = await db.query(
      habitPlansTable,
      where: "$colId = ?",
      whereArgs: [id],
    );

    if (resultsMap.length > 1) {
      print(
          "Something went wrong in getActiveHabitPlan(). Multiple Steps are active.");
    }

    if (resultsMap.length != 0) {
      // A hacky solution to null-issues
      final HabitPlan habitPlan = HabitPlan.fromMap(resultsMap[0]);

      return habitPlan;
    }
  }

  Future<List<HabitPlan>> getActiveHabitPlan() async {
    final Database db = await this._getDb;

    final List<Map<String, Object?>> resultsMap;
    resultsMap = await db.query(
      habitPlansTable,
      where: "$colHabitIsActive = ?",
      whereArgs: [1],
    );

    if (resultsMap.length > 1) {
      print(
          "Something went wrong in getActiveHabitPlan(). Multiple Steps are active.");
    }

    if (resultsMap.length == 0) {
      return const <HabitPlan>[];
    } else {
      // A hacky solution to null-issues
      final List<HabitPlan> activeHabitPlan = [
        HabitPlan.fromMap(resultsMap[0]),
      ];
      return activeHabitPlan;
    }
  }

  Future<int> insertHabitPlan(final HabitPlan habitPlan) async {
    final Database db = await this._getDb;
    final int result = await db.insert(habitPlansTable, habitPlan.toMap());
    return result;
  }

  Future<int> updateHabitPlan(final HabitPlan habitPlan) async {
    final Database db = await this._getDb;
    final int result = await db.update(
      habitPlansTable,
      habitPlan.toMap(),
      where: "$colId = ?",
      whereArgs: [habitPlan.id],
    );
    return result;
  }

  Future<int> deleteHabitPlan(final int id) async {
    final Database db = await this._getDb;
    final int result = await db.delete(
      habitPlansTable,
      where: "$colId = ?",
      whereArgs: [id],
    );
    return result;
  }

  Future<ProgressData> getProgressData() async {
    final List<Map<String, Object?>> queryResultList =
        await getDataMapList(progressDataTable);
    final Map<String, Object?> queryResult = queryResultList[0];

    final ProgressData result = ProgressData.fromMap(queryResult);
    return result;
  }

  Future<int> updateProgressData(final ProgressData progressData) async {
    final Database db = await this._getDb;
    final int result = await db.update(
      progressDataTable,
      progressData.toMap(),
    );
    return result;
  }

  Future<SettingsData> getSettings() async {
    final List<Map<String, Object?>> queryResultList =
        await getDataMapList(settingsTable);
    final Map<String, Object?> queryResult = queryResultList[0];

    final SettingsData result = SettingsData.fromMap(queryResult);
    return result;
  }

  Future<int> updateSettings(final SettingsData settings) async {
    final Database db = await this._getDb;
    final int result = await db.update(
      settingsTable,
      settings.toMap(),
    );
    return result;
  }
}
