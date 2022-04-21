/* 
 * Githo – An app that helps you gradually form long-lasting habits.
 * Copyright (C) 2022 Florian Thaler
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
    required this.valuesSetter,
    required this.initialValues,
    Key? key,
  }) : super(key: key);

  final String fieldName;
  final bool canBeEmpty;
  final void Function(List<String>) valuesSetter;
  final List<String> initialValues;

  @override
  _FormListState createState() => _FormListState();
}

class _FormListState extends State<FormList> {
  static const int minFormFieldCount = 2;

  final List<Widget> formFields = <Widget>[];
  final List<String> returnValues = List<String>.generate(
    DataShortcut.maxLevelCount,
    (_) => '',
  );

  late List<String> values;

  @override
  void initState() {
    super.initState();
    _initList();
  }

  /// Initialize the List of default-values.
  void _initList() {
    final List<String> initialValues = List<String>.from(widget.initialValues);

    // Make sure the list isn't empty
    if (initialValues.isEmpty) {
      initialValues.add('');
    }
    // Make sure we have an additional empty slot at the end of our list
    if (initialValues.length < DataShortcut.maxLevelCount) {
      initialValues.add('');
    }

    // Generate the TextFormFields
    formFields.clear();
    for (int i = 0; i < initialValues.length; i++) {
      formFields.add(
        textFormField(widget.fieldName, i, initialValues[i]),
      );
    }

    // Save current initValues to make sure change is detected.
    values = widget.initialValues;
  }

  Widget textFormField(
    final String name,
    final int index,
    final String value,
  ) {
    final TextEditingController controller = TextEditingController();
    final int fieldNr = index + 1;
    final String fieldName;

    controller.text = value;

    if (fieldNr < DataShortcut.maxLevelCount) {
      fieldName = '${name.capitalize()} $fieldNr';
    } else {
      fieldName = 'Final $name';
    }

    return Column(
      children: <Widget>[
        TextFormField(
          controller: controller,
          decoration: InputDecoration(labelText: fieldName),
          maxLength: DataShortcut.maxLevelCharacters,
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
            return null;
          },
          onChanged: (final String? input) {
            if (fieldNr == formFields.length &&
                fieldNr < DataShortcut.maxLevelCount) {
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
            String correctedInput = input.toString().trim();
            if (correctedInput.length > DataShortcut.maxLevelCharacters) {
              correctedInput = correctedInput.substring(
                0,
                DataShortcut.maxLevelCharacters,
              );
            }

            if (fieldNr < formFields.length) {
              // If this is not the last TextFormField.
              returnValues[index] = correctedInput;
            } else {
              // If this is the last one of the TextFormFields ([formFields]).
              // Remove the values for all non-existent TextFormFields.
              while (returnValues.length > formFields.length) {
                returnValues.removeLast();
              }
              // Remove the value for the last TextFormField if it's empty.
              // If it's not, also return it.
              if (correctedInput.isEmpty) {
                returnValues.removeLast();
              } else {
                returnValues[index] = correctedInput;
              }
            }

            // Send the results back to the EditHabit()-screen.
            widget.valuesSetter(returnValues);
          },
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (values != widget.initialValues) {
      _initList();
    }

    return Column(
      children: <Widget>[
        ...formFields,
        if (formFields.length < DataShortcut.maxLevelCount)
          const Text(
            '⋮',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }
}
