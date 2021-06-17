import 'package:githo/models/habitPlanModel.dart';
import 'package:githo/models/progressDataModel.dart';

int getCurrentStepIndex(HabitPlan habitPlan, ProgressData progressData) {
  // returns the index of the current step. (The first step has the index 0)
  final int stepIndex = ((progressData.completedTrainingPeriods) /
          habitPlan.requiredTrainingPeriods)
      .floor();

  return stepIndex;
}
