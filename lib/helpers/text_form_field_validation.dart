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

// Functions that are used to validate TextFormFields.

import 'dart:convert';

import 'package:githo/config/data_shortcut.dart';

/// Checks if the [input] is empty.
String? complainIfEmpty({
  required final String? input,
  required final String toFillIn,
}) {
  final String trimmedInput = input.toString().trim();

  if (trimmedInput.isEmpty) {
    return 'Please fill in $toFillIn';
  } else {
    return null;
  }
}

/// The validation-function for all number-input-TextFields
String? validateNumberField({
  required final String? input,
  required final int maxInput,
  required final String toFillIn,
  required final String textIfZero,
}) {
  final String? complaint = complainIfEmpty(
    input: input,
    toFillIn: toFillIn,
  );
  if (complaint != null) {
    // If the TextField is empty:
    return complaint;
  } else {
    // If the TextField contains a value, see if it's valid.
    try {
      final int intput = int.parse(input.toString().trim()); // I'm so funny!
      if (intput > maxInput) {
        return 'Must be between 1 and $maxInput';
      } else if (intput == 0) {
        return textIfZero;
      } else {
        return null;
      }
    } catch (error) {
      return 'This is not a number';
    }
  }
}

/// Converts a [json]-like [String] into a list of [String]s.
List<String> _jsonToStringList(final String json) {
  final dynamic dynamicList = jsonDecode(json);
  final List<String> stringList = <String>[];

  for (final String element in dynamicList) {
    stringList.add(element);
  }
  return stringList;
}

/// Checks whether an [input] has the correct structure to be used.
String? validateHabitPlanImport(final String input) {
  if (input.length > 9999) {
    return 'Too much text';
  }

  try {
    // Convert the input into something usable.
    final Map<String, dynamic> map = jsonDecode(input) as Map<String, dynamic>;

    // Make sure all required values exist within the map.
    if (!map.containsKey('goal') ||
        !map.containsKey('requiredReps') ||
        !map.containsKey('steps') ||
        !map.containsKey('comments') ||
        !map.containsKey('trainingTimeIndex') ||
        !map.containsKey('requiredTrainings') ||
        !map.containsKey('requiredTrainingPeriods')) {
      return 'Some values are missing';
    }

    for (final MapEntry<String, dynamic> entry in map.entries) {
      if (entry.value == null) {
        return 'A value is missing';
      }
    }

    final List<String> steps = _jsonToStringList(map['steps'] as String);
    final List<String> comments = _jsonToStringList(map['comments'] as String);

    // Check the number of steps & comments.
    if (steps.isEmpty) {
      return 'The list of steps is empty.';
    } else if (steps.length > DataShortcut.maxStepCount) {
      return 'Too many steps. (> ${DataShortcut.maxStepCount})';
    }
    if (comments.length > DataShortcut.maxStepCount) {
      return 'Too many comments. (> ${DataShortcut.maxStepCount})';
    }

    // Make sure all other values are within their acceptable ranges.
    final int requiredReps = map['requiredReps'] as int;
    if (requiredReps < 1 || requiredReps > 99) {
      return '[requiredReps]: is out of range';
    }

    final int trainingTimeIndex = map['trainingTimeIndex'] as int;
    final int maxTimeIndex = DataShortcut.timeFrames.length - 2;
    if (trainingTimeIndex < 0 || trainingTimeIndex > maxTimeIndex) {
      return '[trainingTimeIndex]: out of range';
    }

    final int requiredTrainings = map['requiredTrainings'] as int;
    final int maxTrainings = DataShortcut.maxTrainings[trainingTimeIndex];
    if (requiredTrainings < 1 || requiredTrainings > maxTrainings) {
      return '[requiredTrainings]: out of range';
    }

    final int requiredTrainingPeriods = map['requiredTrainingPeriods'] as int;

    if (requiredTrainingPeriods < 1 || requiredTrainingPeriods > 10) {
      return '[requiredTrainingPeriods]:\nout of range';
    }
  } catch (error) {
    print(error);
    return 'This format is not valid';
  }
}
