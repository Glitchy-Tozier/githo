import 'package:flutter/material.dart';

class FatDivider extends StatelessWidget {
  final Color color;
  const FatDivider({this.color = Colors.grey});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 30,
      thickness: 10,
      color: this.color,
    );
  }
}
