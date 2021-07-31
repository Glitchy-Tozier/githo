import 'package:flutter/material.dart';
import 'package:githo/extracted_data/styleData.dart';

class CustomListTile extends StatelessWidget {
  // A list-item used in the habitDetails.dart-screen.

  final Widget leadingWidget;
  final String title;

  const CustomListTile({
    required this.leadingWidget,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        leadingWidget,
        Flexible(
          child: Text(
            title,
            style: StyleData.textStyle,
          ),
        ),
      ],
    );
  }
}
