import 'package:githo/models/used_classes/trainingPeriod.dart';

class Training {
  int number;
  int durationInHours;
  int doneReps = 0;
  int requiredReps;
  DateTime startingDate;
  late DateTime endingDate;
  String status = "";

  Training({
    required this.number,
    required this.durationInHours,
    required this.requiredReps,
    required this.startingDate,
  }) {
    this.endingDate = this.startingDate;
  }

  void incrementReps() {
    this.doneReps++;
    if (this.requiredReps == this.doneReps) {
      this.status = "done";
    }
  }

  void activate() {
    this.status = "active";
  }

  void setResult() {
    if (this.status == "done") {
      // If the training was finished in time
      this.status = "successful";
    } else if (this.status == "active") {
      // If the training was started but never successfully finished
      this.status = "unsuccessful";
    }
  }
}
