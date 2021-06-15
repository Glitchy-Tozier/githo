import 'package:flutter/material.dart';
import 'package:githo/extracted_data/styleData.dart';

class AppInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          "App Info",
          style: StyleData.textStyle,
        ),
      ),
    );
  }
}
