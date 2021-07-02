import 'package:flutter/material.dart';
import 'package:githo/extracted_data/styleData.dart';

class TextDialog extends StatelessWidget {
  final Widget title;
  final String text;
  final Color buttonColor;
  const TextDialog({
    required this.title,
    required this.text,
    required this.buttonColor,
  });
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: title,
      content: SingleChildScrollView(
        child: Text(
          text,
          style: StyleData.textStyle,
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
          child: Text(
            "Okay",
            style: StyleData.textStyle,
          ),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(buttonColor),
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
