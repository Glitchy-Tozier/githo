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
import 'package:githo/config/style_data.dart';
import 'package:githo/helpers/text_form_field_validation.dart';

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
  final int _iniLength = 2;
  int listLength = 0;
  final List<Widget> widgetList = <Widget>[];
  List<String> inputValues = <String>[];

  @override
  void initState() {
    super.initState();
    // Generate the TextFormFields
    for (int i = 0; i < widget.initValues.length + 1; i++) {
      if (i < widget.initValues.length) {
        widgetList.add(
          _textFormField(widget.fieldName, i, widget.initValues[i]),
        );
      } else {
        widgetList.add(
          _textFormField(widget.fieldName, i, ''),
        );
      }
    }
    _updateScores();
  }

  void _updateScores() {
    listLength = widgetList.length;
    inputValues = List<String>.generate(
      listLength - 1,
      (final int index) => '',
    );
  }

  Widget _textFormField(
    final String name,
    final int index,
    final String value,
  ) {
    final int fieldNr = index + 1;
    final String fieldName = '$name $fieldNr';

    return Column(
      children: <Widget>[
        TextFormField(
          initialValue: value,
          decoration: inputDecoration(fieldName),
          maxLength: 140,
          validator: (String? input) {
            if (widget.canBeEmpty == true) {
              // Use This validation if the fields are optional
              if ((fieldNr != listLength) && (listLength > _iniLength)) {
                return complainIfEmpty(
                  input: input,
                  toFillIn: fieldName,
                );
              }
            } else {
              // Use this validation if at least one field NEEDS to be
              // filled out.
              if (fieldNr != listLength) {
                return complainIfEmpty(
                  input: input,
                  toFillIn: fieldName,
                );
              }
            }
          },
          onChanged: (String? input) {
            if (fieldNr == listLength) {
              setState(() {
                widgetList.add(_textFormField(name, index + 1, ''));
                _updateScores();
              });
            } else if (fieldNr == listLength - 1 && listLength > _iniLength) {
              final bool removeLast;
              if (input == null) {
                removeLast = true;
              } else if (input.isEmpty) {
                removeLast = true;
              } else {
                removeLast = false;
              }
              if (removeLast) {
                setState(() {
                  widgetList.removeLast();
                  _updateScores();
                });
              }
            }
          },
          textInputAction: TextInputAction.next,
          onSaved: (String? input) {
            if (fieldNr != listLength) {
              // Only do this if the current TextFormField is not
              // the last (empty) TextFormField
              inputValues[index] = input.toString().trim();
              widget.valuesGetter(inputValues);
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
      children: <Widget>[
        ...widgetList,
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
