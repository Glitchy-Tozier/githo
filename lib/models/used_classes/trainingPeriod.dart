import 'dart:convert';

import 'package:githo/extracted_data/dataShortcut.dart';
import 'package:githo/extracted_data/fullDatabaseImport.dart';
import 'package:githo/models/used_classes/training.dart';

class TrainingPeriod {
  late int number;
  late int durationInHours;
  late int requiredTrainings;
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
    required this.requiredTrainings,
    required this.trainings,
  });

  void setChildrenDates(DateTime startingDate) {
    for (final training in this.trainings) {
      training.startingDate = startingDate;
      startingDate.add(Duration(hours: training.durationInHours));
    }
  }

  Training? getActiveTraining() {
    for (final Training training in this.trainings) {
      if ((training.status == "active") || (training.status == "done")) {
        return training;
      }
    }
  }

  Training? getTrainingByDate(date) {
    for (final Training training in this.trainings) {
      if (training.startingDate.isBefore(date) &&
          training.endingDate.isAfter(date)) {
        return training;
      }
    }
  }

  void resetTrainingProgresses(int startingNumber) {
    for (final Training training in this.trainings) {
      if (training.number >= startingNumber) {
        training.status = "";
        training.doneReps = 0;
      }
    }
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

  Map<String, dynamic>? getActiveData() {
    Map<String, dynamic>? result;

    for (final training in this.trainings) {
      if (training.status == "active" || training.status == "done") {
        result = Map<String, dynamic>();
        result["training"] = training;
        result["trainingPeriod"] = this;
        break;
      }
    }
    return result;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};
    List<Map<String, dynamic>> mapList = [];

    for (int i = 0; i < this.trainings.length; i++) {
      mapList.add(this.trainings[i].toMap());
    }

    map["number"] = this.number;
    map["durationInHours"] = this.durationInHours;
    map["requiredTrainings"] = this.requiredTrainings;
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
      requiredTrainings: map["requiredTrainings"],
      trainings: jsonToList(map["trainings"]),
    );
  }
}
