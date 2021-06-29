import 'package:flutter/material.dart';
import 'package:githo/extracted_data/fullDatabaseImport.dart';
import 'package:githo/extracted_widgets/alert_dialogs/confirmActivationChange.dart';
import 'package:githo/extracted_widgets/alert_dialogs/confirmStartingTime.dart';

class ActivationFAB extends StatelessWidget {
  final HabitPlan habitPlan;
  final Function updateFunction;

  const ActivationFAB({required this.habitPlan, required this.updateFunction});

  void onClickFunc(BuildContext context) async {
    if (habitPlan.isActive == true) {
      // If the viewed habetPlan was active to begin with, disable it.
      void onConfirmation() async {
        // Update habitPlan
        this.habitPlan.isActive = false;
        await DatabaseHelper.instance.updateHabitPlan(this.habitPlan);

        // Update progressData
        ProgressData progressData =
            await DatabaseHelper.instance.getProgressData();
        progressData = ProgressData.emptyData();
        await DatabaseHelper.instance.updateProgressData(progressData);

        // Update previous screens and close screen
        updateFunction(habitPlan);
      }

      showDialog(
        context: context,
        builder: (BuildContext buildContext) => ConfirmActivationChange(
          title: "Confirm Deactivation",
          confirmationFunc: onConfirmation,
        ),
      );
    } else {
      // If the viewed habitPlan wasn't active, activate it.

      void onConfirmation() async {
        showDialog(
          context: context,
          builder: (BuildContext buildContext) => ConfirmStartingTime(
            habitPlan,
            updateFunction,
          ),
        );
      }

      showDialog(
        context: context,
        builder: (BuildContext buildContext) => ConfirmActivationChange(
          title: "Confirm Activation",
          confirmationFunc: onConfirmation,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Icon child;
    if (habitPlan.isActive == true) {
      child = const Icon(Icons.star_outline);
    } else {
      child = const Icon(Icons.star);
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
