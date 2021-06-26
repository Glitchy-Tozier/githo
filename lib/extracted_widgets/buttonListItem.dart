import 'package:flutter/material.dart';
import 'package:githo/extracted_data/styleData.dart';

class ButtonListItem extends StatelessWidget {
  final String text;
  final Color color;
  final Function onPressed;

  const ButtonListItem({
    required this.text,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: ElevatedButton(
        child: Text(
          text,
          style: coloredTextStyle(Colors.white),
        ),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(color),
          minimumSize: MaterialStateProperty.all<Size>(
            const Size(double.infinity, 60),
          ),
          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
            const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          ),
        ),
        onPressed: () => onPressed(),
      ),
    );
  }
}
