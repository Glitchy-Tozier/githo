/* 
 * Githo – An app that helps you form long-lasting habits, one step at a time.
 * Copyright (C) 2021 Florian Thaler
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

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
