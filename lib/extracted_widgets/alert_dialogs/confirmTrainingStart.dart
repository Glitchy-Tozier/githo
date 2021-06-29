import 'package:flutter/material.dart';
import 'package:githo/extracted_data/styleData.dart';

class ConfirmTrainingStart extends StatelessWidget {
  final String title;
  final String trainingDescription;
  final Function confirmationFunc;

  const ConfirmTrainingStart({
    required this.title,
    required this.trainingDescription,
    required this.confirmationFunc,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        "Tackle the next training?",
        style: StyleData.textStyle,
      ),
      content: Text(
        "To-Do: $trainingDescription",
        style: StyleData.textStyle,
      ),
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton.icon(
              icon: const Icon(
                Icons.cancel,
                color: Colors.white,
              ),
              label: Text(
                "Cancel",
                style: coloredTextStyle(Colors.white),
              ),
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.orange),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            ElevatedButton.icon(
              icon: const Icon(
                Icons.check_circle,
                color: Colors.white,
              ),
              label: Text(
                "Start",
                style: coloredTextStyle(Colors.white),
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
              ),
              onPressed: () {
                Navigator.pop(context);
                confirmationFunc();
              },
            ),
          ],
        ),
      ],
    );
  }
}
