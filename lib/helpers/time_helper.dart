/* 
 * Githo – An app that helps you gradually form long-lasting habits.
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

import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:githo/config/data_shortcut.dart';
import 'package:githo/models/progress_data.dart';

/// Used intstead of TZDateTime.now(…) to help with debugging.
class TimeHelper {
  const TimeHelper._privateConstructor();

  /// The singleton-instance of DatabaseHelper.
  static const TimeHelper instance = TimeHelper._privateConstructor();
  static Duration _timeToAdd = Duration.zero;

  static void initTimeZones() {
    tz.initializeTimeZones();
  }

  /// Returns the current [tz.TZDateTime].
  ///
  /// Use this instead of `TZDateTime.now(…)` in your code.
  tz.TZDateTime get currentTime {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

    if (DataShortcut.testing == true) {
      final tz.TZDateTime result = now.add(_timeToAdd);
      return result;
    } else {
      // When not testing, always use the actual current time
      return now;
    }
  }

  /// Make the time move ahead one training
  void timeTravel(final ProgressData progressData) {
    _timeToAdd = _timeToAdd +
        Duration(
          hours: progressData.trainingDurationInHours,
        );
  }

  /// Make the time move ahead one trainingPeriod
  void superTimeTravel(final ProgressData progressData) {
    _timeToAdd = _timeToAdd +
        Duration(
          hours: progressData.trainingPeriodDurationInHours,
        );
  }
}
