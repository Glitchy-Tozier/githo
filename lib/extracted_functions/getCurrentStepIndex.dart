import 'package:githo/models/habitPlanModel.dart';
import 'package:githo/models/progressDataModel.dart';

int getCurrentStepIndex(HabitPlan habitPlan, ProgressData progressData) {
  // returns the index of the current challenge.
  final int stepIndex = ((progressData.completedTrainingPeriods) /
          habitPlan.requiredTrainingPeriods)
      .floor();

  return stepIndex;
}
