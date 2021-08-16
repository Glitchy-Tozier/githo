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

import 'dart:convert';
import 'package:githo/database/database_helper.dart';
import 'package:githo/helpers/type_extentions.dart';
import 'package:githo/helpers/time_helper.dart';

/// The model for what a habit-plan consists of.

class HabitPlan {
  HabitPlan({
    required this.isActive,
    required this.fullyCompleted,
    required this.habit,
    required this.requiredReps,
    required this.steps,
    required this.comments,
    required this.trainingTimeIndex,
    required this.requiredTrainings,
    required this.requiredTrainingPeriods,
    required this.lastChanged,
  }) : id = null;

  HabitPlan.withId({
    required this.id,
    required this.isActive,
    required this.fullyCompleted,
    required this.habit,
    required this.requiredReps,
    required this.steps,
    required this.comments,
    required this.trainingTimeIndex,
    required this.requiredTrainings,
    required this.requiredTrainingPeriods,
    required this.lastChanged,
  });

  /// Returns the default empty [HabitPlan].
  HabitPlan.emptyHabitPlan()
      : id = null,
        isActive = false,
        fullyCompleted = false,
        // TextFormFields:
        habit = '',
        requiredReps = 1,
        steps = <String>[],
        comments = <String>[],
        // Sliders:
        trainingTimeIndex = 1,
        requiredTrainings = 5,
        requiredTrainingPeriods = 1,
        lastChanged = TimeHelper.instance.currentTime;

  /// Converts a Map into a [HabitPlan].
  HabitPlan.fromMap(final Map<String, dynamic> map)
      : id = map['id'] as int,
        isActive = (map['isActive'] as int).toBool(),
        fullyCompleted = (map['fullyCompleted'] as int).toBool(),
        habit = map['goal'] as String,
        requiredReps = map['requiredReps'] as int,
        steps = _jsonToStringList(map['steps'] as String),
        comments = _jsonToStringList(map['comments'] as String),
        trainingTimeIndex = map['trainingTimeIndex'] as int,
        requiredTrainings = map['requiredTrainings'] as int,
        requiredTrainingPeriods = map['requiredTrainingPeriods'] as int,
        lastChanged = DateTime.parse(map['lastChanged'] as String);

  final int? id;
  bool isActive;
  bool fullyCompleted;
  String habit;
  int requiredReps;
  List<String> steps;
  List<String> comments;
  int trainingTimeIndex;
  int requiredTrainings;
  int requiredTrainingPeriods;
  DateTime lastChanged;

  /// Converts a [json]-like [String] into a list of [String]s.
  static List<String> _jsonToStringList(final String json) {
    final dynamic dynamicList = jsonDecode(json);
    final List<String> stringList = <String>[];

    for (final String element in dynamicList) {
      stringList.add(element);
    }
    return stringList;
  }

  /// Converts the [HabitPlan] into a Map.
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = <String, dynamic>{};

    if (id != null) {
      map['id'] = id;
    }
    map['isActive'] = isActive.toInt();
    map['fullyCompleted'] = fullyCompleted.toInt();
    map['goal'] = habit;
    map['requiredReps'] = requiredReps;
    map['steps'] = jsonEncode(steps);
    map['comments'] = jsonEncode(comments);
    map['trainingTimeIndex'] = trainingTimeIndex;
    map['requiredTrainings'] = requiredTrainings;
    map['requiredTrainingPeriods'] = requiredTrainingPeriods;
    map['lastChanged'] = lastChanged.toString();

    return map;
  }

  /// Converts the [HabitPlan] into a [String] that is as short as possible
  /// and can be converted into a map at a later point in time.
  String toShareJson() {
    // Get the map of the habitPlan.
    final Map<String, dynamic> map = toMap();

    // Remove unneccessary parameters.
    map.remove('id');
    map.remove('isActive');
    map.remove('fullyCompleted');
    map.remove('lastChanged');

    // Add the database-version.
    map['dbVersion'] = DatabaseHelper.version;

    // Convert the map into a String and return it.
    final String json = jsonEncode(map);
    return json;
  }
}
