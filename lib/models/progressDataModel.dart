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

import 'dart:convert';

import 'package:githo/extracted_functions/typeExtentions.dart';

import 'package:githo/helpers/timeHelper.dart';
import 'package:githo/helpers/databaseHelper.dart';

import 'package:githo/models/habitPlanModel.dart';

import 'package:githo/models/used_classes/step.dart';
import 'package:githo/models/used_classes/training.dart';
import 'package:githo/models/used_classes/trainingPeriod.dart';

class ProgressData {
  int habitPlanId;
  bool isActive;
  bool fullyCompleted;
  DateTime currentStartingDate;
  String habit;
  List<StepData> steps;

  // Constructors
  ProgressData({
    required this.habitPlanId,
    required this.isActive,
    required this.fullyCompleted,
    required this.currentStartingDate,
    required this.habit,
    required this.steps,
  });

  factory ProgressData.emptyData() {
    return ProgressData(
      habitPlanId: 123456789,
      isActive: false,
      fullyCompleted: false,
      currentStartingDate: DateTime(0),
      habit: "",
      steps: const [],
    );
  }

  void adaptToHabitPlan({
    required final HabitPlan habitPlan,
    required final DateTime startingDate,
    final int startingStepNr = 1,
  }) {
    this.habitPlanId = habitPlan.id!;
    this.isActive = true;
    this.fullyCompleted = habitPlan.fullyCompleted;
    this.currentStartingDate = startingDate;
    this.habit = habitPlan.habit;
    this.steps = [];
    for (int i = 0; i < habitPlan.steps.length; i++) {
      this.steps.add(
            StepData.fromHabitPlan(
              stepIndex: i,
              habitPlan: habitPlan,
            ),
          );
    }

    final int startingStepIdx = startingStepNr - 1;
    this.steps[startingStepIdx].trainingPeriods[0].status = "waiting for start";

    final Map<String, int> startingIdxData = {
      "step": startingStepIdx,
      "trainingPeriod": 0,
    };
    _setTrainingDates(startingIdxData);
  }

  // Regularly used functions
  bool get _hasStarted {
    final DateTime now = TimeHelper.instance.currentTime;
    final bool hasStarted = now.isAfter(this.currentStartingDate);
    return hasStarted;
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

  bool get _inNewTraining {
    final bool inNewTraining;

    Map<String, dynamic>? activeMap = this.activeData;
    if (activeMap == null) {
      inNewTraining = true;
    } else {
      final DateTime now = TimeHelper.instance.currentTime;
      final Map<String, dynamic>? currentMap = _getDataByDate(now);
      if (currentMap != null) {
        final Training activeTraining = activeMap["training"];
        final Training currentTraining = currentMap["training"];

        if (activeTraining != currentTraining) {
          inNewTraining = true;
        } else {
          inNewTraining = false;
        }
      } else {
        // If we've run out of trainings, act as if we are in a new training
        inNewTraining = true;
      }
    }
    return inNewTraining;
  }

  int _getPassedTrainingPeriods({
    required final DateTime startingDate,
    required final DateTime endingDate,
  }) {
    final int hoursPassed = endingDate.difference(startingDate).inHours;
    final int trainingsPassed =
        (hoursPassed / this.trainingPeriodDurationInHours).floor();

    return trainingsPassed;
  }

  Map<String, dynamic>? get activeData {
    for (final StepData step in this.steps) {
      final Map<String, dynamic>? tempResult = step.activeData;
      if (tempResult != null) {
        return tempResult;
      }
    }
  }

  Map<String, dynamic>? get waitingData {
    for (final StepData step in this.steps) {
      final Map<String, dynamic>? tempResult = step.waitingData;
      if (tempResult != null) {
        return tempResult;
      }
    }
  }

  void _activateStartingPeriod() {
    for (final StepData step in this.steps) {
      step.activateStartingPeriod();
    }
  }

  void _setNewStartingDate() {
    final DateTime now = TimeHelper.instance.currentTime;
    final Duration periodDuration =
        Duration(hours: this.trainingPeriodDurationInHours);

    while ((this.currentStartingDate.add(periodDuration)).isBefore(now)) {
      print("Moved date one trainingPeriod.");
      this.currentStartingDate = this.currentStartingDate.add(periodDuration);
    }
  }

  void _setTrainingDates(
      [final Map<String, int> startingIndexData = const {
        "step": 0,
        "trainingPeriod": 0,
      }]) {
    final int startingStepIdx = startingIndexData["step"]!;
    final int startingPeriodIdx = startingIndexData["trainingPeriod"]!;

    // Set dates for all the trainings
    DateTime workingDate = this.currentStartingDate;

    for (int i = startingStepIdx; i < this.steps.length; i++) {
      final StepData step = this.steps[i];

      if (i == startingStepIdx) {
        workingDate = step.setChildrenDates(workingDate, startingPeriodIdx);
      } else {
        workingDate = step.setChildrenDates(workingDate, 0);
      }
    }
  }

  Map<String, dynamic>? _getDataByDate(final DateTime date) {
    Map<String, dynamic>? map;
    for (final StepData step in this.steps) {
      map = step.getDataByDate(date);
      if (map != null) {
        return map;
      }
    }
  }

  Map<String, int> _penalizeFailure(
    final int failedPeriods,
    final Map<String, dynamic> lastActiveMap,
  ) {
    final int previouslyActivePeriodIdx =
        (lastActiveMap["trainingPeriod"] as TrainingPeriod).index;

    int currentStepIdx = (lastActiveMap["step"] as StepData).index;
    int remainingRegressions = failedPeriods +
        1; // Always reset one additional period to make sure we actually move backwards in time.

    while (true) {
      final StepData currentStep = this.steps[currentStepIdx];
      remainingRegressions = currentStep.regressPeriods(remainingRegressions);

      if (remainingRegressions > 0 && currentStepIdx > 0) {
        // If there are more loops to come AND we haven't reached the start of all challenges
        currentStepIdx--;
      } else {
        // If this was the last loop, return the current trainingPeriod's position

        final int newCurrentStepIdx = currentStepIdx;
        final int newCurrentPeriodIdx;
        if (previouslyActivePeriodIdx == 0) {
          newCurrentPeriodIdx = 0;
        } else {
          newCurrentPeriodIdx = previouslyActivePeriodIdx - failedPeriods;
        }

        final Map<String, int> newCurrentPosition = {
          "step": newCurrentStepIdx,
          "trainingPeriod": newCurrentPeriodIdx,
        };
        return newCurrentPosition;
      }
    }
  }

  void _completeHabitPlan() async {
    final HabitPlan? habitPlan =
        await DatabaseHelper.instance.getHabitPlan(this.habitPlanId);

    if (habitPlan != null) {
      habitPlan.fullyCompleted = true;
      DatabaseHelper.instance.updateHabitPlan(habitPlan);
    }
  }

  void _analyzePassedTime() {
    final Map<String, dynamic> lastActiveMap = this.activeData!;

    // Analyze the last training
    final Training lastActiveTraining = lastActiveMap["training"];
    lastActiveTraining.setResult();

    // Analyze the passed trainingPeriods
    // Calculate the number of trainingPeriods passed. For dayly trainings, that would be how many weeks have passed.
    final DateTime now = TimeHelper.instance.currentTime;
    final int passedTrainingPeriods = _getPassedTrainingPeriods(
      startingDate: this.currentStartingDate,
      endingDate: now,
    );

    if (passedTrainingPeriods >= 1) {
      // Analyze the trainingPeriod that was last active
      final TrainingPeriod lastActivePeriod = lastActiveMap["trainingPeriod"];

      // Get the number of failed trainigPeriods
      int failedPeriods = passedTrainingPeriods;
      if (lastActivePeriod.wasSuccessful) {
        print("WAS SUCCESSFUL!!!!!!!!!!");
        failedPeriods -= 2;
      }

      print("failedPeriods: $failedPeriods");
      _setNewStartingDate();

      final TrainingPeriod lastPeriod = this.steps.last.trainingPeriods.last;

      if (lastActivePeriod.wasSuccessful && lastActivePeriod == lastPeriod) {
        this.fullyCompleted = true;
        _completeHabitPlan();
      }

      if (failedPeriods >= 0 || lastActivePeriod == lastPeriod) {
        final Map<String, int> nextPeriodPosition;
        nextPeriodPosition = _penalizeFailure(failedPeriods, lastActiveMap);
        _setTrainingDates(nextPeriodPosition);
      }
    }
  }

  void _completePassedPeriods() {
    for (final StepData step in this.steps) {
      step.markPassedPeriods();
    }
  }

  void _activateCurrentTraining() {
    final DateTime now = TimeHelper.instance.currentTime;
    final Map<String, dynamic> currentData = _getDataByDate(now)!;

    final Training currentTraining = currentData["training"];
    currentTraining.status = "current";

    final TrainingPeriod currentPeriod = currentData["trainingPeriod"];
    currentPeriod.status = "active";
  }

  bool updateSelf() {
    final bool somethingChanged;

    if (this._hasStarted && this._inNewTraining) {
      if (this.activeData == null) {
        // If this is the first training we ever arrive in
        _activateStartingPeriod();
      }

      // Analyze what happened since last time opening the app
      _analyzePassedTime();

      // Activate the next Training/TrainingPeriod
      _activateCurrentTraining();

      // Save all changes
      DatabaseHelper.instance.updateProgressData(this);

      somethingChanged = true;
    } else {
      somethingChanged = false;
    }

    // Set the passed trainings' status to "complete"
    _completePassedPeriods();

    return somethingChanged;
  }

  // Functions for interacting with the database
  Map<String, dynamic> toMap() {
    final List<Map> stepMapList = [];

    for (final StepData step in this.steps) {
      stepMapList.add(step.toMap());
    }

    final Map<String, dynamic> map = {};
    map["habitPlanId"] = habitPlanId;
    map["isActive"] = isActive.boolToInt();
    map["fullyCompleted"] = fullyCompleted.boolToInt();
    map["currentStartingDate"] = currentStartingDate.toString();
    map["goal"] = habit;
    map["steps"] = jsonEncode(stepMapList);
    return map;
  }

  factory ProgressData.fromMap(final Map<String, dynamic> map) {
    List<StepData> jsonToStepList(final String json) {
      final List<dynamic> dynamicList = jsonDecode(json);
      final List<StepData> steps = [];

      for (final dynamic stepMap in dynamicList) {
        steps.add(StepData.fromMap(stepMap));
      }

      return steps;
    }

    return ProgressData(
      habitPlanId: map["habitPlanId"],
      isActive: (map["isActive"] as int).intToBool(),
      fullyCompleted: (map["fullyCompleted"] as int).intToBool(),
      currentStartingDate: DateTime.parse(map["currentStartingDate"]),
      habit: map["goal"],
      steps: jsonToStepList(map["steps"]),
    );
  }
}
