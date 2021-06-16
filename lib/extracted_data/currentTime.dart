import 'package:githo/extracted_data/dataShortcut.dart';

class CurrentTime {
  static final CurrentTime instance = CurrentTime._instance();
  static late DateTime testingTime;

  CurrentTime._instance();

  void setTime(DateTime dateTime) {
    testingTime = dateTime;
  }

  get getTime {
    if (DataShortcut.testing == true) {
      return testingTime;
    } else {
      return DateTime.now();
    }
  }
}
