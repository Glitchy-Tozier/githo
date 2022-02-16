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
import 'package:githo/database/database_helper.dart';
import 'package:githo/helpers/notification_helper.dart';
import 'package:githo/models/habit_plan.dart';
import 'package:githo/models/progress_data.dart';
import 'package:githo/widgets/alert_dialogs/confirm_activation_change.dart';
import 'package:githo/widgets/alert_dialogs/confirm_starting_time.dart';

class ActivationFAB extends StatelessWidget {
  /// The middle FloatingActionButton in the habitDetals.dart-screen.
  /// It's used to activate/deactivate the viewed habit.
  const ActivationFAB({
    required this.habitPlan,
    required this.updateFunction,
  });

  final HabitPlan habitPlan;
  final void Function(HabitPlan) updateFunction;

  Future<void> onClickFunc(BuildContext context) async {
    if (habitPlan.isActive == true) {
      // If the viewed habitPlan was active to begin with, disable it.
      Future<void> deactivateHabitPlan() async {
        // Update habitPlan
        habitPlan.isActive = false;
        await habitPlan.save();

        // Clear progressData
        await ProgressData.emptyData().save();

        // If ProgressData gets reset, so should everything notifications-
        // related.
        await annihilateNotifcations();

        // Update previous screens
        updateFunction(habitPlan);
      }

      await showDialog(
        context: context,
        builder: (BuildContext buildContext) => ConfirmActivationChange(
          title: 'Confirm Deactivation',
          content: Text(
            'All progress will be lost.',
            style: Theme.of(context).textTheme.bodyText2,
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
        await showDialog(
          context: context,
          builder: (BuildContext buildContext) => ConfirmActivationChange(
            title: 'Confirm Activation',
            content: RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(
                    text: 'Your previous habit-plan ',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  TextSpan(
                    text: '(Habit: ${progressData.habit})',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  TextSpan(
                    text: ' will be deactivated.',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                ],
              ),
            ),
            onConfirmation: showStrartingTimePicker,
          ),
        );
      } else {
        // If no challenge is active, there is no need to display
        // a warning popup -> go straight to the starting-time-dialouge.
        showStrartingTimePicker();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String tooltip;
    if (habitPlan.isActive == true) {
      tooltip = 'Deactivate';
    } else {
      tooltip = 'Activate';
    }

    final Icon child;
    final Color color;

    if (habitPlan.isActive == true) {
      color = Theme.of(context).primaryColor;
      child = const Icon(
        Icons.star,
      );
    } else {
      color = ThemedColors.green;
      child = const Icon(
        Icons.play_arrow,
      );
    }

    if (habitPlan.isActive == true) {
    } else {}

    return FloatingActionButton(
      tooltip: tooltip,
      backgroundColor: color,
      onPressed: () => onClickFunc(context),
      heroTag: null,
      child: child,
    );
  }
}
