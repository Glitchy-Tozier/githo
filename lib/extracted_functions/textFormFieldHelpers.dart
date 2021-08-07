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

// A few handy functions that were extracted to make the script more readable and controlable.
// Only functions connected to TextFormFields can be found here!!

import 'package:flutter/material.dart';

InputDecoration inputDecoration(final String text) {
  // Provide the basic Styling for TextFormFields.
  return InputDecoration(
    labelText: text,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  );
}

String? complainIfEmpty(final String? input, final String variableText) {
  // Check if the TextFormField is empty.
  if (input!.trim().isEmpty) {
    return "Please fill in $variableText";
  } else {
    return null;
  }
}

String? validateNumberField({
  required final String? input,
  required final int maxInput,
  required final String variableText,
  required final String onEmptyText,
}) {
  // Validation function for all number-input-TextFields
  final String? emptycheck =
      complainIfEmpty(input.toString().trim(), variableText);
  if (emptycheck != null) {
    return emptycheck;
  }

  final int intput = int.parse(input.toString().trim()); // I'm so funny!
  if (intput > maxInput) {
    return "Must be between 1 and $maxInput";
  } else if (intput == 0) {
    return onEmptyText;
  } else {
    return null;
  }
}
