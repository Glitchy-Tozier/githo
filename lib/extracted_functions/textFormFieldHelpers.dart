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

String? validateNumberField({
  required final String? input,
  required final int maxInput,
  required final String variableText,
  required final String onEmptyText,
}) {
  final String? emptycheck =
      checkIfEmpty(input.toString().trim(), variableText);
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
