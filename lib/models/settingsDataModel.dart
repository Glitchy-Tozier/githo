import 'package:githo/extracted_functions/typeExtentions.dart';

class SettingsData {
  bool paused;

  SettingsData({
    required this.paused,
  });

  Map<String, dynamic> toMap() {
    final map = Map<String, dynamic>();
    map["paused"] = paused.boolToInt();
    return map;
  }

  factory SettingsData.fromMap(Map<String, dynamic> map) {
    return SettingsData(
      paused: (map["paused"] as int).intToBool(),
    );
  }
}
