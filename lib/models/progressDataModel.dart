import 'dart:convert';

import 'package:githo/helpers/timeHelper.dart';
import 'package:githo/extracted_functions/jsonToList.dart';
import 'package:githo/helpers/databaseHelper.dart';
import 'package:githo/models/habitPlanModel.dart';
import 'package:githo/models/used_classes/step.dart';
import 'package:githo/models/used_classes/training.dart';
import 'package:githo/models/used_classes/trainingPeriod.dart';

class ProgressData {
  DateTime lastActiveDate;
  DateTime currentStartingDate;
  String goal;
  List<StepClass> steps;

  ProgressData({
    required this.currentStartingDate,
    required this.lastActiveDate,
    required this.goal,
    required this.steps,
  });

  factory ProgressData.emptyData() {
    return ProgressData(
      lastActiveDate: TimeHelper.instance.getTime,
      currentStartingDate: TimeHelper.instance.getTime,
      goal: "",
      steps: [],
    );
  }

  void adaptToHabitPlan(DateTime startingDate, HabitPlan habitPlan) {
    this.lastActiveDate = TimeHelper.instance.getTime;
    this.currentStartingDate = startingDate;
    this.goal = habitPlan.goal;
    this.steps = [];
    for (int i = 0; i < habitPlan.steps.length; i++) {
      this.steps.add(
            StepClass(stepIndex: i, habitPlan: habitPlan),
          );
    }
    _setTrainingDates();
  }

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

  // Regularly used functions
  void incrementData() {
    Training? currentTraining = _getActiveTraining();
    if (currentTraining != null) {
      currentTraining.incrementReps();
    }
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

  Training? _getActiveTraining() {
    for (final StepClass step in this.steps) {
      Training? training = step.getActiveTraining();
      if (training != null) {
        return training;
      }
    }
  }

  Map<String, int> _penalizeInactivity(
    Map<String, dynamic> lastActiveMap,
    int inactivePeriods,
  ) {
    int newStep = lastActiveMap["step"];
    int newPeriod = lastActiveMap["trainingPeriod"];
    for (int i = 0; i < inactivePeriods - 1; i++) {
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
      print("A WEEK HAS PASSED");
      if (newStartingDate.isBefore(now)) {
        newStartingDate.add(
          Duration(
            hours: this.stepDurationInHours,
          ),
        );
      } else {
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

  void _setTrainingDates(
      [Map<String, int> startingTrainingPeriodData = const {
        "step": 1,
        "trainingPeriod": 1
      }]) {
    if (this._hasStarted) {
      final int startingStepNr = startingTrainingPeriodData["step"]!;
      final int startingPeriodNr =
          startingTrainingPeriodData["trainingPeriod"]!;
      DateTime startingDate = _getStartingDate();
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
      for (final step in this.steps.sublist(startingStepNr - 1)) {
        step.setChildrenDates(startingDate);
        startingDate.add(Duration(hours: step.durationInHours));
      }
    }
  }

  Training? _getTrainingByDate(DateTime date) {
    for (final StepClass step in this.steps) {
      Training? training = step.getTrainingByDate(date);
      if (training != null) {
        return training;
      }
    }
  }

  void _resetTrainingProgresses(Training training) {
    final int startingTrainingNr = training.number;

    for (final step in this.steps) {
      step.resetChildrenProgresses(startingTrainingNr);
    }
  }

  void updateTime() {
    final DateTime currentDate = TimeHelper.instance.getTime;

    final StepClass firstStep = this.steps.first;
    final TrainingPeriod firstPeriod = firstStep.trainingPeriods.first;
    final Training firstTraining = firstPeriod.trainings.first;
    // Make sure we're not in the initial waiting period
    if (this._hasStarted) {
      // Get the number of trainings passed since {insert first date} (for dayly trainings days)
      final int lastActiveDiffHours =
          this.lastActiveDate.difference(currentStartingDate).inHours;
      final int lastActiveTrainingsDiff =
          (lastActiveDiffHours / firstTraining.durationInHours).floor();

      final int nowDiffHours =
          currentDate.difference(currentStartingDate).inHours;
      final int nowTrainingsDiff =
          (nowDiffHours / firstTraining.durationInHours).floor();

      // Check if we have moved to a new training (For dayly trainings, that would be the next day).
      final bool inNewTraining = (lastActiveTrainingsDiff != nowTrainingsDiff);
      if (inNewTraining) {
        Map<String, dynamic> lastActiveMap = getActiveData()!;
        final Training lastActiveTraining = lastActiveMap["training"];
        lastActiveTraining.setResult();

        // Calculate the number of trainingPeriods passed. For dayly trainings, that would be how many weeks have passed.
        final int passedTrainingPeriods =
            (nowTrainingsDiff / firstPeriod.trainings.length).floor();
        if (passedTrainingPeriods == 1) {
        } else {
          Map<String, int> newTrainingPeriodPosition =
              _penalizeInactivity(lastActiveMap, passedTrainingPeriods);
          _setTrainingDates(newTrainingPeriodPosition);
          Training firstTrainingToReset =
              _getTrainingByDate(this.currentStartingDate)!;
          _resetTrainingProgresses(firstTrainingToReset);
        }
      }

      DatabaseHelper.instance.updateProgressData(this);
    }
  }

  // Functions for interacting with the database
  Map<String, dynamic> toMap() {
    final map = Map<String, dynamic>();

    List<Map> mapList = [];
    for (final StepClass step in this.steps) {
      mapList.add(step.toMap());
    }

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
      lastActiveDate: DateTime.parse(map["lastActiveDate"]),
      currentStartingDate: DateTime.parse(map["currentStartingDate"]),
      goal: map["goal"],
      steps: jsonToStepList(map["steps"]),
    );
  }
}
