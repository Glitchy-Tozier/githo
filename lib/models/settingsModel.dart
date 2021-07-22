import 'package:githo/extracted_functions/typeExtentions.dart';

class Settings {
  bool showIntroduction;
  bool paused;

  Settings({
    required this.showIntroduction,
    required this.paused,
  });

  Map<String, dynamic> toMap() {
    final map = Map<String, dynamic>();
    map["showIntroduction"] = showIntroduction.boolToInt();
    map["paused"] = paused.boolToInt();
    return map;
  }

  factory Settings.fromMap(final Map<String, dynamic> map) {
    return Settings(
      showIntroduction: (map["showIntroduction"] as int).intToBool(),
      paused: (map["paused"] as int).intToBool(),
    );
  }
}
