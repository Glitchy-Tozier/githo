/* import 'package:githo/helpers/timeHelper.dart';

import 'package:githo/models/progressDataModel.dart';
import 'package:githo/models/used_classes/step.dart';
import 'package:githo/models/used_classes/trainingPeriod.dart';

String getStatusString(final ProgressData progressData) {
  // Used in the title of some screens.
  final String subTitle;

  if (progressData.steps.length > 0) {
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
        subTitle =
            "Step $stepNr – ${activePeriod.durationText} ${activePeriod.number}/$trainingPeriodCount";
      }
    }
  } else {
    subTitle = "Status: Inactive";
  }

  return subTitle;
}
 */
