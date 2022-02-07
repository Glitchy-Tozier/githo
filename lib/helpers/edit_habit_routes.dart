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
import 'package:timezone/timezone.dart';

import 'package:githo/database/database_helper.dart';
import 'package:githo/helpers/time_helper.dart';
import 'package:githo/models/habit_plan.dart';
import 'package:githo/models/progress_data.dart';
import 'package:githo/screens/edit_habit.dart';

/// Opens the editHabit-screen without any predefined values.
void addNewHabit(
  BuildContext context,
  final void Function() updatePrevScreens,
) {
  final HabitPlan habitPlan = HabitPlan.emptyHabitPlan();

  void _onSaved(final HabitPlan habitPlan) {
    DatabaseHelper.instance.insertHabitPlan(habitPlan).then(
          (_) => updatePrevScreens(),
        );
  }

  Navigator.push(
    context,
    MaterialPageRoute<EditHabit>(
      builder: (BuildContext context) => EditHabit(
        title: 'Add Habit-Plan',
        habitPlan: habitPlan,
        onSavedFunction: _onSaved,
        displayImportFAB: true,
      ),
    ),
  );
}

/// Sends an existing habitPlan to the editHabit-screen for you to edit.
void editHabit(
  BuildContext context,
  final void Function(HabitPlan) updatePrevScreens,
  final HabitPlan habitPlan,
) {
  void _onSaved(final HabitPlan habitPlan) {
    final TZDateTime now = TimeHelper.instance.currentTime;
    habitPlan.lastChanged = now;

    // IF the habitPlan was active, disable it to make sure
    // that nothing gets messed up by changing its values.
    if (habitPlan.isActive) {
      // Reset progressData because it should not be active.
      final ProgressData newProgressdata = ProgressData.emptyData();
      newProgressdata.save();

      habitPlan.isActive = false;
    }

    habitPlan.save();
    updatePrevScreens(habitPlan);
  }

  Navigator.push(
    context,
    MaterialPageRoute<EditHabit>(
      builder: (BuildContext context) => EditHabit(
        title: 'Edit Habit-Plan',
        habitPlan: habitPlan,
        onSavedFunction: _onSaved,
      ),
    ),
  );
}
