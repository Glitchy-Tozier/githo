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

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:githo/config/custom_widget_themes.dart';
import 'package:githo/widgets/alert_dialogs/base_dialog.dart';

/// Notifies the user of his success.

class TrainingDoneAlert extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const List<String> buttonStrings = <String>[
      "I'm amazing",
      'Yay',
      'Nice job, me',
    ];
    final Random random = Random();
    final String buttonString =
        buttonStrings[random.nextInt(buttonStrings.length)];

    return BaseDialog(
      title: const Text(
        'Training completed!',
      ),
      actions: <ElevatedButton>[
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all<Color>(ThemedColors.green),
            minimumSize: MaterialStateProperty.all<Size>(
              const Size(double.infinity, 60),
            ),
            padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
              const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            ),
          ),
          onPressed: () => Navigator.pop(context),
          child: Text(
            buttonString,
            style: Theme.of(context).textTheme.bodyText1!.copyWith(
                  color: Colors.white,
                ),
          ),
        ),
      ],
    );
  }
}
