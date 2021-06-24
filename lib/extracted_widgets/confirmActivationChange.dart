import 'package:flutter/material.dart';
import 'package:githo/extracted_data/styleData.dart';

class ConfirmActivationChange extends StatelessWidget {
  final String title;
  final String message;
  final Function confirmationFunc;

  const ConfirmActivationChange({
    required this.title,
    required this.message,
    required this.confirmationFunc,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
        style: StyleData.textStyle,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "All previous progress will be lost.",
            style: StyleData.textStyle,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                icon: Icon(
                  Icons.cancel,
                  color: Colors.orange,
                ),
                label: Text(
                  "Cancel",
                  style: coloredTextStyle(Colors.orange),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton.icon(
                icon: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
                label: Text(
                  "Confirm",
                  style: coloredTextStyle(Colors.green),
                ),
                onPressed: () {
                  confirmationFunc();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
