import 'dart:convert';

import 'package:githo/extracted_data/dataShortcut.dart';
import 'package:githo/extracted_data/fullDatabaseImport.dart';
import 'package:githo/helpers/timeHelper.dart';
import 'package:githo/models/used_classes/training.dart';

class TrainingPeriod {
  late int index;
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
            Training(
              trainingIndex: trainingIndex,
              habitPlan: habitPlan,
            ),
          );
    }
  }

  TrainingPeriod.withDirectValues({
    required this.index,
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

  void activate() {
    this.status = "active";
    this.trainings[0].status = "active";
  }

  void reset() {
    // Reset self
    this.status = "";

    // Reset trainings
    for (final Training training in this.trainings) {
      training.reset();
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

  int get successfulTrainings {
    // This also counts the current day!!
    int successfulTrainings = 0;

    for (final Training training in this.trainings) {
      if (training.status == "successful" || training.status == "done") {
        successfulTrainings++;
      }
    }
    return successfulTrainings;
  }

  int get remainingTrainings {
    int remainingTrainings = 0;
    for (final Training training in this.trainings) {
      if (training.endingDate.isAfter(TimeHelper.instance.getTime)) {
        remainingTrainings++;
      }
    }
    return remainingTrainings;
  }

  void setResult() {
    this.status = "completed";
  }

  Map<String, dynamic> toMap() {
    final List<Map<String, dynamic>> trainingMapList = [];

    for (int i = 0; i < this.trainings.length; i++) {
      trainingMapList.add(this.trainings[i].toMap());
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

  factory TrainingPeriod.fromMap(Map<String, dynamic> map) {
    List<Training> jsonToList(String json) {
      final List<dynamic> dynamicList = jsonDecode(json);
      final List<Training> stepList = [];

      for (final dynamic periodMap in dynamicList) {
        stepList.add(Training.fromMap(periodMap));
      }

      return stepList;
    }

    return TrainingPeriod.withDirectValues(
      index: map["index"],
      number: map["number"],
      durationInHours: map["durationInHours"],
      durationText: map["durationText"],
      requiredTrainings: map["requiredTrainings"],
      status: map["status"],
      trainings: jsonToList(map["trainings"]),
    );
  }
}
