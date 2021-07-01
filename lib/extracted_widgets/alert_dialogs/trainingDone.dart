import 'dart:math';

import 'package:flutter/material.dart';
import 'package:githo/extracted_data/styleData.dart';

class TrainingDoneAlert extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const List<String> buttonStrings = [
      "I'm amazing",
      "Yay",
      "Nice job, me",
    ];
    final Random random = new Random();
    final String buttonString =
        buttonStrings[random.nextInt(buttonStrings.length)];

    print(random);

    return AlertDialog(
      title: const Text(
        "Training completed!",
        style: StyleData.textStyle,
      ),
      // content: Text(""),
      actions: <Widget>[
        ElevatedButton(
          child: Text(
            buttonString,
            style: coloredTextStyle(Colors.white),
          ),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
            minimumSize: MaterialStateProperty.all<Size>(
              const Size(double.infinity, 60),
            ),
            padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
              const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
