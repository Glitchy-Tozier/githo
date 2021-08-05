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

class DataShortcut {
  // Contains some useful, regularly used values.

  static const List<String> timeFrames = [
    "hour",
    "day",
    "week",
    "month",
  ];
  static const List<String> adjectiveTimeFrames = [
    "hourly",
    "daily",
    "weekly",
    "monthly",
  ];
  static const List<String> nextTimeFrameNames = [
    "the next hour",
    "tomorrow",
    "the next week",
    "the next month",
  ];
  static const List<int> maxTrainings = [24, 7, 4];

  static const List<int> trainingDurationInHours = [
    1,
    24,
    24 * 7,
  ];
  static const List<int> periodDurationInHours = [
    24,
    24 * 7,
    24 * 7 * 4,
  ];

  static const bool testing = false;
}
