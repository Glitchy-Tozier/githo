import 'dart:convert';

import 'package:githo/extracted_data/dataShortcut.dart';
import 'package:githo/extracted_data/fullDatabaseImport.dart';
import 'package:githo/extracted_functions/typeExtentions.dart';
import 'package:githo/models/used_classes/training.dart';

class TrainingPeriod {
  late int number;
  late int durationInHours;
  late String durationText;
  late int requiredTrainings;
  String status = "";
  late List<Training> trainings;

  TrainingPeriod({
    required int trainingPeriodIndex,
    required HabitPlan habitPlan,
  }) {
    this.number = trainingPeriodIndex + 1;

    // Calculate the duration
    final int trainingTimeIndex = habitPlan.trainingTimeIndex;
    this.durationInHours =
        DataShortcut.periodDurationInHours[trainingTimeIndex];
    this.durationText =
        DataShortcut.timeFrames[trainingTimeIndex + 1].capitalize();

    // Get required trainings
    this.requiredTrainings = habitPlan.requiredTrainings;

    // Create all the TrainingPeriod-instances
    final int trainingCount = DataShortcut.maxTrainings[trainingTimeIndex];
    this.trainings = [];
    for (int i = 0; i < trainingCount; i++) {
      final int trainingIndex = trainingPeriodIndex * trainingCount + i;
      this.trainings.add(
            Training(
              trainingIndex: trainingIndex,
              habitPlan: habitPlan,
            ),
          );
    }
  }

  TrainingPeriod.withDirectValues({
    required this.number,
    required this.durationInHours,
    required this.durationText,
    required this.requiredTrainings,
    required this.status,
    required this.trainings,
  });

  void setChildrenDates(DateTime startingDate) {
    for (final training in this.trainings) {
      training.setDates(startingDate);
      startingDate =
          startingDate.add(Duration(hours: training.durationInHours));
    }
  }

  Map<String, dynamic>? getDataByDate(DateTime date) {
    Map<String, dynamic>? result;

    for (final training in this.trainings) {
      if ((training.startingDate.isAtSameMomentAs(date) ||
              training.startingDate.isBefore(date)) &&
          training.endingDate.isAfter(date)) {
        result = Map<String, dynamic>();
        result["training"] = training;
        result["trainingPeriod"] = this;
        break;
      }
    }
    return result;
  }

  void resetTrainingProgresses(int startingNumber) {
    for (final Training training in this.trainings) {
      if (training.number >= startingNumber) {
        training.status = "";
        training.doneReps = 0;
      }
    }
  }

  Map<String, dynamic>? getActiveData() {
    Map<String, dynamic>? result;

    for (final training in this.trainings) {
      if (training.status == "current" ||
          training.status == "active" ||
          training.status == "done") {
        result = Map<String, dynamic>();
        result["training"] = training;
        result["trainingPeriod"] = this;
        break;
      }
    }
    return result;
  }

  bool wasSuccessful() {
    final bool result;
    int successfulTrainings = 0;

    this.trainings.forEach((Training training) {
      if (training.doneReps == training.requiredReps) {
        successfulTrainings++;
      }
    });
    result = (successfulTrainings >= requiredTrainings);
    return result;
  }

  void validate() {
    if (wasSuccessful()) {
      this.status = "successful";
    } else {
      this.status = "unsuccessful";
    }
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};
    List<Map<String, dynamic>> mapList = [];

    for (int i = 0; i < this.trainings.length; i++) {
      mapList.add(this.trainings[i].toMap());
    }

    map["number"] = this.number;
    map["durationInHours"] = this.durationInHours;
    map["durationText"] = this.durationText;
    map["requiredTrainings"] = this.requiredTrainings;
    map["status"] = this.status;
    map["trainings"] = jsonEncode(mapList);
    return map;
  }

  factory TrainingPeriod.fromMap(Map<String, dynamic> map) {
    List<Training> jsonToList(String json) {
      List<dynamic> dynamicList = jsonDecode(json);
      List<Training> stepList = [];

      for (final dynamic periodMap in dynamicList) {
        stepList.add(Training.fromMap(periodMap));
      }

      return stepList;
    }

    return TrainingPeriod.withDirectValues(
      number: map["number"],
      durationInHours: map["durationInHours"],
      durationText: map["durationText"],
      requiredTrainings: map["requiredTrainings"],
      status: map["status"],
      trainings: jsonToList(map["trainings"]),
    );
  }
}
