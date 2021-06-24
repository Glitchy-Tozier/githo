import 'package:flutter/material.dart';
import 'package:githo/extracted_data/fullDatabaseImport.dart';
import 'package:githo/extracted_data/styleData.dart';
import 'package:githo/helpers/databaseHelper.dart';
import 'package:githo/models/habitPlanModel.dart';

class ConfirmDeletion extends StatelessWidget {
  final HabitPlan habitPlan;
  final Function updateFunc;
  const ConfirmDeletion(this.habitPlan, this.updateFunc);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        "Confirm deletion",
        style: StyleData.textStyle,
      ),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            icon: Icon(
              Icons.cancel,
              color: Colors.orange,
            ),
            label: Text(
              "Cancel",
              style: coloredTextStyle(Colors.orange),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton.icon(
            icon: Icon(
              Icons.delete,
              color: Colors.red,
            ),
            label: Text(
              "Delete",
              style: coloredTextStyle(Colors.red),
            ),
            onPressed: () async {
              DatabaseHelper.instance.deleteHabitPlan(habitPlan.id!);

              ProgressData progressData =
                  await DatabaseHelper.instance.getProgressData();
              progressData = ProgressData.emptyData();
              DatabaseHelper.instance.updateProgressData(progressData);

              updateFunc();
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
