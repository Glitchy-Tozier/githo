/* 
 * Githo – An app that helps you gradually form long-lasting habits.
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
import 'package:githo/config/style_data.dart';
import 'package:githo/widgets/headings/heading.dart';

class TextSheet extends StatelessWidget {
  /// Returns a bottom-sheet containing the input title and text(span).
  const TextSheet({
    required this.title,
    required this.text,
    Key? key,
  }) : super(key: key);

  final String title;
  final TextSpan text;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Colors.deepOrange.shade300,
            Colors.pinkAccent.shade400,
            Colors.purple.shade900,
          ],
        ),
      ),
      child: Container(
        padding: const EdgeInsets.only(
          right: StyleData.screenPaddingValue,
          bottom: 30,
          left: StyleData.screenPaddingValue,
        ),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
          color: Colors.white70,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: double.infinity,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 9),
              child: Container(
                width: 100,
                height: 2,
                color: Colors.pink,
              ),
            ),
            Heading(title),
            RichText(
              overflow: TextOverflow.ellipsis,
              maxLines: 8,
              text: text,
            ),
          ],
        ),
      ),
    );
  }
}
