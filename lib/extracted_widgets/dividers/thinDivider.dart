import 'package:flutter/material.dart';

class ThinDivider extends StatelessWidget {
  final Color? color;
  const ThinDivider({this.color});

  @override
  Widget build(BuildContext context) {
    final Color dividerColor;
    if (this.color == null) {
      dividerColor = Theme.of(context).primaryColor;
    } else {
      dividerColor = this.color!;
    }
    return Divider(
      color: dividerColor,
    );
  }
}
