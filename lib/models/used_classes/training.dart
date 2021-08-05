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

import 'package:githo/extracted_data/dataShortcut.dart';
import 'package:githo/helpers/timeHelper.dart';
import 'package:githo/models/habitPlanModel.dart';

class Training {
  late int number;
  late int durationInHours;
  int doneReps = 0;
  late int requiredReps;
  DateTime startingDate = DateTime(135);
  DateTime endingDate = DateTime(246);
  String status = "";

  Training.fromHabitPlan(
      {required int trainingIndex, required HabitPlan habitPlan}) {
    this.number = trainingIndex + 1;

    final int trainingTimeIndex = habitPlan.trainingTimeIndex;
    this.durationInHours =
        DataShortcut.trainingDurationInHours[trainingTimeIndex];

    this.requiredReps = habitPlan.requiredReps;
  }

  Training({
    required this.number,
    required this.durationInHours,
    required this.doneReps,
    required this.requiredReps,
    required this.startingDate,
    required this.endingDate,
    required this.status,
  });

  bool get isNow {
    final DateTime now = TimeHelper.instance.currentTime;
    if (now.isAfter(this.startingDate) && now.isBefore(this.endingDate))
      return true;
    else
      return false;
  }

  bool get hasPassed {
    final DateTime now = TimeHelper.instance.currentTime;
    if (now.isAfter(this.endingDate))
      return true;
    else
      return false;
  }

  void setDates(final DateTime startingDate) {
    this.startingDate = startingDate;
    this.endingDate = startingDate.add(
      Duration(hours: this.durationInHours),
    );
  }

  void incrementReps() {
    this.doneReps++;
    if (this.doneReps >= this.requiredReps) {
      this.status = "done";
    }
  }

  void activate() {
    if (this.status == "current") {
      this.status = "active";
    }
  }

  void reset() {
    this.doneReps = 0;
    this.status = "";
  }

  void setResult() {
    if (this.status == "current") {
      // If the training never was started
      this.status = "ignored";
    } else if (this.status == "active") {
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

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};

    map["number"] = this.number;
    map["durationInHours"] = this.durationInHours;
    map["doneReps"] = this.doneReps;
    map["requiredReps"] = this.requiredReps;
    map["startingDate"] = this.startingDate.toString();
    map["endingDate"] = this.endingDate.toString();
    map["status"] = this.status;
    return map;
  }

  factory Training.fromMap(Map<String, dynamic> map) {
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
