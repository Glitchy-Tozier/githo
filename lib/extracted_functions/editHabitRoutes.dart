import 'package:flutter/material.dart';

import 'package:githo/helpers/databaseHelper.dart';
import 'package:githo/models/habitPlan_model.dart';
import 'package:githo/screens/editHabit.dart';

// Open the editHabit-screen and add a new habitPlan using whatever you type in
void addNewHabit(
  BuildContext context,
  Function updatePrevScreens,
) {
  HabitPlan habitPlan = HabitPlan(
    isActive: false,
    // TextFormFields:
    goal: "",
    reps: 1,
    challenges: [""],
    rules: [""],
    // Sliders:
    timeIndex: 1,
    activity: 5,
    requiredRepeats: 2,
  );

  void _onSaved(HabitPlan habitPlan) {
    DatabaseHelper.instance.insertHabitPlan(habitPlan);
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

// Sent an existing habitPlan to the editHabit-screen and edit it
void editHabit(
  BuildContext context,
  Function updatePrevScreens,
  HabitPlan habitPlan,
) {
  void _onSaved(HabitPlan habitPlan) {
    DatabaseHelper.instance.updateHabitPlan(habitPlan);
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
