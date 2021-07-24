import 'dart:convert';
import 'package:githo/extracted_functions/typeExtentions.dart';

class HabitPlan {
  int? id;
  bool isActive;
  bool fullyCompleted;
  String habit;
  int requiredReps;
  List<String> steps;
  List<String> comments;
  int trainingTimeIndex;
  int requiredTrainings;
  int requiredTrainingPeriods;
  DateTime lastChanged;

  HabitPlan({
    required this.isActive,
    required this.fullyCompleted,
    required this.habit,
    required this.requiredReps,
    required this.steps,
    required this.comments,
    required this.trainingTimeIndex,
    required this.requiredTrainings,
    required this.requiredTrainingPeriods,
    required this.lastChanged,
  });

  HabitPlan.withId({
    required this.id,
    required this.isActive,
    required this.fullyCompleted,
    required this.habit,
    required this.requiredReps,
    required this.steps,
    required this.comments,
    required this.trainingTimeIndex,
    required this.requiredTrainings,
    required this.requiredTrainingPeriods,
    required this.lastChanged,
  });

  Map<String, dynamic> toMap() {
    final map = Map<String, dynamic>();
    if (id != null) {
      map["id"] = id;
    }

    map["isActive"] = isActive.boolToInt();
    map["fullyCompleted"] = fullyCompleted.boolToInt();
    map["goal"] = habit;
    map["requiredReps"] = requiredReps;
    map["steps"] = jsonEncode(steps);
    map["comments"] = jsonEncode(comments);
    map["trainingTimeIndex"] = trainingTimeIndex;
    map["requiredTrainings"] = requiredTrainings;
    map["requiredTrainingPeriods"] = requiredTrainingPeriods;
    map["lastChanged"] = lastChanged.toString();

    return map;
  }

  factory HabitPlan.fromMap(final Map<String, dynamic> map) {
    List<String> jsonToStringList(final String json) {
      final List<dynamic> dynamicList = jsonDecode(json);
      final List<String> stringList = [];

      for (final dynamic element in dynamicList) {
        stringList.add(element);
      }
      return stringList;
    }

    return HabitPlan.withId(
      id: map["id"],
      isActive: (map["isActive"] as int).intToBool(),
      fullyCompleted: (map["fullyCompleted"] as int).intToBool(),
      habit: map["goal"],
      requiredReps: map["requiredReps"],
      steps: jsonToStringList(map["steps"]),
      comments: jsonToStringList(map["comments"]),
      trainingTimeIndex: map["trainingTimeIndex"],
      requiredTrainings: map["requiredTrainings"],
      requiredTrainingPeriods: map["requiredTrainingPeriods"],
      lastChanged: DateTime.parse(map["lastChanged"]),
    );
  }
}
