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
import 'package:githo/config/custom_widget_themes.dart';
import 'package:githo/widgets/alert_dialogs/base_dialog.dart';

class ConfirmEdit extends StatelessWidget {
  /// Returns a dialog that asks 'Do you really want to edit the habit-plan?'
  const ConfirmEdit({required this.onConfirmation});

  final Function onConfirmation;

  @override
  Widget build(BuildContext context) {
    return BaseDialog(
      title: const Text(
        'Edit current habit-plan?',
      ),
      content: RichText(
        text: TextSpan(
          children: <TextSpan>[
            const TextSpan(
              text: 'By changing something, ',
            ),
            TextSpan(
              text: 'all previous progress will be lost.\n',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            const TextSpan(
              text: '\n'
                  'You will need to re-activate the '
                  'habit-plan after editing it.',
            ),
          ],
        ),
      ),
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <ElevatedButton>[
            ElevatedButton.icon(
              icon: const Icon(
                Icons.cancel,
              ),
              label: Text(
                'Cancel',
                style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      color: Colors.white,
                    ),
              ),
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(ThemedColors.orange),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton.icon(
              icon: const Icon(
                Icons.edit,
              ),
              label: Text(
                'Edit',
                style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      color: Colors.white,
                    ),
              ),
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(ThemedColors.green),
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
