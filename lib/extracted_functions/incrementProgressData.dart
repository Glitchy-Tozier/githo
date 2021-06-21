import 'package:githo/extracted_data/fullDatabaseImport.dart';
import 'package:githo/extracted_functions/catchUpProgressData.dart';

void incrementProgressData(HabitPlan habitPlan, ProgressData progressData) {
  // Make sure we're using the correct values
  catchUpProgressData(habitPlan, progressData);

  // Increment requiredReps-data.
  progressData.completedReps++;

  if (progressData.completedReps == habitPlan.requiredReps) {
    progressData.completedTrainings++;
  }

  // Save
  DatabaseHelper.instance.updateProgressData(progressData);
}
