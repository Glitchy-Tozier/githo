import 'package:flutter/material.dart';
import 'package:githo/extracted_data/fullDatabaseImport.dart';
import 'package:githo/extracted_data/styleData.dart';
import 'package:githo/helpers/databaseHelper.dart';
import 'package:githo/models/habitPlanModel.dart';
import 'package:intl/intl.dart';

class ConfirmStartingTime extends StatefulWidget {
  final HabitPlan habitPlan;
  final Function updateFunction;

  const ConfirmStartingTime(this.habitPlan, this.updateFunction);

  @override
  _ConfirmStartingTimeState createState() =>
      _ConfirmStartingTimeState(this.habitPlan, this.updateFunction);
}

class _ConfirmStartingTimeState extends State<ConfirmStartingTime> {
  final HabitPlan habitPlan;
  final Function updateFunction;
  _ConfirmStartingTimeState(this.habitPlan, this.updateFunction);

  late DateTime startingDate;
  @override
  void initState() {
    super.initState();
    this.startingDate = _getDefaultStartingTime(widget.habitPlan);
  }

  DateTime _getDefaultStartingTime(final HabitPlan habitPlan) {
    final DateTime now = DateTime.now();
    final DateTime startingDate;

    switch (habitPlan.trainingTimeIndex) {
      case 0:
        // start on the next day, 0am
        startingDate = DateTime(
          now.year,
          now.month,
          now.day + 1,
        );
        break;
      default:
        // start on the next week, monday, 0am
        startingDate = DateTime(
          now.year,
          now.month,
          now.day + 8 - now.weekday,
        );
    }

    return startingDate;
  }

  void _updateDataBase(
    HabitPlan habitPlan,
    final DateTime startingDate,
  ) async {
    // Mark the old plan as inactive
    final List<HabitPlan> activeHabitPlanList =
        await DatabaseHelper.instance.getActiveHabitPlan();
    if (activeHabitPlanList.length > 0) {
      HabitPlan oldHabitPlan = activeHabitPlanList[0];
      oldHabitPlan.isActive = false;
      await DatabaseHelper.instance.updateHabitPlan(oldHabitPlan);
    }

    // Update (and reset) older progressData
    ProgressData progressData = await DatabaseHelper.instance.getProgressData();
    progressData.adaptToHabitPlan(startingDate, habitPlan);
    await DatabaseHelper.instance.updateProgressData(progressData);

    // Update the plan you're looking at to be active
    habitPlan.isActive = true;
    habitPlan.lastChanged = DateTime.now();
    await DatabaseHelper.instance.updateHabitPlan(habitPlan);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        "Confirm starting time",
        style: StyleData.textStyle,
      ),
      content: Text(
        "The first training will start at ",
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
                "Start",
                style: coloredTextStyle(Colors.white),
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
              ),
              onPressed: () {
                Navigator.pop(context);
                _updateDataBase(widget.habitPlan, startingDate);
                widget.updateFunction();
              },
            ),
          ],
        ),
      ],
    );
  }
}
