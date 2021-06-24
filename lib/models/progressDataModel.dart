import 'dart:convert';

import 'package:githo/extracted_functions/typeExtentions.dart';

import 'package:githo/helpers/timeHelper.dart';
import 'package:githo/helpers/databaseHelper.dart';

import 'package:githo/models/habitPlanModel.dart';

import 'package:githo/models/used_classes/step.dart';
import 'package:githo/models/used_classes/training.dart';
import 'package:githo/models/used_classes/trainingPeriod.dart';

class ProgressData {
  bool isActive;
  DateTime lastActiveDate;
  DateTime currentStartingDate;
  String goal;
  List<StepClass> steps;

  // Constructors
  ProgressData({
    required this.isActive,
    required this.currentStartingDate,
    required this.lastActiveDate,
    required this.goal,
    required this.steps,
  });

  factory ProgressData.emptyData() {
    return ProgressData(
      isActive: false,
      lastActiveDate: TimeHelper.instance.getTime,
      currentStartingDate: TimeHelper.instance.getTime,
      goal: "",
      steps: [],
    );
  }

  void adaptToHabitPlan(DateTime startingDate, HabitPlan habitPlan) {
    this.isActive = true;
    this.lastActiveDate = TimeHelper.instance.getTime;
    this.currentStartingDate = startingDate;
    this.goal = habitPlan.goal;
    this.steps = [];
    for (int i = 0; i < habitPlan.steps.length; i++) {
      this.steps.add(
            StepClass(
              stepIndex: i,
              habitPlan: habitPlan,
            ),
          );
    }
    _setDates();
  }

  // Regularly used functions
  bool get _hasStarted {
    return (TimeHelper.instance.getTime.isAfter(this.currentStartingDate));
  }

  int get stepDurationInHours {
    final int duration = this.steps[0].durationInHours;
    return duration;
  }

  int get trainingPeriodDurationInHours {
    final int duration = this.steps[0].trainingPeriods[0].durationInHours;
    return duration;
  }

  int get trainingDurationInHours {
    final int duration =
        this.steps[0].trainingPeriods[0].trainings[0].durationInHours;
    return duration;
  }

  int get trainingsPerPeriod {
    final int trainingCount = this.steps[0].trainingPeriods[0].trainings.length;
    return trainingCount;
  }

  bool _inNewTraining() {
    final bool inNewTraining;

    Map<String, dynamic>? activeMap = getActiveData();
    if (activeMap == null) {
      inNewTraining = true;
    } else {
      final DateTime now = TimeHelper.instance.getTime;

      Training activeTraining = activeMap["training"];
      Training currentTraining = _getDataByDate(now)!["training"];

      if (activeTraining != currentTraining) {
        inNewTraining = inNewTraining = true;
      } else {
        inNewTraining = false;
      }
    }
    return inNewTraining;
  }

  int _getPassedTrainingPeriods({
    required DateTime startingDate,
    required DateTime endingDate,
  }) {
    final int hoursPassed = endingDate.difference(startingDate).inHours;
    final int trainingsPassed =
        (hoursPassed / this.trainingPeriodDurationInHours).floor();

    return trainingsPassed;
  }

  void incrementData() {
    final Training currentTraining = getActiveData()!["training"];
    currentTraining.incrementReps();

    updateTime();
    DatabaseHelper.instance.updateProgressData(this);
  }

  Map<String, dynamic>? getActiveData() {
    for (final StepClass step in this.steps) {
      Map<String, dynamic>? tempResult = step.getActiveData();
      if (tempResult != null) {
        return tempResult;
      }
    }
  }

  Map<String, int> _penalizeInactivity(
    Map<String, dynamic> lastActiveMap,
    int penalty,
  ) {
    int newStep = (lastActiveMap["step"] as StepClass).number;
    int newPeriod = (lastActiveMap["trainingPeriod"] as TrainingPeriod).number;
    for (int i = 0; i < -penalty; i++) {
      if (newPeriod > 1) {
        newPeriod--;
      } else {
        if (newStep > 1) {
          newStep--;
          newPeriod = this.steps[0].trainingPeriods.length;
        } else {
          break;
        }
      }
    }
    final Map<String, int> newTrainingPeriodPosition = {
      "step": newStep,
      "trainingPeriod": newPeriod
    };
    return newTrainingPeriodPosition;
  }

  DateTime _getStartingDate() {
    DateTime newStartingDate = this.currentStartingDate;
    DateTime now = TimeHelper.instance.getTime;
    while (5 < 4) {
      if (newStartingDate.isBefore(now)) {
        print("A WEEK HAS PASSED");
        newStartingDate.add(
          Duration(
            hours: this.stepDurationInHours,
          ),
        );
      } else {
        print("Wait, no.");
        newStartingDate.subtract(
          Duration(
            hours: this.stepDurationInHours,
          ),
        );
        break;
      }
    }
    return newStartingDate;
  }

  void _setDates(
      [Map<String, int> startingTrainingPeriodData = const {
        "step": 1,
        "trainingPeriod": 1
      }]) {
    final int startingStepNr = startingTrainingPeriodData["step"]!;
    final int startingPeriodNr = startingTrainingPeriodData["trainingPeriod"]!;
    DateTime startingDate = _getStartingDate();

    // Update starting date
    this.currentStartingDate = startingDate;

    // Set dates for all the trainings
    if (startingPeriodNr > 1) {
      final int extraPeriods = startingPeriodNr - 1;
      for (int i = 0; i < extraPeriods; i++) {
        startingDate.add(
          Duration(
            hours: this.trainingPeriodDurationInHours,
          ),
        );
      }
    }
    for (final StepClass step in this.steps.sublist(startingStepNr - 1)) {
      step.setChildrenDates(startingDate);
      startingDate = startingDate.add(Duration(hours: step.durationInHours));
    }
  }

  Map<String, dynamic>? _getDataByDate(DateTime date) {
    Map<String, dynamic>? map = {};
    for (final StepClass step in this.steps) {
      map = step.getDataByDate(date);
      if (map != null) {
        return map;
      }
    }
  }

  void _resetTrainingProgresses(Training training) {
    final int startingTrainingNr = training.number;

    for (final step in this.steps) {
      step.resetChildrenProgresses(startingTrainingNr);
    }
  }

  void _analyzePassedTime() {
    Map<String, dynamic> lastActiveMap = getActiveData()!;
    final Training lastActiveTraining = lastActiveMap["training"];
    lastActiveTraining.setResult();
    print("lastNr ${lastActiveTraining.number}");
    print("LastSt ${lastActiveTraining.status}");

    // Calculate the number of trainingPeriods passed. For dayly trainings, that would be how many weeks have passed.
    final DateTime now = TimeHelper.instance.getTime;
    final int passedTrainingPeriods = _getPassedTrainingPeriods(
      startingDate: this.currentStartingDate,
      endingDate: now,
    );
    int periodMoveCounter = 0;
    print("\n\n\n\n\n");
    print(this.currentStartingDate);
    for (int i = 0; i < passedTrainingPeriods; i++) {
      TrainingPeriod passedPeriod = lastActiveMap["trainingPeriod"];
      passedPeriod.validate();

      if (i == 0) {
        if (passedPeriod.status == "successful") {
          periodMoveCounter++;
        } else {
          periodMoveCounter--;
        }
      } else {
        periodMoveCounter--;
      }
    }
    print(periodMoveCounter);
    print("\n\n\n\n\n");

    if (periodMoveCounter <= 0) {
      // No need for the initial validation as the training period will be reset anyways
      Map<String, int> newTrainingPeriodPosition =
          _penalizeInactivity(lastActiveMap, periodMoveCounter);

      _setDates(newTrainingPeriodPosition);

      print(this.currentStartingDate);
      Training firstTrainingToReset =
          _getDataByDate(this.currentStartingDate)!["training"];

      _resetTrainingProgresses(firstTrainingToReset);
    }
  }

  void _moveToCurrentTraining() {
    Map<String, dynamic> currentData =
        _getDataByDate(TimeHelper.instance.getTime)!;

    Training currentTraining = currentData["training"];
    currentTraining.status = "current";

    TrainingPeriod currentPeriod = currentData["trainingPeriod"];
    currentPeriod.status = "active";
  }

  void updateTime() {
    print(this._hasStarted);
    print(_inNewTraining());
    if (this._hasStarted && _inNewTraining()) {
      if (getActiveData() == null) {
        // No complicated calculations necessary.
        _setDates();
      } else {
        // Analyze what happened since last time opening the app
        _analyzePassedTime();
      }
      // Activate the next Training/TrainingPeriod
      _moveToCurrentTraining();
    }
    DatabaseHelper.instance.updateProgressData(this);
  }

  // Functions for interacting with the database
  Map<String, dynamic> toMap() {
    final map = Map<String, dynamic>();

    List<Map> mapList = [];
    for (final StepClass step in this.steps) {
      mapList.add(step.toMap());
    }

    map["isActive"] = isActive.boolToInt();
    map["lastActiveDate"] = lastActiveDate.toString();
    map["currentStartingDate"] = currentStartingDate.toString();
    map["goal"] = goal;
    map["steps"] = jsonEncode(mapList);
    return map;
  }

  factory ProgressData.fromMap(Map<String, dynamic> map) {
    List<StepClass> jsonToStepList(String json) {
      List<dynamic> dynamicList = jsonDecode(json);
      List<StepClass> stepList = <StepClass>[];

      for (final dynamic stepMap in dynamicList) {
        stepList.add(StepClass.fromMap(stepMap));
      }

      return stepList;
    }

    return ProgressData(
      isActive: (map["isActive"] as int).intToBool(),
      lastActiveDate: DateTime.parse(map["lastActiveDate"]),
      currentStartingDate: DateTime.parse(map["currentStartingDate"]),
      goal: map["goal"],
      steps: jsonToStepList(map["steps"]),
    );
  }
}
