import 'package:flutter/material.dart';
import 'package:githo/extracted_data/styleData.dart';

class BulletPoint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Text(
      "•  ",
      style: StyleData.boldTextStyle,
    );
  }
}
