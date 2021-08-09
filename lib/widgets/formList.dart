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
import 'package:githo/config/styleData.dart';
import 'package:githo/helpers/textFormFieldvalidation.dart';

class FormList extends StatefulWidget {
  final String fieldName;
  final bool canBeEmpty;
  final Function valuesGetter;
  final List<String> inputList;

  /// Creates a column of TextFormFields that grow in numbers when filled out.
  const FormList({
    required this.fieldName,
    required this.canBeEmpty,
    required this.valuesGetter,
    required this.inputList,
  });

  @override
  _FormListState createState() => _FormListState(
        fieldName,
        canBeEmpty,
        valuesGetter,
        inputList,
      );
}

class _FormListState extends State<FormList> {
  final int _iniLength = 2;

  final List<Widget> _inputFields = [];
  int listLength = 0;
  late List<String> inputValues;

  final bool canBeEmpty;
  final Function exportValues;

  _FormListState(
    final String name,
    this.canBeEmpty,
    this.exportValues,
    final List<String> initValues,
  ) {
    // Generate the TextFormFields
    for (int i = 0; i < initValues.length + 1; i++) {
      if (i < initValues.length) {
        this._inputFields.add(_textFormField(name, i, initValues[i]));
      } else {
        this._inputFields.add(_textFormField(name, i, ""));
      }
    }
    _updateScores();
  }

  void _updateScores() {
    this.listLength = _inputFields.length;
    this.inputValues = List.generate(this.listLength - 1, (index) => "");
  }

  Widget _textFormField(
    final String name,
    final int index,
    final String value,
  ) {
    int fieldNr = index + 1;
    String fieldName = "$name $fieldNr";

    return Column(
      children: [
        TextFormField(
          initialValue: value,
          decoration: inputDecoration(fieldName),
          maxLength: 140,
          validator: (input) {
            if (canBeEmpty == true) {
              // Use This validation if the fields are optional
              if ((fieldNr != this.listLength) &&
                  (this.listLength > this._iniLength)) {
                return complainIfEmpty(
                  input: input,
                  toFillIn: fieldName,
                );
              }
            } else {
              // Use this validation if at least one field NEEDS to be filled out.
              if (fieldNr != this.listLength) {
                return complainIfEmpty(
                  input: input,
                  toFillIn: fieldName,
                );
              }
            }
          },
          onChanged: (input) {
            if (fieldNr == this.listLength) {
              setState(() {
                this._inputFields.add(_textFormField(name, index + 1, ""));
                _updateScores();
              });
            } else if (input.isEmpty &&
                (fieldNr == this.listLength - 1) &&
                (this.listLength > this._iniLength)) {
              setState(() {
                this._inputFields.removeLast();
                _updateScores();
              });
            }
          },
          textInputAction: TextInputAction.next,
          onSaved: (input) {
            if (fieldNr != this.listLength) {
              // Only do this if the current TextFormField is not the last (empty) TextFormField
              this.inputValues[index] = input.toString().trim();
              exportValues(this.inputValues);
            }
          },
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...this._inputFields,
        const Text(
          "⋮",
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
