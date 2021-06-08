import 'dart:io';
import 'package:githo/extracted_data/defaultHabitPlans.dart';
import 'package:sqflite/sqflite.dart';

import 'package:githo/models/habitPlan_model.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._instance();
  static Database? _db;

  DatabaseHelper._instance();

  final String habitPlansTable = "habitPlansTable";
  final String colId = "id";
  final String colIsActive = "isActive";
  final String colGoal = "goal";
  final String colReps = "reps";
  final String colChallenges = "challenges";
  final String colRules = "rules";
  final String colTimeIndex = "timeIndex";
  final String colActivity = "activity";
  final String colRequiredRepeats = "requiredRepeats";

  Future get _getDb async {
    if (_db == null) {
      _db = await _initDb();
    }
    return _db;
  }

  Future<Database> _initDb() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = dir.path + "/HabitPlanDatabase.db";

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
    String commandString = "";
    commandString += "CREATE TABLE $habitPlansTable";
    commandString += "(";
    commandString += "$colId INTEGER PRIMARY KEY AUTOINCREMENT, ";
    commandString += "$colIsActive INTEGER, ";
    commandString += "$colGoal TEXT, ";
    commandString += "$colReps INTEGER, ";
    commandString += "$colChallenges TEXT, ";
    commandString += "$colRules TEXT, ";
    commandString += "$colTimeIndex REAL, ";
    commandString += "$colActivity REAL, ";
    commandString += "$colRequiredRepeats REAL";
    commandString += ")";

    await db.execute(commandString);

    final List<HabitPlan> defaultHabitPlans = DefaultHabitPlans.habitPlanList;
    defaultHabitPlans.forEach((habitPlan) {
      db.insert(habitPlansTable, habitPlan.toMap());
    });
  }

  Future<List<Map<String, dynamic>>> getHabitPlanMapList() async {
    Database db = await this._getDb;

    final List<Map<String, dynamic>> result = await db.query(habitPlansTable);
    return result;
  }

  Future<List<HabitPlan>> getHabitPlanList() async {
    final List<Map<String, dynamic>> habitPlanMapList =
        await getHabitPlanMapList();

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
          "Something went wrong in getActiveHabitPlan(). Multiple Challenges are active.");
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
}
