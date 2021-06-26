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

String? checkIfEmpty(final String? input, final String variableText) {
  // Check if the TextFormField is empty.
  if (input!.trim().isEmpty) {
    return "Please fill out $variableText";
  } else {
    return null;
  }
}

String? validateNumberField(
  final String? input,
  final String variableText,
  final String timeFrameText,
) {
  final String? emptycheck =
      checkIfEmpty(input.toString().trim(), variableText);
  if (emptycheck != null) {
    return emptycheck;
  }

  final int intput = int.parse(input.toString().trim()); // I'm so funny!
  if (intput >= 1000) {
    return "Please input smaller numbers";
  } else if (intput == 0) {
    return "It has to be at least one rep a $timeFrameText";
  } else {
    return null;
  }
}
