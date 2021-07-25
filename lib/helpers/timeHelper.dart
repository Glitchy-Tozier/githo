import 'package:githo/extracted_data/dataShortcut.dart';
import 'package:githo/models/progressDataModel.dart';

class TimeHelper {
  static final TimeHelper instance = TimeHelper._privateConstructor();
  static late DateTime _testingTime;

  TimeHelper._privateConstructor();

  void setTime(final DateTime dateTime) {
    _testingTime = dateTime;
  }

  DateTime get getTime {
    if (DataShortcut.testing == true) {
      return _testingTime;
    } else {
      return DateTime.now();
    }
  }

  void timeTravel(final ProgressData progressData) {
    _testingTime = _testingTime.add(
      Duration(
        hours: progressData.trainingDurationInHours,
      ),
    );
  }

  void superTimeTravel(final ProgressData progressData) {
    _testingTime = _testingTime.add(
      Duration(
        hours: progressData.trainingPeriodDurationInHours,
      ),
    );
  }
}
