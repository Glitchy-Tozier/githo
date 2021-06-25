import 'package:githo/extracted_data/dataShortcut.dart';
import 'package:githo/models/habitPlanModel.dart';

class Training {
  late int number;
  late int durationInHours;
  int doneReps = 0;
  late int requiredReps;
  DateTime startingDate = DateTime.now();
  DateTime endingDate = DateTime.now();
  String status = "";

  Training({required int trainingIndex, required HabitPlan habitPlan}) {
    this.number = trainingIndex + 1;
    this.durationInHours =
        DataShortcut.trainingDurationInHours[habitPlan.trainingTimeIndex];
    this.requiredReps = habitPlan.requiredReps;
  }

  Training.withDirectValues({
    required this.number,
    required this.durationInHours,
    required this.doneReps,
    required this.requiredReps,
    required this.startingDate,
    required this.endingDate,
    required this.status,
  });

  void setDates(DateTime startingDate) {
    this.startingDate = startingDate;
    this.endingDate = startingDate.add(
      Duration(hours: this.durationInHours),
    );
  }

  void incrementReps() {
    this.doneReps++;
    if (this.requiredReps == this.doneReps) {
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
      this.status = "";
    } else if (this.status == "active") {
      // If the training was started but never successfully finished
      this.status = "unsuccessful";
    } else if (this.status == "done") {
      // If the training was finished in time
      this.status = "successful";
    } else {
      print("Unknown Status: ${this.status}");
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
    return Training.withDirectValues(
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
