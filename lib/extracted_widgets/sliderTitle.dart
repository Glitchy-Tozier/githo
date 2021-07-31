import 'package:flutter/material.dart';

class SliderTitle extends StatelessWidget {
  // Creates the titles for the sliders in the EditHabit.dart-screen.
  // Specify how the sub-elements should look by using "normal" or "bold".

  final List<List<String>> textDataPairs;
  const SliderTitle(this.textDataPairs);

  @override
  Widget build(BuildContext context) {
    final List<TextSpan> textSpanList = [];

    // Style the spans according to the input
    textDataPairs.forEach((textSpanData) {
      String style = textSpanData[0];
      String text = textSpanData[1];
      if (style == "normal") {
        textSpanList.add(
          TextSpan(
            text: text,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black,
            ),
          ),
        );
      } else if (style == "bold") {
        textSpanList.add(
          TextSpan(
            text: text,
            style: const TextStyle(
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
    return SizedBox(
      width: double.infinity,
      child: Center(
        child: RichText(
          text: TextSpan(
            children: textSpanList,
          ),
        ),
      ),
    );
  }
}
