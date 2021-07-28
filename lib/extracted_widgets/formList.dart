import 'package:flutter/material.dart';
import 'package:githo/extracted_functions/textFormFieldHelpers.dart';

class FormList extends StatefulWidget {
  final String fieldName;
  final bool canBeEmpty;
  final Function valuesGetter;
  final List<String> inputList;

  FormList({
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
  // A function that sends back the values.
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
          maxLength: 150,
          validator: (input) {
            if (canBeEmpty == true) {
              // Use This validation if the fields are optional
              if ((fieldNr != this.listLength) &&
                  (this.listLength > this._iniLength)) {
                return checkIfEmpty(
                  input.toString().trim(),
                  fieldName,
                );
              }
            } else {
              // Use this validation if at least one field NEEDS to be filled out.
              if (fieldNr != this.listLength) {
                return checkIfEmpty(
                  input.toString().trim(),
                  fieldName,
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
