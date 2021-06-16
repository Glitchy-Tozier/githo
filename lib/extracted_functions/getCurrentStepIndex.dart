import 'package:githo/models/habitPlanModel.dart';
import 'package:githo/models/progressDataModel.dart';

int getCurrentStepIndex(HabitPlan habitPlan, ProgressData progressData) {
  // returns the index of the current challenge.
  final int challengeIndex;
  if (progressData.level == 0) {
    challengeIndex = 0;
  } else {
    challengeIndex =
        ((progressData.level - 1) / habitPlan.requiredTrainingPeriods).floor();
  }
  return challengeIndex;
}
