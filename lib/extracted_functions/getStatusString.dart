import 'package:githo/extracted_data/currentTime.dart';
import 'package:githo/extracted_data/dataShortcut.dart';
import 'package:githo/extracted_functions/getCurrentStepIndex.dart';
import 'package:githo/extracted_functions/typeExtentions.dart';

import 'package:githo/models/habitPlanModel.dart';
import 'package:githo/models/progressDataModel.dart';

String getStatusString(HabitPlan habitPlan, ProgressData progressData) {
  // Used in the title of some screens.
  String subTitle;

  if (habitPlan.isActive) {
    if (CurrentTime.instance.getTime
        .isBefore(progressData.currentStartingDate)) {
      subTitle = "Status: Preparing";
    } else {
      final int stepIndex = getCurrentStepIndex(habitPlan, progressData);
      final int stepNr = stepIndex + 1;
      final int requiredTrainingPeriods = habitPlan.requiredTrainingPeriods;
      if (requiredTrainingPeriods == 1) {
        subTitle = "Status: Step $stepNr";
      } else {
        final String timeFrame = DataShortcut
            .timeFrames[habitPlan.trainingTimeIndex + 1]
            .capitalize();

        final int ignoredTimePeriods =
            stepIndex * habitPlan.requiredTrainingPeriods;
        final int currentTimePeriod =
            progressData.completedTrainingPeriods + 1 - ignoredTimePeriods;

        subTitle =
            "Step $stepNr – $timeFrame $currentTimePeriod/$requiredTrainingPeriods";
      }
    }
  } else {
    subTitle = "Status: Inactive";
  }

  return subTitle;
}
