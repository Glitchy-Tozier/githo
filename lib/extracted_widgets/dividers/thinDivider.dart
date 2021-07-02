import 'package:flutter/material.dart';

class ThinDivider extends StatelessWidget {
  final Color color;
  const ThinDivider({this.color = Colors.grey});

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: this.color,
    );
  }
}
