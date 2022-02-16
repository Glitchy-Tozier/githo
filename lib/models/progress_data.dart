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
import 'package:githo/database/database_helper.dart';
import 'package:githo/helpers/time_helper.dart';
import 'package:githo/helpers/type_extentions.dart';
import 'package:githo/models/habit_plan.dart';
import 'package:githo/models/used_classes/level.dart';
import 'package:githo/models/used_classes/training.dart';
import 'package:githo/models/used_classes/training_period.dart';

/// A class that makes conveying a [TrainingPeriod]'s position easier.
class PeriodPosition {
  const PeriodPosition({
    required this.levelIdx,
    required this.periodIdx,
  });

  /// The index of what [Level] the [TrainingPeriod] belongs to.
  final int levelIdx;

  /// The index of the [TrainingPeriod], within the [Level].
  final int periodIdx;
}

/// A class that helps with structuring related [Level], [TrainingPeriod], and
/// [Training] without needing to use `Map<String, dynamic>`.
class ProgressDataSlice {
  const ProgressDataSlice({
    required this.level,
    required this.period,
    required this.training,
  });

  final Level level;
  final TrainingPeriod period;
  final Training training;
}

/// The model for how progress is structured and tracked.
class ProgressData {
  ProgressData({
    required this.habitPlanId,
    required this.isActive,
    required this.fullyCompleted,
    required this.currentStartingDate,
    required this.habit,
    required this.levels,
  });

  /// Creates dummy, inactive [ProgressData].
  ProgressData.emptyData()
      : habitPlanId = 123456789,
        isActive = false,
        fullyCompleted = false,
        currentStartingDate = DateTime(0),
        habit = '',
        levels = <Level>[];

  /// Creates a new [ProgressData], according to the [HabitPlan].
  ProgressData.fromHabitPlan({
    required final HabitPlan habitPlan,
    required final DateTime startingDate,
    final int startingLevelNr = 1,
  })  : habitPlanId = habitPlan.id!,
        isActive = true,
        fullyCompleted = habitPlan.fullyCompleted,
        currentStartingDate = startingDate,
        habit = habitPlan.habit,
        levels = <Level>[] {
    for (int i = 0; i < habitPlan.levels.length; i++) {
      levels.add(
        Level.fromHabitPlan(
          levelIndex: i,
          habitPlan: habitPlan,
          save: save,
        ),
      );
    }

    final int startingLevelIdx = startingLevelNr - 1;
    levels[startingLevelIdx].trainingPeriods[0].status = 'waiting for start';

    final PeriodPosition startingPosition = PeriodPosition(
      levelIdx: startingLevelIdx,
      periodIdx: 0,
    );
    _setTrainingDates(startingPosition);

    if (startingLevelNr > 0) {
      // Set the passed trainings' status to 'completed'
      _completePassedPeriods();
    }
  }

  /// Converts a Map into [ProgressData].
  ProgressData.fromMap(final Map<String, dynamic> map)
      : habitPlanId = map['habitPlanId'] as int,
        isActive = (map['isActive'] as int).toBool(),
        fullyCompleted = (map['fullyCompleted'] as int).toBool(),
        currentStartingDate =
            DateTime.parse(map['currentStartingDate'] as String),
        habit = map['habit'] as String {
    levels = _jsonToLevelList(map['levels'] as String, save);
  }

  int habitPlanId;
  bool isActive;
  bool fullyCompleted;
  DateTime currentStartingDate;
  String habit;
  late List<Level> levels;

  /// Saves the current progressData in the [Database].
  Future<void> save() async {
    await DatabaseHelper.instance.updateProgressData(this);
  }

  /// Converts a [json]-like [String] into a list of [Level].
  static List<Level> _jsonToLevelList(
    final String json,
    final Future<void> Function() save,
  ) {
    final dynamic dynamicList = jsonDecode(json);
    final List<Level> levels = <Level>[];

    for (final Map<String, dynamic> map in dynamicList) {
      final Level level = Level.fromMap(map, save);
      levels.add(level);
    }

    return levels;
  }

  // Regularly used functions

  /// Reverse-engeneers the [trainingTimeIndex] of the [HabitPlan] that was used
  /// to create this [ProgressData].
  int get trainingTimeIndex {
    final int nrOfTrainings = levels[0].trainingPeriods[0].trainings.length;
    return DataShortcut.maxTrainings.indexOf(nrOfTrainings);
  }

  /// Checks whether [this] has started or if it still is waiting
  /// for the [currentStartingDate] to arrive.
  bool get _hasStarted {
    final DateTime now = TimeHelper.instance.currentTime;
    final bool hasStarted = now.isAfter(currentStartingDate);
    return hasStarted;
  }

  /// Returns how many hours a [Level] lasts.
  int get levelDurationInHours {
    final int duration = levels[0].durationInHours;
    return duration;
  }

  /// Returns how many hours a [TrainingPeriod] lasts.
  int get trainingPeriodDurationInHours {
    final int duration = levels[0].trainingPeriods[0].durationInHours;
    return duration;
  }

  /// Returns how many hours a [Training] lasts.
  int get trainingDurationInHours {
    final int duration =
        levels[0].trainingPeriods[0].trainings[0].durationInHours;
    return duration;
  }

  /// Returns how many [Training]s there are in each [TrainingPeriod].
  int get trainingsPerPeriod {
    final int trainingCount = levels[0].trainingPeriods[0].trainings.length;
    return trainingCount;
  }

  /// Returns whether we're in a different [Training] than when we last checked.
  bool get _inNewTraining {
    final bool inNewTraining;

    final ProgressDataSlice? activeSlice = activeDataSlice;
    if (activeSlice == null) {
      inNewTraining = true;
    } else {
      final DateTime now = TimeHelper.instance.currentTime;
      final ProgressDataSlice? currentSlice = getDataSliceByDate(now);
      if (currentSlice != null) {
        final Training activeTraining = activeSlice.training;
        final Training currentTraining = currentSlice.training;

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

  /// Returns how many [TrainingPeriod]s have gone by since last
  /// opening the app.
  int _getPassedTrainingPeriods({
    required final DateTime startingDate,
    required final DateTime endingDate,
  }) {
    final int passedHours = endingDate.difference(startingDate).inHours;
    final int passedPeriods =
        (passedHours / trainingPeriodDurationInHours).floor();

    return passedPeriods;
  }

  /// Returns the [Level], the [TrainingPeriod], and the [Training]
  /// that currently are active.
  ProgressDataSlice? get activeDataSlice {
    for (final Level level in levels) {
      final ProgressDataSlice? activeSlice = level.activeDataSlice;
      if (activeSlice != null) {
        return activeSlice;
      }
    }
    return null;
  }

  /// Returns the [Level], the [TrainingPeriod], and the [Training]
  /// that will start the whole training-process off.
  ProgressDataSlice? get waitingDataSlice {
    for (final Level level in levels) {
      final ProgressDataSlice? tempResult = level.waitingDataSlice;
      if (tempResult != null) {
        return tempResult;
      }
    }
    return null;
  }

  /// Performs the initial activation of the starting [TrainingPeriod].
  void _activateStartingPeriod() {
    for (final Level level in levels) {
      level.activateWaitingPeriod();
    }
  }

  /// Moves the [currentStartingDate] so that it is the
  /// starting Date for the current [TrainingPeriod].
  void _setNewStartingDate() {
    final DateTime now = TimeHelper.instance.currentTime;
    final Duration periodDuration =
        Duration(hours: trainingPeriodDurationInHours);

    while ((currentStartingDate.add(periodDuration)).isBefore(now)) {
      print('Moved date one trainingPeriod.');
      currentStartingDate = currentStartingDate.add(periodDuration);
    }
  }

  /// This (re-)sets the dates for all trainings,
  /// the first one starting at [currentStartingDate].
  ///
  /// Define [startingPeriodPosition] to start at a specified trainingPeriod.
  /// Without any arguments, all trainings will be re-dated.
  void _setTrainingDates([
    final PeriodPosition startingPeriodPosition = const PeriodPosition(
      levelIdx: 0,
      periodIdx: 0,
    ),
  ]) {
    final int startingLevelIdx = startingPeriodPosition.levelIdx;
    final int startingPeriodIdx = startingPeriodPosition.periodIdx;

    // Set dates for all the trainings
    DateTime workingDate = currentStartingDate;

    for (int i = startingLevelIdx; i < levels.length; i++) {
      final Level level = levels[i];

      if (i == startingLevelIdx) {
        workingDate = level.setChildrenDates(workingDate, startingPeriodIdx);
      } else {
        workingDate = level.setChildrenDates(workingDate, 0);
      }
    }
  }

  /// Marks all [TrainingPeriod]s that have passed as being passed.
  ///
  /// Necessary if the user starts with something else than level 1.
  void _completePassedPeriods() {
    for (final Level level in levels) {
      level.markPassedPeriods();
    }
  }

  /// Returns the [Level], the [TrainingPeriod], and the [Training]
  /// that aling with on specific [date].
  ProgressDataSlice? getDataSliceByDate(final DateTime date) {
    ProgressDataSlice? result;
    for (final Level level in levels) {
      result = level.getDataSliceByDate(date);
      if (result != null) {
        return result;
      }
    }
    return null;
  }

  /// Resets a number of [TrainingPeriod]s ([remainingRegressions],
  /// derived from [failedPeriods]).
  ///
  /// Returns the position of the new current [TrainingPeriod].
  PeriodPosition _penalizeFailure(
    final int failedPeriods,
    final ProgressDataSlice lastActiveSlice,
  ) {
    final int previouslyActivePeriodIdx = lastActiveSlice.period.index;

    int currentLevelIdx = lastActiveSlice.level.index;

    // Always reset one additional period
    // to make sure we actually move backwards in time.
    int remainingRegressions = failedPeriods + 1;

    while (true) {
      final Level currentLevel = levels[currentLevelIdx];
      remainingRegressions = currentLevel.regressPeriods(remainingRegressions);

      if (remainingRegressions > 0 && currentLevelIdx > 0) {
        // If there are more loops to come AND
        // we haven't reached the start of all challenges: Repeat cycle.
        currentLevelIdx--;
      } else {
        // If this was the last loop,
        // return the current trainingPeriod's position.
        final int newCurrentLevelIdx = currentLevelIdx;
        final int newCurrentPeriodIdx;
        if (previouslyActivePeriodIdx == 0) {
          newCurrentPeriodIdx = 0;
        } else {
          newCurrentPeriodIdx = previouslyActivePeriodIdx - failedPeriods;
        }

        final PeriodPosition newCurrentPosition = PeriodPosition(
          levelIdx: newCurrentLevelIdx,
          periodIdx: newCurrentPeriodIdx,
        );
        return newCurrentPosition;
      }
    }
  }

  /// Marks the [HabitPlan] that constructed this [ProgressData]
  /// as having been completed.
  Future<void> _completeHabitPlan() async {
    final HabitPlan? habitPlan =
        await DatabaseHelper.instance.getHabitPlan(habitPlanId);

    if (habitPlan != null) {
      habitPlan.fullyCompleted = true;
      await habitPlan.save();
    }
  }

  /// Analyzes the amount of time that has passed since last time opening
  /// the app. Then adapts [ProgressData] accordingly.
  void _adaptToPassedTime() {
    final ProgressDataSlice lastActiveSlice = activeDataSlice!;

    // Analyze the last training
    final Training lastActiveTraining = lastActiveSlice.training;
    lastActiveTraining.setResult();

    // Analyze the passed trainingPeriods
    // Calculate the number of trainingPeriods passed.
    // For dayly trainings, that would be how many weeks have passed.
    final DateTime now = TimeHelper.instance.currentTime;
    final int passedTrainingPeriods = _getPassedTrainingPeriods(
      startingDate: currentStartingDate,
      endingDate: now,
    );

    if (passedTrainingPeriods >= 1) {
      // Analyze the trainingPeriod that was last active
      final TrainingPeriod lastActivePeriod = lastActiveSlice.period;

      // Get the number of failed trainigPeriods
      int failedPeriods = passedTrainingPeriods;
      if (lastActivePeriod.wasSuccessful) {
        print('WAS SUCCESSFUL!!!!!!!!!!');
        lastActivePeriod.status = 'completed';
        failedPeriods -= 2;
      }

      print('failedPeriods: $failedPeriods');
      _setNewStartingDate();

      final TrainingPeriod lastPeriod = levels.last.trainingPeriods.last;

      // This happens whenever the last training-period of the last level is
      // completed.
      if (lastActivePeriod.wasSuccessful && lastActivePeriod == lastPeriod) {
        fullyCompleted = true;
        _completeHabitPlan();
      }

      if (failedPeriods >= 0 || lastActivePeriod == lastPeriod) {
        final PeriodPosition nextPeriodPosition;
        nextPeriodPosition = _penalizeFailure(failedPeriods, lastActiveSlice);
        _setTrainingDates(nextPeriodPosition);
      }
    }
  }

  /// Activate the next [Training] & [TrainingPeriod].
  void _activateCurrentTraining() {
    final DateTime now = TimeHelper.instance.currentTime;
    final ProgressDataSlice currentSlice = getDataSliceByDate(now)!;

    final Training currentTraining = currentSlice.training;
    currentTraining.status = 'ready';

    final TrainingPeriod currentPeriod = currentSlice.period;
    currentPeriod.status = 'active';
  }

  /// Checks how much time has passed since the last activity and
  /// adapts [ProgressData] (and the database) accordingly.
  Future<bool> updateSelf() async {
    final bool somethingChanged;

    if (_hasStarted && _inNewTraining) {
      somethingChanged = true;

      if (activeDataSlice == null) {
        // If this is the first training we ever arrive in.
        // Necessary for _analyzePassedTime(); to not crash.
        _activateStartingPeriod();
      }

      // Analyze what happened since last time opening the app
      _adaptToPassedTime();

      // Activate the next Training/TrainingPeriod
      _activateCurrentTraining();

      // Save all changes
      await save();
    } else {
      somethingChanged = false;
    }

    return somethingChanged;
  }

  // Functions for interacting with the database

  /// Converts [this] into a Map.
  Map<String, dynamic> toMap() {
    final List<Map<String, dynamic>> levelMapList = <Map<String, dynamic>>[];

    for (final Level level in levels) {
      levelMapList.add(level.toMap());
    }

    final Map<String, dynamic> map = <String, dynamic>{
      'habitPlanId': habitPlanId,
      'isActive': isActive.toInt(),
      'fullyCompleted': fullyCompleted.toInt(),
      'currentStartingDate': currentStartingDate.toString(),
      'habit': habit,
      'levels': jsonEncode(levelMapList),
    };
    return map;
  }
}
