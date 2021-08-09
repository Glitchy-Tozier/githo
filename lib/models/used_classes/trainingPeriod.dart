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

import 'package:githo/config/dataShortcut.dart';
import 'package:githo/helpers/timeHelper.dart';
import 'package:githo/models/habitPlanModel.dart';
import 'package:githo/models/used_classes/training.dart';

/// A group of [Training]s.
///
/// One or multiple [TrainingPeriods] can make up a step ([StepData]).
///
/// Example: For daily habits this would be a week.

class TrainingPeriod {
  late int index;
  late int number;
  late int durationInHours;
  late String durationText;
  late int requiredTrainings;
  String status = "";
  late List<Training> trainings;

  /// Creates a [TrainingPeriod] from a [HabitPlan].
  TrainingPeriod.fromHabitPlan({
    required int trainingPeriodIndex,
    required HabitPlan habitPlan,
  }) {
    this.index = trainingPeriodIndex;
    this.number = trainingPeriodIndex + 1;

    // Calculate the duration
    final int trainingTimeIndex = habitPlan.trainingTimeIndex;
    this.durationInHours =
        DataShortcut.periodDurationInHours[trainingTimeIndex];
    this.durationText = DataShortcut.timeFrames[trainingTimeIndex + 1];

    // Get required trainings
    this.requiredTrainings = habitPlan.requiredTrainings;

    // Create all the TrainingPeriod-instances
    final int trainingCount = DataShortcut.maxTrainings[trainingTimeIndex];
    this.trainings = [];
    for (int i = 0; i < trainingCount; i++) {
      final int trainingIndex = trainingPeriodIndex * trainingCount + i;
      this.trainings.add(
            Training.fromHabitPlan(
              trainingIndex: trainingIndex,
              habitPlan: habitPlan,
            ),
          );
    }
  }

  /// Creates a [TrainingPeriod] by directly supplying its values.
  TrainingPeriod({
    required this.index,
    required this.number,
    required this.durationInHours,
    required this.durationText,
    required this.requiredTrainings,
    required this.status,
    required this.trainings,
  });

  /// Sets the dates of its [Training]-children.
  ///
  /// The first [training] starts at [startingDate].
  void setChildrenDates(DateTime startingDate) {
    for (final Training training in this.trainings) {
      training.setDates(startingDate);
      startingDate =
          startingDate.add(Duration(hours: training.durationInHours));
    }
  }

  /// Returns [this] and the [training]-child if a [training] is found that is active  at [date].
  Map<String, dynamic>? getDataByDate(final DateTime date) {
    for (final Training training in this.trainings) {
      if ((training.startingDate.isAtSameMomentAs(date) ||
              training.startingDate.isBefore(date)) &&
          training.endingDate.isAfter(date)) {
        final Map<String, dynamic> result = {
          "training": training,
          "trainingPeriod": this,
        };
        return result;
      }
    }
  }

  /// Only used **ONCE**: The first time when the waiting-for-start-period needs to
  /// become active for progressData._analyzePassedTime(); to not crash.
  void initialActivation() {
    this.status = "active";
    this.trainings[0].status = "ready";
  }

  /// Reset [this.status] and all its [training]-children.
  void reset() {
    // Reset self
    this.status = "";

    // Reset trainings
    for (final Training training in this.trainings) {
      training.reset();
    }
  }

  /// Reset the [training]-children that come after a certain training-number.
  void resetProgressAfterNr(final int startingNumber) {
    for (final Training training in this.trainings) {
      if (training.number >= startingNumber) {
        training.reset();
      }
    }
  }

  /// Returns [this] and the [training]-child if a [training] in [this] has a status indicating that it is current/active.
  Map<String, dynamic>? get activeData {
    for (final Training training in this.trainings) {
      if (training.isActive) {
        final Map<String, dynamic> result = {
          "training": training,
          "trainingPeriod": this,
        };
        return result;
      }
    }
  }

  /// Checks if enough [trainings] were successful for [this] to be successful.
  bool get wasSuccessful {
    final bool result;
    int successfulTrainings = 0;

    for (final Training training in this.trainings) {
      if (training.status == "successful") {
        successfulTrainings++;
      }
    }
    result = (successfulTrainings >= requiredTrainings);
    return result;
  }

  /// Returns how many [trainings] so far ware successful within this [TrainingPeriod].
  ///
  /// This includes the current day in it's calculation.
  int get successfulTrainings {
    int successfulTrainings = 0;

    for (final Training training in this.trainings) {
      if (training.status == "successful" || training.status == "done") {
        successfulTrainings++;
      }
    }
    return successfulTrainings;
  }

  /// Counts how many trainings come after the current one.
  int get remainingTrainings {
    int remainingTrainings = 0;
    for (final Training training in this.trainings) {
      final DateTime now = TimeHelper.instance.currentTime;
      if (training.endingDate.isAfter(now)) {
        remainingTrainings++;
      }
    }
    return remainingTrainings;
  }

  /// Sets the [status] of [this] to "completed".
  void setResult() {
    this.status = "completed";
  }

  /// Checks if the [TrainingPeriod] is over. If so, it is marked accordingly.
  void markIfPassed() {
    final Training lastTraining = this.trainings.last;
    final DateTime now = TimeHelper.instance.currentTime;
    if (lastTraining.endingDate.isBefore(now)) {
      this.setResult();
    }
  }

  /// Converts the [TrainingPeriod] into a Map.
  Map<String, dynamic> toMap() {
    final List<Map<String, dynamic>> trainingMapList = [];

    for (final Training training in this.trainings) {
      trainingMapList.add(training.toMap());
    }

    final Map<String, dynamic> map = {};
    map["index"] = this.index;
    map["number"] = this.number;
    map["durationInHours"] = this.durationInHours;
    map["durationText"] = this.durationText;
    map["requiredTrainings"] = this.requiredTrainings;
    map["status"] = this.status;
    map["trainings"] = jsonEncode(trainingMapList);
    return map;
  }

  /// Converts a Map into a [TrainingPeriod].
  factory TrainingPeriod.fromMap(final Map<String, dynamic> map) {
    List<Training> jsonToTrainingList(final String json) {
      final List<dynamic> dynamicList = jsonDecode(json);
      final List<Training> trainings = [];

      for (final dynamic trainingMap in dynamicList) {
        final Training training = Training.fromMap(trainingMap);
        trainings.add(training);
      }

      return trainings;
    }

    return TrainingPeriod(
      index: map["index"],
      number: map["number"],
      durationInHours: map["durationInHours"],
      durationText: map["durationText"],
      requiredTrainings: map["requiredTrainings"],
      status: map["status"],
      trainings: jsonToTrainingList(map["trainings"]),
    );
  }
}
