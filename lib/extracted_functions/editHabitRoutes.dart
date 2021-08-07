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

import 'package:githo/helpers/databaseHelper.dart';
import 'package:githo/helpers/timeHelper.dart';
import 'package:githo/models/habitPlanModel.dart';
import 'package:githo/models/progressDataModel.dart';
import 'package:githo/screens/editHabit.dart';

// Open the editHabit-screen and add a new habitPlan using whatever you type in
void addNewHabit(
  BuildContext context,
  final Function updatePrevScreens,
) {
  final DateTime now = TimeHelper.instance.currentTime;

  final HabitPlan habitPlan = HabitPlan(
    isActive: false,
    fullyCompleted: false,
    // TextFormFields:
    habit: "",
    requiredReps: 1,
    steps: const <String>[""],
    comments: const <String>[""],
    // Sliders:
    trainingTimeIndex: 1,
    requiredTrainings: 5,
    requiredTrainingPeriods: 1,
    lastChanged: now,
  );

  void _onSaved(final HabitPlan habitPlan) {
    DatabaseHelper.instance.insertHabitPlan(habitPlan).then(
          (_) => updatePrevScreens(),
        );
  }

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => EditHabit(
        title: "Add Habit-Plan",
        habitPlan: habitPlan,
        onSavedFunction: _onSaved,
      ),
    ),
  );
}

// Send an existing habitPlan to the editHabit-screen and edit it there
void editHabit(
  BuildContext context,
  final Function updatePrevScreens,
  final HabitPlan habitPlan,
) {
  void _onSaved(final HabitPlan habitPlan) {
    final DateTime now = TimeHelper.instance.currentTime;
    habitPlan.lastChanged = now;

    // IF the habitPlan was active, disable it to make sure nothing gets messed up by changing its values.
    if (habitPlan.isActive) {
      // Reset progressData because it should not be active.
      DatabaseHelper.instance.updateProgressData(ProgressData.emptyData());
      habitPlan.isActive = false;
    }

    DatabaseHelper.instance.updateHabitPlan(habitPlan);
    updatePrevScreens(habitPlan);
  }

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => EditHabit(
        title: "Edit Habit-Plan",
        habitPlan: habitPlan,
        onSavedFunction: _onSaved,
      ),
    ),
  );
}
