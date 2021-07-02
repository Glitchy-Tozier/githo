import 'package:flutter/material.dart';

class FatDivider extends StatelessWidget {
  final Color? color;
  const FatDivider({this.color});

  @override
  Widget build(BuildContext context) {
    final Color dividerColor;
    if (this.color == null) {
      dividerColor = Theme.of(context).primaryColor;
    } else {
      dividerColor = this.color!;
    }

    return Divider(
      height: 30,
      thickness: 10,
      color: dividerColor,
    );
  }
}
