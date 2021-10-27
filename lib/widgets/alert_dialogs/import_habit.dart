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
import 'package:githo/helpers/text_form_field_validation.dart';
import 'package:githo/widgets/alert_dialogs/base_dialog.dart';

class ImportHabit extends StatelessWidget {
  /// Returns a dialog that lets you import a habit-plan.
  ImportHabit({required this.onImport});

  final Function onImport;
  final GlobalKey<FormFieldState<String?>> formKey =
      GlobalKey<FormFieldState<String?>>();

  @override
  Widget build(BuildContext context) {
    return BaseDialog(
      title: const Text(
        'Import habit-plan',
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'Copy the habit-plan-text into the field below.',
            style: Theme.of(context).textTheme.bodyText2,
          ),
          Text(
            'This will overwrite all previous inputs.',
            style: Theme.of(context).textTheme.bodyText1,
          ),
          const SizedBox(height: 20),
          TextFormField(
            key: formKey,
            autocorrect: false,
            onFieldSubmitted: (_) => formKey.currentState!.validate(),
            validator: (final String? input) {
              final String? complaint;
              complaint = complainIfEmpty(
                input: input,
                toFillIn: 'the habit-plan text',
              );
              if (complaint == null) {
                return validateHabitPlanImport(input!);
              } else {
                return complaint;
              }
            },
            onSaved: (final String? input) {
              onImport(input!);
            },
          ),
        ],
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
                Icons.download,
              ),
              label: Text(
                'Import',
                style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      color: Colors.white,
                    ),
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  ThemedColors.lightBlue,
                ),
              ),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();

                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}
