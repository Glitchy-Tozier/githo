import 'package:flutter/material.dart';
import 'package:githo/extracted_data/styleData.dart';
import 'package:githo/helpers/databaseHelper.dart';
import 'package:githo/models/habitPlanModel.dart';
import 'package:githo/models/progressDataModel.dart';

class ConfirmDeletion extends StatelessWidget {
  final HabitPlan habitPlan;
  final Function updateFunction;

  const ConfirmDeletion(this.habitPlan, this.updateFunction);

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
              label: Text(
                "Cancel",
                style: coloredTextStyle(Colors.white),
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
              label: Text(
                "Delete",
                style: coloredTextStyle(Colors.white),
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
              ),
              onPressed: () async {
                final ProgressData progressData = ProgressData.emptyData();
                DatabaseHelper.instance.updateProgressData(progressData);

                await DatabaseHelper.instance.deleteHabitPlan(habitPlan.id!);

                updateFunction();

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
