import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  final String? leadingString;
  final Widget? leadingWidget;
  final String title;
  const CustomListTile(
      {this.leadingString, this.leadingWidget, required this.title});

  @override
  Widget build(BuildContext context) {
    final Widget leading;
    if (this.leadingString != null) {
      if (this.leadingWidget != null) {
        const String error =
            "ERROR: CustomListTile: Only input EITHER leadingString OR leadingWidget, never both.";
        print(error);
        leading = Text(error);
      } else {
        leading = Text(
          this.leadingString as String,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        );
      }
    } else {
      if (this.leadingWidget != null) {
        leading = leadingWidget as Widget;
      } else {
        const String error =
            "ERROR: CustomListTile: Too few arguments. Input leadingString OR leadingWidget.";
        leading = Text(error);
        print(error);
      }
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        leading,
        Flexible(
          child: Text(
            title,
            //overflow: TextOverflow.,
          ),
        ),
      ],
    );
    /* ListTile(
      leading: leading,
      title: Text(title),
      horizontalTitleGap: -10,
      contentPadding: EdgeInsets.only(left: 5),
    ); */
  }
}
