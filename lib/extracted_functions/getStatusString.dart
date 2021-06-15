import 'package:githo/extracted_data/fullDatabaseImport.dart';
import 'package:githo/models/progressDataModel.dart';

String getStatusString(HabitPlan habitPlan, ProgressData progressData) {
  String subTitle = "Status: ";

  if (habitPlan.isActive) {
    if (progressData.level == 0) {
      subTitle += "Preparing";
    } else {
      subTitle += "Level ${progressData.level}";
    }
  } else {
    subTitle += "Inactive";
  }

  return subTitle;
}
