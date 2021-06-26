import 'package:flutter/material.dart';
import 'package:githo/extracted_data/styleData.dart';

class ConfirmActivationChange extends StatelessWidget {
  final String title;
  final Function confirmationFunc;

  const ConfirmActivationChange({
    required this.title,
    required this.confirmationFunc,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
        style: StyleData.textStyle,
      ),
      content: const Text(
        "All previous progress will be lost.",
        style: StyleData.textStyle,
      ),
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton.icon(
              icon: Icon(
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
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton.icon(
              icon: Icon(
                Icons.check_circle,
                color: Colors.white,
              ),
              label: Text(
                "Confirm",
                style: coloredTextStyle(Colors.white),
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
              ),
              onPressed: () {
                confirmationFunc();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ],
    );
  }
}
