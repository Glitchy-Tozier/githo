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

/// Contains some useful, regularly used values.
class DataShortcut {
  static const List<String> timeFrames = <String>[
    'hour',
    'day',
    'week',
    'month',
  ];
  static const List<String> adjectiveTimeFrames = <String>[
    'hourly',
    'daily',
    'weekly',
    'monthly',
  ];
  static const List<String> nextTimeFrameNames = <String>[
    'the next hour',
    'tomorrow',
    'the next week',
    'the next month',
  ];
  static const List<int> maxTrainings = <int>[24, 7, 4];

  static const List<int> trainingDurationInHours = <int>[
    1,
    24,
    24 * 7,
  ];
  static const List<int> periodDurationInHours = <int>[
    24,
    24 * 7,
    24 * 7 * 4,
  ];

  /// Toggles the Debug-banner and activates testing-functionality.
  static const bool testing = false;
}
