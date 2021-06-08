import 'package:flutter/material.dart';

class ScreenTitle extends StatelessWidget {
  final String titleText;
  ScreenTitle(this.titleText);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(height: 30),
      Text(
        titleText,
        style: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: 30),
    ]);
  }
}
