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
import 'package:githo/config/styleData.dart';

class ConfirmEdit extends StatelessWidget {
  final Function onConfirmation;

  /// Returns a dialog that asks "Do you really want to edit the habit-plan?"
  const ConfirmEdit({required this.onConfirmation});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        "Confirm edit",
        style: StyleData.textStyle,
      ),
      content: const Text(
        "By changing something, all previous progress will be lost.\n\nYou will need to re-activate the habit-plan after editing it.",
        style: StyleData.textStyle,
      ),
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton.icon(
              icon: const Icon(
                Icons.cancel,
                color: Colors.white,
              ),
              label: const Text(
                "Cancel",
                style: StyleData.whiteTextStyle,
              ),
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.orange),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton.icon(
              icon: const Icon(
                Icons.edit,
                color: Colors.white,
              ),
              label: const Text(
                "Edit",
                style: StyleData.whiteTextStyle,
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
              ),
              onPressed: () {
                Navigator.pop(context);
                onConfirmation();
              },
            ),
          ],
        ),
      ],
    );
  }
}
