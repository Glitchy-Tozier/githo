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
