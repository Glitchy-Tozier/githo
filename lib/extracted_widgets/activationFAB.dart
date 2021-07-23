import 'package:flutter/material.dart';
import 'package:githo/extracted_data/styleData.dart';

import 'package:githo/extracted_widgets/alert_dialogs/confirmActivationChange.dart';
import 'package:githo/extracted_widgets/alert_dialogs/confirmStartingTime.dart';
import 'package:githo/helpers/databaseHelper.dart';
import 'package:githo/models/habitPlanModel.dart';
import 'package:githo/models/progressDataModel.dart';
import 'package:githo/screens/homeScreen.dart';

class ActivationFAB extends StatelessWidget {
  final HabitPlan habitPlan;
  final Function updateFunction;

  const ActivationFAB({required this.habitPlan, required this.updateFunction});

  void onClickFunc(BuildContext context) async {
    if (habitPlan.isActive == true) {
      // If the viewed habetPlan was active to begin with, disable it.
      void deactivateHabitPlan() async {
        // Update habitPlan
        this.habitPlan.isActive = false;
        await DatabaseHelper.instance.updateHabitPlan(this.habitPlan);

        // Clear progressData
        final ProgressData progressData = ProgressData.emptyData();
        await DatabaseHelper.instance.updateProgressData(progressData);

        // Update previous screens and close screen
        updateFunction(habitPlan);
      }

      showDialog(
        context: context,
        builder: (BuildContext buildContext) => ConfirmActivationChange(
          title: "Confirm Deactivation",
          content: const Text(
            "All previous progress will be lost.",
            style: StyleData.textStyle,
          ),
          confirmationFunc: deactivateHabitPlan,
        ),
      );
    } else {
      // If the viewed habitPlan wasn't active, activate it.

      void showStrartingTimePicker() async {
        void popToHome(final HabitPlan habitPlan) {
          // Move to homescreen
          // For some reason, this also results in the homescreen updating itself automatically.
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) {
                return HomeScreen();
              },
              settings: const RouteSettings(
                name: '/home',
              ),
            ),
          );
        }

        showDialog(
          context: context,
          builder: (BuildContext buildContext) => ConfirmStartingTime(
            habitPlan,
            popToHome,
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
                    text: "(Habit: ${progressData.goal})",
                    style: StyleData.boldTextStyle,
                  ),
                  const TextSpan(
                    text: " will be deactivated.",
                    style: StyleData.textStyle,
                  ),
                ],
              ),
            ),
            confirmationFunc: showStrartingTimePicker,
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
      child: child,
      backgroundColor: color,
      onPressed: () => onClickFunc(context),
      heroTag: null,
    );
  }
}
