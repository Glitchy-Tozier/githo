import 'dart:convert';

import 'package:githo/extracted_data/dataShortcut.dart';
import 'package:githo/models/habitPlanModel.dart';
import 'package:githo/models/used_classes/trainingPeriod.dart';

class StepClass {
  late int number;
  late String text;
  late int durationInHours;
  late List<TrainingPeriod> trainingPeriods;

  StepClass({required int stepIndex, required HabitPlan habitPlan}) {
    this.number = stepIndex + 1;
    this.text = habitPlan.steps[stepIndex];

    // Calculate the duration
    final int trainingPeriodCount = habitPlan.requiredTrainingPeriods;
    final int trainingPeriodHours =
        DataShortcut.periodDurationInHours[habitPlan.trainingTimeIndex];
    final int stepHours = trainingPeriodHours * trainingPeriodCount;
    this.durationInHours = stepHours;

    // Create all the TrainingPeriod-instances
    this.trainingPeriods = [];
    for (int i = 0; i < habitPlan.requiredTrainingPeriods; i++) {
      final int trainingPeriodIndex = stepIndex * trainingPeriodCount + i;
      this.trainingPeriods.add(
            TrainingPeriod(
              trainingPeriodIndex: trainingPeriodIndex,
              habitPlan: habitPlan,
            ),
          );
    }
  }
  StepClass.withDirectValues({
    required this.number,
    required this.text,
    required this.durationInHours,
    required this.trainingPeriods,
  });

  void setChildrenDates(DateTime startingDate) {
    for (final TrainingPeriod trainingPeriod in this.trainingPeriods) {
      trainingPeriod.setChildrenDates(startingDate);
      startingDate =
          startingDate.add(Duration(hours: trainingPeriod.durationInHours));
    }
  }

  Map<String, dynamic>? getDataByDate(DateTime date) {
    Map<String, dynamic>? map;
    for (final trainingPeriod in this.trainingPeriods) {
      map = trainingPeriod.getDataByDate(date);
      if (map != null) {
        map["step"] = this;
        break;
      }
    }
    return map;
  }

  void resetChildrenProgresses(int startingNumber) {
    for (final TrainingPeriod trainingPeriod in this.trainingPeriods) {
      trainingPeriod.resetTrainingProgresses(startingNumber);
    }
  }

  Map<String, dynamic>? getActiveData() {
    Map<String, dynamic>? result;
    for (final trainingPeriod in this.trainingPeriods) {
      if (trainingPeriod.status == "active") {
        Map<String, dynamic>? map = trainingPeriod.getActiveData();
        if (map != null) {
          result = map;
          result["step"] = this;
          break;
        }
      }
    }
    return result;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};
    List<Map<String, dynamic>> mapList = [];

    for (int i = 0; i < this.trainingPeriods.length; i++) {
      mapList.add(this.trainingPeriods[i].toMap());
    }

    map["number"] = this.number;
    map["text"] = this.text;
    map["durationInHours"] = this.durationInHours;
    map["trainingPeriods"] = jsonEncode(mapList);
    return map;
  }

  factory StepClass.fromMap(Map<String, dynamic> map) {
    List<TrainingPeriod> jsonToList(String json) {
      List<dynamic> dynamicList = jsonDecode(json);
      List<TrainingPeriod> stepList = [];

      for (final dynamic periodMap in dynamicList) {
        stepList.add(TrainingPeriod.fromMap(periodMap));
      }

      return stepList;
    }

    return StepClass.withDirectValues(
      number: map["number"],
      text: map["text"],
      durationInHours: map["durationInHours"],
      trainingPeriods: jsonToList(map["trainingPeriods"]),
    );
  }
}
