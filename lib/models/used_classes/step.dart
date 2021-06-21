import 'package:githo/models/used_classes/training.dart';
import 'package:githo/models/used_classes/trainingPeriod.dart';

class Step {
  String text;
  int durationInHours;
  List<TrainingPeriod> trainingPeriods;

  Step({
    required this.text,
    required this.durationInHours,
    required this.trainingPeriods,
  });

  void setChildrenDates(DateTime startingDate) {
    for (final TrainingPeriod trainingPeriod in this.trainingPeriods) {
      trainingPeriod.setChildrenDates(startingDate);
      startingDate.add(Duration(hours: trainingPeriod.durationInHours));
    }
  }

  Training? getActiveTraining() {
    for (final TrainingPeriod trainingPeriod in this.trainingPeriods) {
      Training? training = trainingPeriod.getActiveTraining();
      if (training != null) {
        return training;
      }
    }
  }

  Training? getTrainingByDate(DateTime date) {
    for (final TrainingPeriod trainingPeriod in this.trainingPeriods) {
      Training? training = trainingPeriod.getTrainingByDate(date);
      if (training != null) {
        return training;
      }
    }
  }

  void resetChildrenProgresses(int startingNumber) {
    for (final TrainingPeriod trainingPeriod in this.trainingPeriods) {
      trainingPeriod.resetTrainingProgresses(startingNumber);
    }
  }

  Map<String, dynamic>? getActiveData() {
    Map<String, dynamic>? result;
    for (final trainingPeriod in this.trainingPeriods) {
      Map<String, dynamic>? tempResult = trainingPeriod.getActiveData();
      if (tempResult != null) {
        result = tempResult;
        result["step"] = this;
        break;
      }
    }
    return result;
  }
}
