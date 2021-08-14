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

import 'package:flutter/material.dart';
import 'package:githo/config/data_shortcut.dart';
import 'package:githo/helpers/text_form_field_validation.dart';
import 'package:githo/helpers/type_extentions.dart';

class FormList extends StatefulWidget {
  /// Creates a column of TextFormFields that grow in numbers when filled out.
  const FormList({
    required this.fieldName,
    required this.canBeEmpty,
    required this.valuesGetter,
    required this.initValues,
  });

  final String fieldName;
  final bool canBeEmpty;
  final Function valuesGetter;
  final List<String> initValues;

  @override
  _FormListState createState() => _FormListState();
}

class _FormListState extends State<FormList> {
  static const int minFormFieldCount = 2;

  final List<Widget> formFields = <Widget>[];
  final List<String> returnValues = List<String>.generate(
    DataShortcut.maxStepCount,
    (_) => '',
  );

  @override
  void initState() {
    super.initState();

    final List<String> initialValues = widget.initValues;

    if (initialValues.length < DataShortcut.maxStepCount) {
      initialValues.add('');
    }

    // Generate the TextFormFields
    for (int i = 0; i < initialValues.length; i++) {
      formFields.add(
        textFormField(widget.fieldName, i, initialValues[i]),
      );
    }
  }

  Widget textFormField(
    final String name,
    final int index,
    final String value,
  ) {
    final int fieldNr = index + 1;
    final String fieldName;
    if (fieldNr < DataShortcut.maxStepCount) {
      fieldName = '${name.capitalize()} $fieldNr';
    } else {
      fieldName = 'Final $name';
    }

    return Column(
      children: <Widget>[
        TextFormField(
          initialValue: value,
          decoration: InputDecoration(labelText: fieldName),
          maxLength: DataShortcut.maxStepCharacters,
          validator: (final String? input) {
            if (widget.canBeEmpty == true) {
              // Use this validation if the fields are optional
              if (formFields.length > minFormFieldCount &&
                  fieldNr < formFields.length) {
                return complainIfEmpty(
                  input: input,
                  toFillIn: fieldName,
                );
              }
            } else {
              // Use this validation if at least one field NEEDS to be
              // filled out.
              if (fieldNr < formFields.length) {
                return complainIfEmpty(
                  input: input,
                  toFillIn: fieldName,
                );
              }
            }
          },
          onChanged: (final String? input) {
            if (fieldNr == formFields.length &&
                fieldNr < DataShortcut.maxStepCount) {
              setState(() {
                formFields.add(textFormField(name, index + 1, ''));
              });
            } else if (formFields.length > minFormFieldCount &&
                fieldNr == formFields.length - 1) {
              final bool removeLast;
              if (input == null || input.trim().isEmpty) {
                removeLast = true;
              } else {
                removeLast = false;
              }
              if (removeLast) {
                setState(() {
                  formFields.removeLast();
                });
              }
            }
          },
          textInputAction: TextInputAction.next,
          onSaved: (final String? input) {
            final String trimmedInput = input.toString().trim();
            if (fieldNr < formFields.length) {
              // If this is not the last TextFormField.
              returnValues[index] = trimmedInput;
            } else {
              // If this is the last one of the TextFormFields ([formFields]).
              // Remove the values for all non-existent TextFormFields.
              while (returnValues.length > formFields.length) {
                returnValues.removeLast();
              }
              // Remove the value for the last TextFormField if it's empty.
              // If it's not, also return it.
              if (trimmedInput.isEmpty) {
                returnValues.removeLast();
              } else {
                returnValues[index] = trimmedInput;
              }
            }

            // Send the results back to the EditHabit()-screen.
            widget.valuesGetter(returnValues);
          },
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ...formFields,
        if (formFields.length < DataShortcut.maxStepCount)
          const Text(
            '⋮',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
      ],
    );
  }
}
