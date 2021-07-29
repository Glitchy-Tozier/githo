import 'package:githo/extracted_data/dataShortcut.dart';
import 'package:githo/models/progressDataModel.dart';

class TimeHelper {
  static final TimeHelper instance = TimeHelper._privateConstructor();
  static DateTime? _time;

  TimeHelper._privateConstructor();

  DateTime get _getTime {
    if (_time == null) {
      _time = DateTime.now();
    }
    return _time!;
  }

  DateTime get currentTime {
    // Use this instead of DateTime.now() in your code
    if (DataShortcut.testing == true) {
      final DateTime time = this._getTime;
      return time;
    } else {
      // When not testing, always use the actual current time
      return DateTime.now();
    }
  }

  void timeTravel(final ProgressData progressData) {
    // Make the time move ahead one training
    final DateTime previousTime = this._getTime;
    _time = previousTime.add(
      Duration(
        hours: progressData.trainingDurationInHours,
      ),
    );
  }

  void superTimeTravel(final ProgressData progressData) {
    // Make the time move ahead one trainingPeriod
    final DateTime previousTime = this._getTime;
    _time = previousTime.add(
      Duration(
        hours: progressData.trainingPeriodDurationInHours,
      ),
    );
  }
}
