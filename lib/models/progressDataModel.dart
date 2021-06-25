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
    _setNewStartingDate();
    _setTrainingDates();
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

  Map<String, dynamic>? getActiveData() {
    for (final StepClass step in this.steps) {
      Map<String, dynamic>? tempResult = step.getActiveData();
      if (tempResult != null) {
        return tempResult;
      }
    }
  }

  void _setNewStartingDate() {
    DateTime now = TimeHelper.instance.getTime;
    final Duration periodDuration =
        Duration(hours: this.trainingPeriodDurationInHours);

    while ((this.currentStartingDate.add(periodDuration)).isBefore(now)) {
      print("WEEK SUBTRACTED");
      this.currentStartingDate = this.currentStartingDate.add(periodDuration);
    }
  }

  void _setTrainingDates(
      [Map<String, int> startingTrainingPeriodData = const {
        "step": 1,
        "trainingPeriod": 1
      }]) {
    final int startingStepNr = startingTrainingPeriodData["step"]!;
    final int startingPeriodNr = startingTrainingPeriodData["trainingPeriod"]!;

    // Set dates for all the trainings
    DateTime workingDate = this.currentStartingDate;
    if (startingPeriodNr > 1) {
      final int extraPeriods = startingPeriodNr - 1;
      for (int i = 0; i < extraPeriods; i++) {
        workingDate.add(
          Duration(
            hours: this.trainingPeriodDurationInHours,
          ),
        );
      }
    }
    for (final StepClass step in this.steps.sublist(startingStepNr - 1)) {
      step.setChildrenDates(workingDate);
      workingDate = workingDate.add(Duration(hours: step.durationInHours));
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

  Map<String, int> _resetPeriodValues(
    int failedPeriods,
    Map<String, dynamic> lastActiveMap,
  ) {
    int currentStepIdx = (lastActiveMap["step"] as StepClass).index;
    while (failedPeriods > 0) {
      StepClass currentStep = this.steps[currentStepIdx];
      int remainingRegressions = currentStep.regressPeriods(failedPeriods);

      if (remainingRegressions > 0) {
        // If there are more loops to come
        currentStepIdx--;
        failedPeriods = remainingRegressions;
      } else {
        // If this was the last loop, return the current trainingPeriod's position
        return {
          "step": currentStep.number,
          "trainingPeriod": currentStep.trainingPeriods.length - failedPeriods,
        };
      }
    }
    throw "ProgressData: _resetPeriodValues(...) was called with a failedPeriods smaller or equal to 0";
  }

  void _analyzePassedTime() {
    final Map<String, dynamic> lastActiveMap = getActiveData()!;

    // Analyze the last training
    final Training lastActiveTraining = lastActiveMap["training"];
    lastActiveTraining.setResult();

    // Analyze the passed trainingPeriods
    // Calculate the number of trainingPeriods passed. For dayly trainings, that would be how many weeks have passed.
    final DateTime now = TimeHelper.instance.getTime;
    final int passedTrainingPeriods = _getPassedTrainingPeriods(
      startingDate: this.currentStartingDate,
      endingDate: now,
    );

    if (passedTrainingPeriods >= 1) {
      // Analyze the trainingPeriod that was last active
      final TrainingPeriod lastActivePeriod = lastActiveMap["trainingPeriod"];
      lastActivePeriod.status = "completed";

      // Get the number of failed trainigPeriods
      int failedPeriods = passedTrainingPeriods;
      if (lastActivePeriod.wasSuccessful) {
        failedPeriods--;
      }

      _setNewStartingDate();

      if (failedPeriods >= 1) {
        final Map<String, int> nextPeriodPosition;
        nextPeriodPosition = _resetPeriodValues(failedPeriods, lastActiveMap);
        _setTrainingDates(nextPeriodPosition);
      }
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
    if (this._hasStarted && _inNewTraining()) {
      if (getActiveData() == null) {
        // If this is the first training we ever arrive in
        _setNewStartingDate();
        _setTrainingDates();
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
