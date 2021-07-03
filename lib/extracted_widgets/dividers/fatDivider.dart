import 'package:flutter/material.dart';
import 'package:githo/extracted_data/styleData.dart';

class FatDivider extends StatelessWidget {
  final Color color;
  const FatDivider({this.color = Colors.black54});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 30,
      thickness: 10,
      color: this.color,
      indent: StyleData.screenPaddingValue * 0.5,
      endIndent: StyleData.screenPaddingValue * 0.5,
    );
  }
}
