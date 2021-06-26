import 'package:flutter/material.dart';

class SliderTitle extends StatelessWidget {
  final List<List<String>> textDataPairs;

  const SliderTitle(this.textDataPairs);

  @override
  Widget build(BuildContext context) {
    List<TextSpan> textSpanList = [];

    // Style the spans according to the input
    textDataPairs.forEach((textSpanData) {
      String style = textSpanData[0];
      String text = textSpanData[1];
      if (style == "normal") {
        textSpanList.add(
          TextSpan(
            text: text,
            style: TextStyle(
              fontSize: 18,
              color: Colors.black,
            ),
          ),
        );
      } else if (style == "bold") {
        textSpanList.add(
          TextSpan(
            text: text,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        );
      } else {
        print("(SliderTitle:) That style was not yet implemented.");
      }
    });

    // Build/return widgets
    return RichText(
      text: TextSpan(
        children: textSpanList,
      ),
    );
  }
}
