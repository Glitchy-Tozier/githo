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

import 'package:githo/extracted_widgets/alert_dialogs/confirmActivationChange.dart';
import 'package:githo/extracted_widgets/alert_dialogs/confirmStartingTime.dart';
import 'package:githo/helpers/databaseHelper.dart';
import 'package:githo/models/habitPlanModel.dart';
import 'package:githo/models/progressDataModel.dart';

class ActivationFAB extends StatelessWidget {
  final HabitPlan habitPlan;
  final Function updateFunction;

  /// The middle FloatingActionButton in the habitDetals.dart-screen.
  /// It's used to activate/deactivate the viewed habit.
  const ActivationFAB({
    required this.habitPlan,
    required this.updateFunction,
  });

  void onClickFunc(BuildContext context) async {
    if (habitPlan.isActive == true) {
      // If the viewed habitPlan was active to begin with, disable it.
      void deactivateHabitPlan() async {
        // Update habitPlan
        this.habitPlan.isActive = false;
        await DatabaseHelper.instance.updateHabitPlan(this.habitPlan);

        // Clear progressData
        final ProgressData progressData = ProgressData.emptyData();
        await DatabaseHelper.instance.updateProgressData(progressData);

        // Update previous screens
        updateFunction(this.habitPlan);
      }

      showDialog(
        context: context,
        builder: (BuildContext buildContext) => ConfirmActivationChange(
          title: "Confirm Deactivation",
          content: const Text(
            "All progress will be lost.",
            style: StyleData.textStyle,
          ),
          onConfirmation: () {
            deactivateHabitPlan();
            Navigator.pop(context); // Pop habit-details
          },
        ),
      );
    } else {
      // If the viewed habitPlan wasn't active, activate it.

      void showStrartingTimePicker() {
        void popToHome(final HabitPlan habitPlan) {
          // Update homescreen
          updateFunction(habitPlan);
          // Move to homescreen
          Navigator.pop(context); // Pop habit-details
          Navigator.pop(context); // Pop habit-list
        }

        showDialog(
          context: context,
          builder: (BuildContext buildContext) => ConfirmStartingTime(
            habitPlan: habitPlan,
            onConfirmation: popToHome,
          ),
        );
      }

      final ProgressData progressData =
          await DatabaseHelper.instance.getProgressData();

      if (progressData.isActive) {
        showDialog(
          context: context,
          builder: (BuildContext buildContext) => ConfirmActivationChange(
            title: "Confirm Activation",
            content: RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: "Your previous habit-plan ",
                    style: StyleData.textStyle,
                  ),
                  TextSpan(
                    text: "(Habit: ${progressData.habit})",
                    style: StyleData.boldTextStyle,
                  ),
                  const TextSpan(
                    text: " will be deactivated.",
                    style: StyleData.textStyle,
                  ),
                ],
              ),
            ),
            onConfirmation: showStrartingTimePicker,
          ),
        );
      } else {
        // If no challenge is active, there is no need to display a warning popup -> go straight to the starting-time-dialouge.
        showStrartingTimePicker();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String tooltip;
    if (habitPlan.isActive == true) {
      tooltip = "Deactivate habit-plan";
    } else {
      tooltip = "Activate habit-plan";
    }

    final Icon child;
    if (habitPlan.isActive == true) {
      child = const Icon(
        Icons.star_outline,
        color: Colors.white,
      );
    } else {
      child = const Icon(
        Icons.star,
        color: Colors.white,
      );
    }

    final Color color;
    if (habitPlan.isActive == true) {
      color = Colors.black;
    } else {
      color = Colors.green;
    }

    return FloatingActionButton(
      tooltip: tooltip,
      child: child,
      backgroundColor: color,
      onPressed: () => onClickFunc(context),
      heroTag: null,
    );
  }
}
