import 'package:flutter/material.dart';

class StyleData {
  static const double screenPaddingValue = 35;

  static const EdgeInsets screenPadding =
      EdgeInsets.symmetric(horizontal: screenPaddingValue);

  static const EdgeInsets floatingActionButtonPadding =
      EdgeInsets.symmetric(horizontal: 16);

  static const double listRowSpacing = 8;

  static const TextStyle textStyle = TextStyle(
    fontSize: 16,
    color: Colors.black,
  );
  static const TextStyle boldTextStyle = TextStyle(
    fontSize: 16,
    color: Colors.black,
    fontWeight: FontWeight.bold,
  );
}

TextStyle coloredTextStyle(final Color color) {
  return TextStyle(
    fontSize: 16,
    color: color,
  );
}

TextStyle coloredBoldTextStyle(final Color color) {
  return TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: color,
  );
}
