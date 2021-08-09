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

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:githo/extracted_data/styleData.dart';

/// Notifies the user of his success.

class TrainingDoneAlert extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const List<String> buttonStrings = [
      "I'm amazing",
      "Yay",
      "Nice job, me",
    ];
    final Random random = Random();
    final String buttonString =
        buttonStrings[random.nextInt(buttonStrings.length)];

    return AlertDialog(
      title: const Text(
        "Training completed!",
        style: StyleData.textStyle,
      ),
      actions: <Widget>[
        ElevatedButton(
          child: Text(
            buttonString,
            style: StyleData.whiteTextStyle,
          ),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
            minimumSize: MaterialStateProperty.all<Size>(
              const Size(double.infinity, 60),
            ),
            padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
              const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
