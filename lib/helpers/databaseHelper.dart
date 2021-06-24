import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import 'package:githo/extracted_data/defaultHabitPlans.dart';

import 'package:githo/models/habitPlanModel.dart';
import 'package:githo/models/progressDataModel.dart';
import 'package:githo/models/settingsDataModel.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._instance();
  static Database? _db;

  DatabaseHelper._instance();

  static const String habitPlansTable = "habitPlansTable";
  static const String colId = "id";
  static const String colIsActive = "isActive";
  static const String colGoal = "goal";
  static const String colRequiredReps = "requiredReps";
  static const String colSteps = "steps";
  static const String colComments = "comments";
  static const String colTrainingTimeIndex = "trainingTimeIndex";
  static const String colRequiredTrainings = "requiredTrainings";
  static const String colRequiredTrainingPeriods = "requiredTrainingPeriods";
  static const String colLastChanged = "lastChanged";

  static const String colProgIsActive = "isActive";
  static const String progressDataTable = "progressDataTable";
  static const String colLastActiveDate = "lastActiveDate";
  static const String colCurrentStartingDate = "currentStartingDate";
  /* static const String colCompletedReps = "completedReps";
  static const String colCompletedTrainings = "completedTrainings";
  static const String colCompletedTrainingPeriods = "completedTrainingPeriods";
  static const String colTrainingData = "trainingData"; */
  static const String colProgGoal = "goal";
  static const String colProgSteps = "steps";

  static const String settingsDataTable = "settingsDataTable";
  static const String colPaused = "paused";

  Future get _getDb async {
    if (_db == null) {
      _db = await _initDb();
    }
    return _db;
  }

  Future<Database> _initDb() async {
    Directory dir = await getApplicationDocumentsDirectory();
    final String path = dir.path + "/HabitPlanDatabase.db";

    var habitPlanDb;
    try {
      habitPlanDb = await openDatabase(
        path,
        version: 1,
        onCreate: _createDb,
      );
    } catch (e) {
      print(e);
    }

    return habitPlanDb;
  }

  void _createDb(Database db, int version) async {
    // Initialize habitPlan-table
    String commandString = "";
    commandString += "CREATE TABLE $habitPlansTable";
    commandString += "(";
    commandString += "$colId INTEGER PRIMARY KEY AUTOINCREMENT, ";
    commandString += "$colIsActive INTEGER, ";
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
    defaultHabitPlans.forEach((habitPlan) {
      // Initialize default values
      db.insert(
        habitPlansTable,
        habitPlan.toMap(),
      );
    });

    // Initialize progress-table
    commandString = "";
    commandString += "CREATE TABLE $progressDataTable";
    commandString += "(";
    commandString += "$colProgIsActive INTEGER, ";
    commandString += "$colLastActiveDate TEXT, ";
    commandString += "$colCurrentStartingDate TEXT, ";
    /* commandString += "$colCompletedReps INTEGER, ";
    commandString += "$colCompletedTrainings INTEGER, ";
    commandString += "$colCompletedTrainingPeriods INTEGER, "; */
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
    commandString += "CREATE TABLE $settingsDataTable";
    commandString += "(";
    commandString += "$colPaused INTEGER";
    commandString += ")";
    await db.execute(commandString);

    db.insert(
        // Initialize default values
        settingsDataTable,
        SettingsData(
          paused: false,
        ).toMap());
  }

  Future<List<Map<String, dynamic>>> getDataMapList(String tableName) async {
    Database db = await this._getDb;

    final List<Map<String, dynamic>> result = await db.query(tableName);
    return result;
  }

  Future<List<HabitPlan>> getHabitPlanList() async {
    final List<Map<String, dynamic>> habitPlanMapList =
        await getDataMapList(habitPlansTable);

    final List<HabitPlan> habitPlanList = [];

    habitPlanMapList.forEach((habitPlanMap) {
      habitPlanList.add(HabitPlan.fromMap(habitPlanMap));
    });
    return habitPlanList;
  }

  Future<List<HabitPlan>> getActiveHabitPlan() async {
    Database db = await this._getDb;

    final List<Map<String, Object?>> resultsMap;
    resultsMap = await db.query(
      habitPlansTable,
      where: "$colIsActive = ?",
      whereArgs: [1],
    );

    if (resultsMap.length > 1) {
      print(
          "Something went wrong in getActiveHabitPlan(). Multiple Steps are active.");
    }

    if (resultsMap.length == 0) {
      return <HabitPlan>[];
    } else {
      List<HabitPlan> activeHabitPlan = [HabitPlan.fromMap(resultsMap[0])];
      return activeHabitPlan;
    }
  }

  Future<int> insertHabitPlan(HabitPlan habitPlan) async {
    Database db = await this._getDb;
    final int result = await db.insert(habitPlansTable, habitPlan.toMap());
    return result;
  }

  Future<int> updateHabitPlan(HabitPlan habitPlan) async {
    Database db = await this._getDb;
    final int result = await db.update(
      habitPlansTable,
      habitPlan.toMap(),
      where: "$colId = ?",
      whereArgs: [habitPlan.id],
    );
    return result;
  }

  Future<int> deleteHabitPlan(int id) async {
    Database db = await this._getDb;
    final int result = await db.delete(
      habitPlansTable,
      where: "$colId = ?",
      whereArgs: [id],
    );
    return result;
  }

  Future<ProgressData> getProgressData() async {
    List<Map<String, Object?>> queryResultList =
        await getDataMapList(progressDataTable);
    Map<String, Object?> queryResult = queryResultList[0];

    ProgressData result = ProgressData.fromMap(queryResult);
    return result;
  }

  Future<int> updateProgressData(ProgressData progressData) async {
    Database db = await this._getDb;
    final int result = await db.update(
      progressDataTable,
      progressData.toMap(),
    );
    return result;
  }

  Future<SettingsData> getSettingsData() async {
    List<Map<String, Object?>> queryResultList =
        await getDataMapList(settingsDataTable);
    Map<String, Object?> queryResult = queryResultList[0];

    SettingsData result = SettingsData.fromMap(queryResult);
    return result;
  }

  Future<int> updateSettingsData(SettingsData settingsData) async {
    Database db = await this._getDb;
    final int result = await db.update(
      progressDataTable,
      settingsData.toMap(),
    );
    return result;
  }
}
