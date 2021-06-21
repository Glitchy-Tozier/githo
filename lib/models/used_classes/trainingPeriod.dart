import 'package:githo/models/used_classes/training.dart';

class TrainingPeriod {
  int durationInHours;
  int requiredTrainings;
  bool isDone = false;
  List<Training> trainings;

  TrainingPeriod({
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
}
