import 'package:githo/extracted_data/dataShortcut.dart';

class TimeHelper {
  static final TimeHelper instance = TimeHelper._instance();
  static late DateTime testingTime;

  TimeHelper._instance();

  void setTime(DateTime dateTime) {
    testingTime = dateTime;
  }

  DateTime get getTime {
    if (DataShortcut.testing == true) {
      return testingTime;
    } else {
      return DateTime.now();
    }
  }
}
