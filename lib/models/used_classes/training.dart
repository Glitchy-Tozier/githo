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

import 'package:githo/config/data_shortcut.dart';
import 'package:githo/helpers/time_helper.dart';
import 'package:githo/models/habit_plan.dart';

/// One instance of you performing your habit.
///
/// Example: For daily habits, this would be a day.

class Training {
  /// Creates a [Training] by directly supplying its values.
  Training({
    required this.number,
    required this.durationInHours,
    required this.requiredReps,
    required this.doneReps,
    required this.startingDate,
    required this.endingDate,
    required this.status,
    required this.save,
  });

  /// Creates a [Training] from a [HabitPlan].
  Training.fromHabitPlan({
    required final int trainingIndex,
    required final HabitPlan habitPlan,
    required this.save,
  })  : number = trainingIndex + 1,
        durationInHours =
            DataShortcut.trainingDurationInHours[habitPlan.trainingTimeIndex],
        requiredReps = habitPlan.requiredReps;

  /// Converts a Map into a [Training].
  Training.fromMap(final Map<String, dynamic> map, this.save)
      : number = map['number'] as int,
        durationInHours = map['durationInHours'] as int,
        requiredReps = map['requiredReps'] as int,
        doneReps = map['doneReps'] as int,
        startingDate = DateTime.parse(map['startingDate'] as String),
        endingDate = DateTime.parse(map['endingDate'] as String),
        status = map['status'] as String;

  final int number;
  final int durationInHours;
  final int requiredReps;
  int doneReps = 0;
  DateTime startingDate = DateTime(135);
  DateTime endingDate = DateTime(246);
  String status = '';
  final Future<void> Function() save;

  /// Checks whether the training is active.
  bool get isActive {
    final bool isActive =
        status == 'ready' || status == 'started' || status == 'done';
    return isActive;
  }

  /// Checks whether the training aligns with the current [DateTime].
  bool get isNow {
    final DateTime now = TimeHelper.instance.currentTime;
    if (now.isAfter(startingDate) && now.isBefore(endingDate)) {
      return true;
    } else {
      return false;
    }
  }

  /// Checks whether the time-period for training has passed.
  bool get hasPassed {
    final DateTime now = TimeHelper.instance.currentTime;
    if (now.isAfter(endingDate)) {
      return true;
    } else {
      return false;
    }
  }

  /// Sets [this.startingDate] and [this.endingDate] for the training.
  Future<void> setDates(final DateTime startingDate) async {
    this.startingDate = startingDate;
    endingDate = startingDate.add(
      Duration(hours: durationInHours),
    );
    await save();
  }

  /// Increments the [doneReps] by 1.
  /// Then, if the trainig is successful, set its [status] it accordingly.
  Future<void> incrementReps() async {
    doneReps++;
    if (doneReps >= requiredReps && status == 'started') {
      status = 'done';
    }
    await save();
  }

  /// Reduces [doneReps] by 1, if it's value is not already 0.
  /// Then, if the trainig was successful but now isn't anymore,
  /// set its [status] accordingly.
  Future<void> decrementReps() async {
    if (doneReps > 0) {
      doneReps--;
    }
    if (doneReps < requiredReps && status == 'done') {
      status = 'started';
    }
    await save();
  }

  /// Activates the training
  Future<void> activate() async {
    if (status == 'ready') status = 'started';
    await save();
  }

  /// Resets the progress ([doneReps]) and the [status] of the training.
  Future<void> reset() async {
    doneReps = 0;
    status = '';
    await save();
  }

  /// Check the outcome of the (passed) training and mark it accordingly.
  Future<void> setResult() async {
    if (status == 'ready') {
      // If the training never was started
      status = 'ignored';
    } else if (status == 'started') {
      // If the training was started but never successfully finished
      status = 'unsuccessful';
    } else if (status == 'done') {
      // If the training was finished in time
      status = 'successful';
    } else {
      throw 'Unknown Status: $status';
    }
    await save();
  }

  /// Converts the [Training] into a Map.
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = <String, dynamic>{
      'number': number,
      'durationInHours': durationInHours,
      'requiredReps': requiredReps,
      'doneReps': doneReps,
      'startingDate': startingDate.toString(),
      'endingDate': endingDate.toString(),
      'status': status,
    };
    return map;
  }
}
