/* import 'package:githo/helpers/timeHelper.dart';
import 'package:githo/extracted_data/dataShortcut.dart';
import 'package:githo/extracted_data/fullDatabaseImport.dart';

void catchUpProgressData(
  HabitPlan habitPlan,
  ProgressData progressData,
) {
  final DateTime currentStartingDate = progressData.currentStartingDate;
  final DateTime lastActive = progressData.lastActiveDate;

  final DateTime currentTime = TimeHelper.instance.getTime;

  print("Start $currentStartingDate");
  print("Last  $lastActive");
  print("Now   $currentTime");
  if (currentTime.isAfter(currentStartingDate)) {
    final int trainingTimeIndex = habitPlan.trainingTimeIndex;

    // Get the number of time-units passed since {insert first date} (for dayly trainings days)
    final int repDurationInHours =
        DataShortcut.repDurationInHours[trainingTimeIndex];
    final int lastActiveDiff =
        (lastActive.difference(currentStartingDate).inHours /
                repDurationInHours)
            .floor();
    final int nowDiff = (currentTime.difference(currentStartingDate).inHours /
            repDurationInHours)
        .floor();

    // Check if we're in a new "time span". (For dayly trainings, that would be the next day).
    final bool inNewTimeFrame = (lastActiveDiff != nowDiff);
    if (inNewTimeFrame) {
      // If this is the first day of the step:

      // Reset reps
      if (progressData.completedReps >= habitPlan.requiredReps) {
        progressData.completedTrainings++;
        //progressData.trainingData[]
      }
      progressData.completedReps = 0;
      progressData.lastActiveDate = currentTime;

      // Calculate the number of time-periods passed. For dayly trainings, that would be how many weeks have passed.
      const List<int> timePeriodLength = DataShortcut.maxTrainings;
      final int timePeriodsPassed =
          (nowDiff / timePeriodLength[trainingTimeIndex]).floor();
      // If we are in a new time-period...
      for (int i = 0; i < timePeriodsPassed; i++) {
        print("A WEEK HAS PASSED");
        // Move the starting date for the current step
        progressData.currentStartingDate = progressData.currentStartingDate.add(
          Duration(
            hours: DataShortcut.stepDurationInHours[trainingTimeIndex],
          ),
        );
        // Adjust the user's level according to his score
        if (progressData.completedTrainings >= habitPlan.requiredTrainings) {
          final int maxPeriods =
              habitPlan.steps.length * habitPlan.requiredTrainingPeriods;
          if (progressData.completedTrainingPeriods < maxPeriods - 1) {
            progressData.completedTrainingPeriods++;
          }
        } else if (progressData.completedTrainingPeriods > 0) {
          progressData.completedTrainingPeriods--;
        }

        progressData.completedTrainings = 0;
      }
      DatabaseHelper.instance.updateProgressData(progressData);
    }
  }
  print("\n\n\n");
}
 */
