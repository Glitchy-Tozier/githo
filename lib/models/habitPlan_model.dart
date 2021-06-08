import 'dart:convert';
import 'package:githo/extracted_functions/typeExtentions.dart';

class HabitPlan {
  int? id;
  bool isActive;
  String goal;
  int reps;
  List<String> challenges;
  List<String> rules;
  double timeIndex;
  double activity;
  double requiredRepeats;

  HabitPlan({
    required this.isActive,
    required this.goal,
    required this.reps,
    required this.challenges,
    required this.rules,
    required this.timeIndex,
    required this.activity,
    required this.requiredRepeats,
  });

  HabitPlan.withId({
    required this.id,
    required this.isActive,
    required this.goal,
    required this.reps,
    required this.challenges,
    required this.rules,
    required this.timeIndex,
    required this.activity,
    required this.requiredRepeats,
  });

  Map<String, dynamic> toMap() {
    final map = Map<String, dynamic>();
    if (id != null) {
      map["id"] = id;
    }

    map["isActive"] = isActive.boolToInt();
    map["goal"] = goal;
    map["reps"] = reps;
    map["challenges"] = jsonEncode(challenges);
    map["rules"] = jsonEncode(rules);
    map["timeIndex"] = timeIndex;
    map["activity"] = activity;
    map["requiredRepeats"] = requiredRepeats;

    return map;
  }

  factory HabitPlan.fromMap(Map<String, dynamic> map) {
    List<String> jsonToList(json) {
      var dynamicList = jsonDecode(json);
      List<String> list = [];

      dynamicList.forEach((element) {
        list.add(element);
      });
      return list;
    }

    return HabitPlan.withId(
      id: map["id"],
      isActive: (map["isActive"] as int).intToBool(),
      goal: map["goal"],
      reps: map["reps"],
      challenges: jsonToList(map["challenges"]),
      rules: jsonToList(map["rules"]),
      timeIndex: map["timeIndex"],
      activity: map["activity"],
      requiredRepeats: map["requiredRepeats"],
    );
  }
}
