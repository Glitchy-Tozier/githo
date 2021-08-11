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
    required this.doneReps,
    required this.requiredReps,
    required this.startingDate,
    required this.endingDate,
    required this.status,
  });

  /// Creates a [Training] from a [HabitPlan].
  Training.fromHabitPlan(
      {required int trainingIndex, required HabitPlan habitPlan}) {
    number = trainingIndex + 1;

    final int trainingTimeIndex = habitPlan.trainingTimeIndex;
    durationInHours = DataShortcut.trainingDurationInHours[trainingTimeIndex];

    requiredReps = habitPlan.requiredReps;
  }

  /// Converts a Map into a [Training].
  Training.fromMap(final Map<String, dynamic> map) {
    number = map['number'] as int;
    durationInHours = map['durationInHours'] as int;
    doneReps = map['doneReps'] as int;
    requiredReps = map['requiredReps'] as int;
    startingDate = DateTime.parse(map['startingDate'] as String);
    endingDate = DateTime.parse(map['endingDate'] as String);
    status = map['status'] as String;
  }

  late int number;
  late int durationInHours;
  int doneReps = 0;
  late int requiredReps;
  DateTime startingDate = DateTime(135);
  DateTime endingDate = DateTime(246);
  String status = '';

  /// Checks whether the training is active.
  bool get isActive {
    final bool isActive =
        status == 'ready' || status == 'started' || status == 'done';
    return isActive;
  }

  /// Checks whether the training aligns with the current DateTime.
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
  void setDates(final DateTime startingDate) {
    this.startingDate = startingDate;
    endingDate = startingDate.add(
      Duration(hours: durationInHours),
    );
  }

  /// Increments the [doneReps] by 1.
  /// Then, if the trainig is successful, mark it accordingly.
  void incrementReps() {
    doneReps++;
    if (doneReps >= requiredReps) {
      status = 'done';
    }
  }

  /// Activates the training
  void activate() {
    status = 'started';
  }

  /// Resets the progress ([doneReps]) and the [status] of the training.
  void reset() {
    doneReps = 0;
    status = '';
  }

  /// Check the outcome of the (passed) training and mark it accordingly.
  void setResult() {
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
      print('Unknown Status: $status');
      throw 'Unknown Status: $status';
    }
  }

  /// Converts the [Training] into a Map.
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = <String, dynamic>{
      'number': number,
      'durationInHours': durationInHours,
      'doneReps': doneReps,
      'requiredReps': requiredReps,
      'startingDate': startingDate.toString(),
      'endingDate': endingDate.toString(),
      'status': status,
    };
    return map;
  }
}
