import 'package:flutter/material.dart';
import 'package:githo/extracted_functions/textFormFieldHelpers.dart';

class FormList extends StatefulWidget {
  final String fieldName;
  final Function valuesGetter;
  final List<String> inputList;

  FormList({
    required this.fieldName,
    required this.valuesGetter,
    required this.inputList,
  });

  @override
  _FormListState createState() => _FormListState(
        fieldName,
        valuesGetter,
        inputList,
      );
}

class _FormListState extends State<FormList> {
  // A function that sends back the values.
  final int _iniLength = 2;

  List<Widget> _inputFields = [];
  int listLength = 0;
  late List<String> inputValues;

  final Function exportValues;
  _FormListState(String name, this.exportValues, List<String> initValues) {
    // Prepare the value-data
    initValues.add("");

    // Generate the TextFormFields
    for (int i = 0; i < initValues.length; i++) {
      this._inputFields.add(_textFormField(name, i, initValues[i]));
    }
    _updateScores();
  }

  void _updateScores() {
    this.listLength = _inputFields.length;
    this.inputValues = new List.generate(this.listLength - 1, (index) => "");
  }

  Widget _textFormField(String name, int index, String value) {
    int fieldNr = index + 1;
    String fieldName = "$name $fieldNr"; //name + " " + fieldNr.toString();

    return Column(
      children: [
        TextFormField(
          initialValue: value,
          decoration: inputDecoration(fieldName),
          validator: (input) {
            if (fieldNr != this.listLength) {
              return checkIfEmpty(
                input.toString().trim(),
                fieldName,
              );
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
          onSaved: (input) {
            if (fieldNr != this.listLength) {
              // Only do this if the current TextFormField is not the last (empty) TextFormField
              this.inputValues[index] = input.toString().trim();
              exportValues(inputValues);
            }
          },
        ),
        SizedBox(height: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      ...this._inputFields,
      Text("⋮",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          )),
      SizedBox(
        height: 10,
      ),
    ]);
  }
}
