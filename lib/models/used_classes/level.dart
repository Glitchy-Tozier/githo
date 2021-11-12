/* 
 * Githo – An app that helps you gradually form long-lasting habits.
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

import 'package:githo/config/data_shortcut.dart';
import 'package:githo/models/habit_plan.dart';
import 'package:githo/models/progress_data.dart';
import 'package:githo/models/used_classes/training.dart';
import 'package:githo/models/used_classes/training_period.dart';

/// A level of potency of your final habit.

class Level {
  /// Creates a [Level] by directly supplying its values.
  Level({
    required this.index,
    required this.number,
    required this.text,
    required this.durationInHours,
    required this.trainingPeriods,
    required this.save,
  });

  /// Creates a [Level] from a [HabitPlan].
  Level.fromHabitPlan({
    required final int levelIndex,
    required final HabitPlan habitPlan,
    required this.save,
  })  : index = levelIndex,
        number = levelIndex + 1,
        text = habitPlan.levels[levelIndex],
        durationInHours = _getDurationHours(habitPlan),
        // Create all the TrainingPeriod-instances
        trainingPeriods = _getTrainingPeriods(levelIndex, habitPlan, save);

  /// Converts a Map into a [Level].
  Level.fromMap(final Map<String, dynamic> map, this.save)
      : index = map['index'] as int,
        number = map['number'] as int,
        text = map['text'] as String,
        durationInHours = map['durationInHours'] as int,
        trainingPeriods =
            _jsonToPeriodList(map['trainingPeriods'] as String, save);

  final int index;
  final int number; // = index + 1
  final String text;
  final int durationInHours;
  final List<TrainingPeriod> trainingPeriods;
  final Future<void> Function() save;

  /// Calculates the level's duration and returns the number of hours.
  static int _getDurationHours(final HabitPlan habitPlan) {
    final int trainingPeriodCount = habitPlan.requiredTrainingPeriods;
    final int trainingPeriodHours =
        DataShortcut.periodDurationInHours[habitPlan.trainingTimeIndex];
    final int levelHours = trainingPeriodHours * trainingPeriodCount;
    return levelHours;
  }

  /// Generates and returns the [List] of [TrainingPeriod]s that
  /// form this [Level].
  static List<TrainingPeriod> _getTrainingPeriods(
    final int levelIndex,
    final HabitPlan habitPlan,
    final Future<void> Function() save,
  ) {
    final List<TrainingPeriod> trainingPeriods = <TrainingPeriod>[];
    final int trainingPeriodCount = habitPlan.requiredTrainingPeriods;

    for (int i = 0; i < habitPlan.requiredTrainingPeriods; i++) {
      final int trainingPeriodIndex = levelIndex * trainingPeriodCount + i;
      trainingPeriods.add(
        TrainingPeriod.fromHabitPlan(
          trainingPeriodIndex: trainingPeriodIndex,
          habitPlan: habitPlan,
          save: save,
        ),
      );
    }
    return trainingPeriods;
  }

  /// Converts a [json]-like [String] into a list of [TrainingPeriod]s.
  static List<TrainingPeriod> _jsonToPeriodList(
    final String json,
    final Future<void> Function() save,
  ) {
    final dynamic dynamicList = jsonDecode(json);
    final List<TrainingPeriod> trainingPeriods = <TrainingPeriod>[];

    for (final Map<String, dynamic> map in dynamicList) {
      final TrainingPeriod trainingPeriod = TrainingPeriod.fromMap(map, save);
      trainingPeriods.add(trainingPeriod);
    }
    return trainingPeriods;
  }

  /// Returns the status of the [Level].
  ///
  /// This value is derived from its children.
  String get status {
    int completedCount = 0;
    for (final TrainingPeriod trainingPeriod in trainingPeriods) {
      if (trainingPeriod.status == 'completed') {
        completedCount++;
      } else if (trainingPeriod.status == 'active') {
        return 'active';
      }
    }
    if (completedCount == trainingPeriods.length) {
      return 'completed';
    } else {
      return 'locked';
    }
  }

  /// Returns the index of the active [TrainingPeriod], if one is found.
  int? get _activePeriodIndex {
    for (int i = 0; i < trainingPeriods.length; i++) {
      final TrainingPeriod trainingPeriod = trainingPeriods[i];
      if (trainingPeriod.status == 'active') {
        return i;
      }
    }
    return trainingPeriods.length - 1;
  }

  /// Resets [periodsToRegress] of the [trainingPeriods],
  /// then returns the remaining amount.
  int regressPeriods(final int periodsToRegress) {
    int activePeriodIndex = _activePeriodIndex!;
    int remainingRegressions = periodsToRegress;

    while (remainingRegressions > 0) {
      final TrainingPeriod activePeriod = trainingPeriods[activePeriodIndex];
      activePeriod.reset();
      if (activePeriodIndex == 0) {
        return remainingRegressions - 1;
      } else {
        activePeriodIndex--;
        remainingRegressions--;
      }
    }
    return 0;
  }

  /// Sets the dates of the level's children, starting from [startingDate],
  /// starting with a specific [trainingPeriod].
  DateTime setChildrenDates(
    final DateTime startingDate,
    final int startingPeriodIdx,
  ) {
    DateTime currentStartingDate = startingDate;
    final int startingPeriodListIdx =
        startingPeriodIdx.remainder(trainingPeriods.length);

    for (int i = startingPeriodListIdx; i < trainingPeriods.length; i++) {
      final TrainingPeriod trainingPeriod = trainingPeriods[i];

      trainingPeriod.setChildrenDates(currentStartingDate);
      currentStartingDate = currentStartingDate
          .add(Duration(hours: trainingPeriod.durationInHours));
    }
    return currentStartingDate;
  }

  /// Returns [this], the current trainingPeriod, and the current training,
  /// if they align with the specified [date].
  ProgressDataSlice? getDataSliceByDate(final DateTime date) {
    for (final TrainingPeriod trainingPeriod in trainingPeriods) {
      final Training? training = trainingPeriod.getChildByDate(date);

      if (training != null) {
        return ProgressDataSlice(
          level: this,
          period: trainingPeriod,
          training: training,
        );
      }
    }
  }

  /// Resets the progress of the [TrainingPeriod]-children
  /// that come after a certain [startingNumber].
  void resetProgressAfterNr(final int startingNumber) {
    for (final TrainingPeriod trainingPeriod in trainingPeriods) {
      trainingPeriod.resetProgressAfterNr(startingNumber);
    }
  }

  /// Returns [this], the active trainingPeriod, and the active training.
  ProgressDataSlice? get activeDataSlice {
    for (final TrainingPeriod trainingPeriod in trainingPeriods) {
      if (trainingPeriod.status == 'active') {
        final Training? activeTraining = trainingPeriod.activeChild;

        if (activeTraining != null) {
          return ProgressDataSlice(
            level: this,
            period: trainingPeriod,
            training: activeTraining,
          );
        }
      }
    }
  }

  /// Returns [this], the waiting [TrainingPeriod] and its first [Training], if
  /// the [TrainingPeriod] actually is waiting for its start.
  ProgressDataSlice? get waitingDataSlice {
    for (final TrainingPeriod trainingPeriod in trainingPeriods) {
      if (trainingPeriod.status == 'waiting for start') {
        return ProgressDataSlice(
          level: this,
          period: trainingPeriod,
          training: trainingPeriod.trainings[0],
        );
      }
    }
  }

  /// Marks the passed [trainingPeriods].
  void markPassedPeriods() {
    for (final TrainingPeriod trainingPeriod in trainingPeriods) {
      trainingPeriod.markIfPassed();
    }
  }

  /// Performs the initial activation of the starting [trainingPeriod].
  void activateWaitingPeriod() {
    for (final TrainingPeriod trainingPeriod in trainingPeriods) {
      if (trainingPeriod.status == 'waiting for start') {
        trainingPeriod.initialActivation();
      }
    }
  }

  /// Converts the [Level] into a Map.
  Map<String, dynamic> toMap() {
    final List<Map<String, dynamic>> trainingPeriodMapList =
        <Map<String, dynamic>>[];

    for (final TrainingPeriod trainingPeriod in trainingPeriods) {
      trainingPeriodMapList.add(trainingPeriod.toMap());
    }

    final Map<String, dynamic> map = <String, dynamic>{
      'index': index,
      'number': number,
      'text': text,
      'durationInHours': durationInHours,
      'trainingPeriods': jsonEncode(trainingPeriodMapList),
    };
    return map;
  }
}
