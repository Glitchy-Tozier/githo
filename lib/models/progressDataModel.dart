import 'dart:convert';

import 'package:githo/helpers/timeHelper.dart';
import 'package:githo/extracted_functions/jsonToList.dart';
import 'package:githo/helpers/databaseHelper.dart';
import 'package:githo/models/used_classes/step.dart';
import 'package:githo/models/used_classes/training.dart';
import 'package:githo/models/used_classes/trainingPeriod.dart';

class ProgressData {
  DateTime lastActiveDate;
  DateTime currentStartingDate;
  /* int completedReps;
  int completedTrainings;
  int completedTrainingPeriods;
  List<String> trainingData;*/
  List<Step> steps;

  ProgressData({
    required this.currentStartingDate,
    required this.lastActiveDate,
    /* required this.completedReps,
    required this.completedTrainings,
    required this.completedTrainingPeriods,
    required this.trainingData, */
    required this.steps,
  });
  bool get _hasStarted {
    return (TimeHelper.instance.getTime.isAfter(this.currentStartingDate));
  }

  // Regularly used functions
  void incrementData() {
    Training? currentTraining = _getActiveTraining();
    if (currentTraining != null) {
      currentTraining.incrementReps();
    }
    DatabaseHelper.instance.updateProgressData(this);
  }

  Map<String, dynamic>? _getActiveData() {
    for (final Step step in this.steps) {
      Map<String, dynamic>? tempResult = step.getActiveData();
      if (tempResult != null) {
        return tempResult;
      }
    }
  }

  Training? _getActiveTraining() {
    for (final Step step in this.steps) {
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
            hours: this.steps[0].durationInHours,
          ),
        );
      } else {
        newStartingDate.subtract(
          Duration(
            hours: this.steps[0].durationInHours,
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
              hours: this.steps[0].trainingPeriods[0].durationInHours,
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
    for (final Step step in this.steps) {
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

  Map<String, int> updateTime() {
    final passedTime = Map<String, int>();
    passedTime["steps"] = 0;
    passedTime["trainingPeriods"] = 0;
    passedTime["trainings"] = 0;

    final DateTime currentDate = TimeHelper.instance.getTime;

    final Step firstStep = this.steps.first;
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
        Map<String, dynamic> lastActiveMap = _getActiveData()!;
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
    return passedTime;
  }

  // Functions for interacting with the database
  Map<String, dynamic> toMap() {
    final map = Map<String, dynamic>();

    map["lastActiveDate"] = lastActiveDate.toString();
    map["currentStartingDate"] = currentStartingDate.toString();
    map["steps"] = jsonEncode(steps);

    return map;
  }

  factory ProgressData.fromMap(Map<String, dynamic> map) {
    List<Step> jsonToList(String json) {
      return [];
    }

    return ProgressData(
      lastActiveDate: DateTime.parse(map["lastActiveDate"]),
      currentStartingDate: DateTime.parse(map["currentStartingDate"]),
      steps: jsonToList(map["steps"]),
    );
  }
}
