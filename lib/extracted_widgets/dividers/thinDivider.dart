import 'package:flutter/material.dart';
import 'package:githo/extracted_data/styleData.dart';

class ThinDivider extends StatelessWidget {
  final Color color;
  const ThinDivider({this.color = Colors.black54});

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: this.color,
      indent: StyleData.screenPaddingValue * 0.5,
      endIndent: StyleData.screenPaddingValue * 0.5,
    );
  }
}
