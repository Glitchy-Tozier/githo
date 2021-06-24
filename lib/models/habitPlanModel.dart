import 'dart:convert';
import 'package:githo/extracted_functions/typeExtentions.dart';

class HabitPlan {
  int? id;
  bool isActive;
  String goal;
  int requiredReps;
  List<String> steps;
  List<String> comments;
  int trainingTimeIndex;
  int requiredTrainings;
  int requiredTrainingPeriods;
  DateTime lastChanged;

  HabitPlan({
    required this.isActive,
    required this.goal,
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
    required this.goal,
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
    map["goal"] = goal;
    map["requiredReps"] = requiredReps;
    map["steps"] = jsonEncode(steps);
    map["comments"] = jsonEncode(comments);
    map["trainingTimeIndex"] = trainingTimeIndex;
    map["requiredTrainings"] = requiredTrainings;
    map["requiredTrainingPeriods"] = requiredTrainingPeriods;
    map["lastChanged"] = lastChanged.toString();

    return map;
  }

  factory HabitPlan.fromMap(Map<String, dynamic> map) {
    List<String> jsonToStringList(String json) {
      List<dynamic> dynamicList = jsonDecode(json);
      List<String> stringList = [];

      dynamicList.forEach((element) {
        stringList.add(element);
      });
      return stringList;
    }

    return HabitPlan.withId(
      id: map["id"],
      isActive: (map["isActive"] as int).intToBool(),
      goal: map["goal"],
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
