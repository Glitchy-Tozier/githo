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
import 'package:githo/extracted_data/styleData.dart';
import 'package:githo/helpers/databaseHelper.dart';
import 'package:githo/models/habitPlanModel.dart';
import 'package:githo/models/progressDataModel.dart';

class ConfirmDeletion extends StatelessWidget {
  // Returns a dialog that asks "Do you really want to delete the habit-plan?"
  // If the user says yes, the habit-plan is deleted.

  final HabitPlan habitPlan;
  final Function onConfirmation;

  const ConfirmDeletion({
    required this.habitPlan,
    required this.onConfirmation,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        "Confirm deletion",
        style: StyleData.textStyle,
      ),
      content: const Text(
        "All previous progress will be lost.",
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
                Navigator.pop(context);
              },
            ),
            ElevatedButton.icon(
              icon: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
              label: const Text(
                "Delete",
                style: StyleData.whiteTextStyle,
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
              ),
              onPressed: () async {
                final ProgressData progressData = ProgressData.emptyData();
                DatabaseHelper.instance.updateProgressData(progressData);

                await DatabaseHelper.instance.deleteHabitPlan(habitPlan.id!);

                onConfirmation();

                Navigator.pop(context); // Pop dialog
                Navigator.pop(context); // Pop habit-details-screen
              },
            ),
          ],
        ),
      ],
    );
  }
}
