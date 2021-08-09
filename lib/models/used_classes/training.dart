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

import 'package:githo/config/dataShortcut.dart';
import 'package:githo/helpers/timeHelper.dart';
import 'package:githo/models/habitPlanModel.dart';

/// One instance of you performing your habit.
///
/// Example: For daily habits, this would be a day.

class Training {
  late int number;
  late int durationInHours;
  int doneReps = 0;
  late int requiredReps;
  DateTime startingDate = DateTime(135);
  DateTime endingDate = DateTime(246);
  String status = "";

  /// Creates a [Training] from a [HabitPlan].
  Training.fromHabitPlan(
      {required int trainingIndex, required HabitPlan habitPlan}) {
    this.number = trainingIndex + 1;

    final int trainingTimeIndex = habitPlan.trainingTimeIndex;
    this.durationInHours =
        DataShortcut.trainingDurationInHours[trainingTimeIndex];

    this.requiredReps = habitPlan.requiredReps;
  }

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

  /// Checks whether the training is active.
  bool get isActive {
    final bool isActive = this.status == "ready" ||
        this.status == "started" ||
        this.status == "done";
    return isActive;
  }

  /// Checks whether the training aligns with the current DateTime.
  bool get isNow {
    final DateTime now = TimeHelper.instance.currentTime;
    if (now.isAfter(this.startingDate) && now.isBefore(this.endingDate))
      return true;
    else
      return false;
  }

  /// Checks whether the time-period for training has passed.
  bool get hasPassed {
    final DateTime now = TimeHelper.instance.currentTime;
    if (now.isAfter(this.endingDate))
      return true;
    else
      return false;
  }

  /// Sets [this.startingDate] and [this.endingDate] for the training.
  void setDates(final DateTime startingDate) {
    this.startingDate = startingDate;
    this.endingDate = startingDate.add(
      Duration(hours: this.durationInHours),
    );
  }

  /// Increments the [doneReps] by 1. Then, if the trainig is successful, mark it accordingly.
  void incrementReps() {
    this.doneReps++;
    if (this.doneReps >= this.requiredReps) {
      this.status = "done";
    }
  }

  /// Activates the training
  void activate() {
    this.status = "started";
  }

  /// Resets the progress ([doneReps]) and the [status] of the training.
  void reset() {
    this.doneReps = 0;
    this.status = "";
  }

  /// Check the outcome of the (passed) training and mark it accordingly.
  void setResult() {
    if (this.status == "ready") {
      // If the training never was started
      this.status = "ignored";
    } else if (this.status == "started") {
      // If the training was started but never successfully finished
      this.status = "unsuccessful";
    } else if (this.status == "done") {
      // If the training was finished in time
      this.status = "successful";
    } else {
      print("Unknown Status: ${this.status}");
      throw "Unknown Status: ${this.status}";
    }
  }

  /// Converts the [Training] into a Map.
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {};

    map["number"] = this.number;
    map["durationInHours"] = this.durationInHours;
    map["doneReps"] = this.doneReps;
    map["requiredReps"] = this.requiredReps;
    map["startingDate"] = this.startingDate.toString();
    map["endingDate"] = this.endingDate.toString();
    map["status"] = this.status;
    return map;
  }

  /// Converts a Map into a [Training].
  factory Training.fromMap(final Map<String, dynamic> map) {
    return Training(
      number: map["number"],
      durationInHours: map["durationInHours"],
      doneReps: map["doneReps"],
      requiredReps: map["requiredReps"],
      startingDate: DateTime.parse(map["startingDate"]),
      endingDate: DateTime.parse(map["endingDate"]),
      status: map["status"],
    );
  }
}
