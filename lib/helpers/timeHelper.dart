import 'package:githo/extracted_data/dataShortcut.dart';
import 'package:githo/models/progressDataModel.dart';

class TimeHelper {
  // Used intstead of DateTime.now() to help with debugging.

  static final TimeHelper instance = TimeHelper._privateConstructor();
  static Duration _timeToAdd = Duration.zero;

  const TimeHelper._privateConstructor();

  DateTime get currentTime {
    final DateTime now = DateTime.now();

    // Use this instead of DateTime.now() in your code
    if (DataShortcut.testing == true) {
      final DateTime result = now.add(_timeToAdd);
      return result;
    } else {
      // When not testing, always use the actual current time
      return now;
    }
  }

  void timeTravel(final ProgressData progressData) {
    // Make the time move ahead one training
    _timeToAdd = _timeToAdd +
        Duration(
          hours: progressData.trainingDurationInHours,
        );
  }

  void superTimeTravel(final ProgressData progressData) {
    // Make the time move ahead one trainingPeriod
    _timeToAdd = _timeToAdd +
        Duration(
          hours: progressData.trainingPeriodDurationInHours,
        );
  }
}
