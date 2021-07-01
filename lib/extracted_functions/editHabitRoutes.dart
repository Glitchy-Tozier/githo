import 'package:flutter/material.dart';

import 'package:githo/helpers/databaseHelper.dart';
import 'package:githo/models/habitPlanModel.dart';
import 'package:githo/models/progressDataModel.dart';
import 'package:githo/screens/editHabit.dart';

// Open the editHabit-screen and add a new habitPlan using whatever you type in
void addNewHabit(
  BuildContext context,
  final Function updatePrevScreens,
) {
  HabitPlan habitPlan = HabitPlan(
    isActive: false,
    // TextFormFields:
    goal: "",
    requiredReps: 1,
    steps: <String>[""],
    comments: <String>[""],
    // Sliders:
    trainingTimeIndex: 1,
    requiredTrainings: 5,
    requiredTrainingPeriods: 1,
    lastChanged: DateTime.now(),
  );

  void _onSaved(HabitPlan habitPlan) async {
    await DatabaseHelper.instance.insertHabitPlan(habitPlan);
    updatePrevScreens();
  }

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => EditHabit(
        habitPlan: habitPlan,
        onSavedFunction: _onSaved,
      ),
    ),
  );
}

// Sent an existing habitPlan to the editHabit-screen and edit it
void editHabit(
  BuildContext context,
  final Function updatePrevScreens,
  final HabitPlan habitPlan,
) {
  void _onSaved(final HabitPlan habitPlan) async {
    habitPlan.lastChanged = DateTime.now();

    // Reset progressData because it should not be active.
    DatabaseHelper.instance.updateProgressData(ProgressData.emptyData());

    // Disable the habitPlan to make sure nothing gets messed up by changing its values.
    habitPlan.isActive = false;
    await DatabaseHelper.instance.updateHabitPlan(habitPlan);

    updatePrevScreens(habitPlan);
  }

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => EditHabit(
        habitPlan: habitPlan,
        onSavedFunction: _onSaved,
      ),
    ),
  );
}
