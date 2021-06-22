import 'package:githo/helpers/timeHelper.dart';
import 'package:githo/extracted_data/dataShortcut.dart';
import 'package:githo/extracted_functions/typeExtentions.dart';

import 'package:githo/models/habitPlanModel.dart';
import 'package:githo/models/progressDataModel.dart';
import 'package:githo/models/used_classes/step.dart';
import 'package:githo/models/used_classes/trainingPeriod.dart';

String getStatusString(HabitPlan habitPlan, ProgressData progressData) {
  // Used in the title of some screens.
  String subTitle;

  if (habitPlan.isActive) {
    if (TimeHelper.instance.getTime
        .isBefore(progressData.currentStartingDate)) {
      subTitle = "Status: Preparing";
    } else {
      final Map<String, dynamic> activeData = progressData.getActiveData()!;
      final StepClass activeStep = activeData["step"];
      final TrainingPeriod activePeriod = activeData["trainingPeriod"];
      final int stepNr = activeStep.number;
      final int trainingPeriodCount = activeStep.trainingPeriods.length;
      if (trainingPeriodCount == 1) {
        subTitle = "Status: Step $stepNr";
      } else {
        final String timeFrameText = DataShortcut
            .timeFrames[habitPlan.trainingTimeIndex + 1]
            .capitalize();

        subTitle =
            "Step $stepNr – $timeFrameText ${activePeriod.number}/$trainingPeriodCount";
      }
    }
  } else {
    subTitle = "Status: Inactive";
  }

  return subTitle;
}
