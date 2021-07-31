import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:githo/extracted_data/styleData.dart';

class BackgroundWidget extends StatelessWidget {
  // Returns a background and places the child in the foreground.

  final Widget child;

  const BackgroundWidget({
    this.child = const SizedBox(),
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/pixabayColorGradient.jpg"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Padding(
          padding: StyleData.screenPadding * 0.5,
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 5,
                sigmaY: 5,
              ),
              child: Container(
                color: Colors.white70,
              ),
            ),
          ),
        ),
        // Content
        child,
      ],
    );
  }
}
