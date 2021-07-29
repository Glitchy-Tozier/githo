import 'dart:convert';

import 'package:githo/extracted_data/dataShortcut.dart';
import 'package:githo/helpers/timeHelper.dart';
import 'package:githo/models/habitPlanModel.dart';
import 'package:githo/models/used_classes/trainingPeriod.dart';

class StepClass {
  late int index;
  late int number; // = index + 1
  late String text;
  late int durationInHours;
  late List<TrainingPeriod> trainingPeriods;

  StepClass({required int stepIndex, required HabitPlan habitPlan}) {
    this.index = stepIndex;
    this.number = stepIndex + 1;
    this.text = habitPlan.steps[stepIndex];

    // Calculate the duration
    final int trainingPeriodCount = habitPlan.requiredTrainingPeriods;
    final int trainingPeriodHours =
        DataShortcut.periodDurationInHours[habitPlan.trainingTimeIndex];
    final int stepHours = trainingPeriodHours * trainingPeriodCount;
    this.durationInHours = stepHours;

    // Create all the TrainingPeriod-instances
    this.trainingPeriods = <TrainingPeriod>[];
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
    required this.index,
    required this.number,
    required this.text,
    required this.durationInHours,
    required this.trainingPeriods,
  });

  bool get isActive {
    final DateTime now = TimeHelper.instance.getTime;
    final Map<String, dynamic>? activeMap = getDataByDate(now);

    if (activeMap == null) {
      return false;
    } else {
      return true;
    }
  }

  String get status {
    int completedCount = 0;
    for (final TrainingPeriod trainingPeriod in this.trainingPeriods) {
      if (trainingPeriod.status == "completed") {
        completedCount++;
      } else if (trainingPeriod.status == "active") {
        return "active";
      }
    }
    if (completedCount == this.trainingPeriods.length) {
      return "completed";
    } else {
      return "locked";
    }
  }

  int? get _activePeriodIndex {
    for (int i = 0; i < this.trainingPeriods.length; i++) {
      final TrainingPeriod trainingPeriod = this.trainingPeriods[i];
      if (trainingPeriod.status == "active") {
        return i;
      }
    }
    return this.trainingPeriods.length - 1;
  }

  int regressPeriods(int periodRegressionCount) {
    int activePeriodIndex = this._activePeriodIndex!;

    while (periodRegressionCount > 0) {
      this.trainingPeriods[activePeriodIndex].reset();
      if (activePeriodIndex == 0) {
        return periodRegressionCount - 1;
      } else {
        activePeriodIndex--;
        periodRegressionCount--;
      }
    }
    return 0;
  }

  DateTime setChildrenDates(
    DateTime startingDate,
    final int startingPeriodIdx,
  ) {
    final startingPeriodListIdx =
        startingPeriodIdx.remainder(this.trainingPeriods.length);

    for (int i = startingPeriodListIdx; i < this.trainingPeriods.length; i++) {
      final TrainingPeriod trainingPeriod = this.trainingPeriods[i];

      trainingPeriod.setChildrenDates(startingDate);
      startingDate =
          startingDate.add(Duration(hours: trainingPeriod.durationInHours));
    }
    return startingDate;
  }

  Map<String, dynamic>? getDataByDate(final DateTime date) {
    Map<String, dynamic>? map;
    for (final TrainingPeriod trainingPeriod in this.trainingPeriods) {
      map = trainingPeriod.getDataByDate(date);
      if (map != null) {
        map["step"] = this;
        break;
      }
    }
    return map;
  }

  void resetChildrenProgresses(final int startingNumber) {
    for (final TrainingPeriod trainingPeriod in this.trainingPeriods) {
      trainingPeriod.resetTrainingProgresses(startingNumber);
    }
  }

  Map<String, dynamic>? get activeData {
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

  Map<String, dynamic>? get waitingData {
    for (final TrainingPeriod trainingPeriod in this.trainingPeriods) {
      if (trainingPeriod.status == "waiting for start") {
        final Map<String, dynamic> result = {};
        result["step"] = this;
        result["trainingPeriod"] = trainingPeriod;
        result["training"] = trainingPeriod.trainings[0];
        return result;
      }
    }
  }

  void markPassedPeriods() {
    for (final TrainingPeriod trainingPeriod in this.trainingPeriods) {
      trainingPeriod.markIfPassed();
    }
  }

  void activateStartingPeriod() {
    for (final TrainingPeriod trainingPeriod in this.trainingPeriods) {
      if (trainingPeriod.status == "waiting for start") {
        trainingPeriod.activate();
      }
    }
  }

  Map<String, dynamic> toMap() {
    final List<Map<String, dynamic>> trainingPeriodList = [];
    for (int i = 0; i < this.trainingPeriods.length; i++) {
      trainingPeriodList.add(this.trainingPeriods[i].toMap());
    }

    final Map<String, dynamic> map = {};
    map["index"] = this.index;
    map["number"] = this.number;
    map["text"] = this.text;
    map["durationInHours"] = this.durationInHours;
    map["trainingPeriods"] = jsonEncode(trainingPeriodList);
    return map;
  }

  factory StepClass.fromMap(Map<String, dynamic> map) {
    List<TrainingPeriod> jsonToList(final String json) {
      final List<dynamic> dynamicList = jsonDecode(json);
      final List<TrainingPeriod> stepList = [];

      for (final dynamic periodMap in dynamicList) {
        stepList.add(TrainingPeriod.fromMap(periodMap));
      }

      return stepList;
    }

    return StepClass.withDirectValues(
      index: map["index"],
      number: map["number"],
      text: map["text"],
      durationInHours: map["durationInHours"],
      trainingPeriods: jsonToList(map["trainingPeriods"]),
    );
  }
}
