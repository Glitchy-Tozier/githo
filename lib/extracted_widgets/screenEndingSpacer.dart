import 'package:flutter/material.dart';

class ScreenEndingSpacer extends StatelessWidget {
  // Returns a SizedBox of a prespecified height.
  // Used to make sure the FloatingActionButtons can't cover important screen-contents.

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 85);
  }
}
