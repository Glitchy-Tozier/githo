/* 
 * Githo – An app that helps you form long-lasting habits, one step at a time.
 * Copyright (C) 2021 Florian Thaler
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'package:githo/extracted_functions/typeExtentions.dart';

/// A model for how the user's settings are stored.

class SettingsData {
  bool showIntroduction;
  bool paused;

  SettingsData({
    required this.showIntroduction,
    required this.paused,
  });

  /// Converts the [SettingsData] into a Map.
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {};
    map["showIntroduction"] = showIntroduction.boolToInt();
    map["paused"] = paused.boolToInt();
    return map;
  }

  /// Converts a Map into [SettingsData].
  factory SettingsData.fromMap(final Map<String, dynamic> map) {
    return SettingsData(
      showIntroduction: (map["showIntroduction"] as int).intToBool(),
      paused: (map["paused"] as int).intToBool(),
    );
  }
}
