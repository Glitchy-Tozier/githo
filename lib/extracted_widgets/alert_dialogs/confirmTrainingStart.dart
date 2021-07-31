import 'package:flutter/material.dart';
import 'package:githo/extracted_data/styleData.dart';
import 'package:githo/models/used_classes/training.dart';

class ConfirmTrainingStart extends StatelessWidget {
  // Returns a dialog that lets the user confirm that he really wants to start the current training.

  final String title;
  final String toDo;
  final Training training;
  final Function onConfirmation;

  const ConfirmTrainingStart({
    required this.title,
    required this.toDo,
    required this.training,
    required this.onConfirmation,
  });

  @override
  Widget build(BuildContext context) {
    final String amountString;
    if (training.requiredReps == 1) {
      amountString = "Perform once";
    } else {
      amountString = "Perform ${training.requiredReps} times";
    }

    return AlertDialog(
      title: const Text(
        "Tackle the next training?",
        style: StyleData.textStyle,
      ),
      content: Text(
        "To-Do: $toDo\n\nReps: $amountString",
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
                onConfirmation();
              },
            ),
          ],
        ),
      ],
    );
  }
}
