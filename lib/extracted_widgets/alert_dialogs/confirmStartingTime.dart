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
import 'package:flutter/services.dart';

import 'package:githo/extracted_data/styleData.dart';
import 'package:githo/extracted_functions/formatDate.dart';
import 'package:githo/extracted_functions/textFormFieldHelpers.dart';
import 'package:githo/helpers/databaseHelper.dart';
import 'package:githo/helpers/timeHelper.dart';
import 'package:githo/models/habitPlanModel.dart';
import 'package:githo/models/progressDataModel.dart';

class ConfirmStartingTime extends StatefulWidget {
  final HabitPlan habitPlan;
  final Function onConfirmation;

  /// Returns a dialog that lets the user choose
  /// 1. when his journey will start
  /// 2. what step it should start with
  const ConfirmStartingTime({
    required this.habitPlan,
    required this.onConfirmation,
  });

  @override
  _ConfirmStartingTimeState createState() =>
      _ConfirmStartingTimeState(this.habitPlan, this.onConfirmation);
}

class _ConfirmStartingTimeState extends State<ConfirmStartingTime> {
  final HabitPlan habitPlan;
  final Function updateFunction;
  _ConfirmStartingTimeState(this.habitPlan, this.updateFunction);

  final _formKey = GlobalKey<FormState>();

  String startingPeriod = "The first training";
  late DateTime startingDate;
  late String startingDateString;
  final TextEditingController dateController = TextEditingController();
  int startingStep = 1;

  @override
  void initState() {
    super.initState();
    this.startingDate = _getDefaultStartingTime();
  }

  /// Returns the default [DateTime] for the first trainig to start.
  DateTime _getDefaultStartingTime() {
    final DateTime now = TimeHelper.instance.currentTime;
    final DateTime startingDate;

    switch (this.habitPlan.trainingTimeIndex) {
      case 0:
        // If it's an hourly habit, start on the next day, 0am.
        startingDate = DateTime(
          now.year,
          now.month,
          now.day + 1,
        );
        break;
      default:
        // Else start the next week, monday, 0am.
        startingDate = DateTime(
          now.year,
          now.month,
          now.day + 8 - now.weekday,
        );
    }

    return startingDate;
  }

  /// Adapts the database so that [habitPlan] is active.
  Future<void> _startHabitPlan(
    final DateTime startingDate,
    final int startingStep,
  ) async {
    // Mark the old plan as inactive.
    final List<HabitPlan> activeHabitPlanList =
        await DatabaseHelper.instance.getActiveHabitPlan();
    if (activeHabitPlanList.length > 0) {
      final HabitPlan oldHabitPlan = activeHabitPlanList[0];
      oldHabitPlan.isActive = false;
      DatabaseHelper.instance.updateHabitPlan(oldHabitPlan);
    }

    // Update the plan you're looking at to be active.
    final DateTime now = TimeHelper.instance.currentTime;
    this.habitPlan.isActive = true;
    this.habitPlan.lastChanged = now;
    DatabaseHelper.instance.updateHabitPlan(this.habitPlan);

    // Adapt [ProgressData] to the [HabitPlan].
    final ProgressData progressData =
        await DatabaseHelper.instance.getProgressData();
    progressData.adaptToHabitPlan(
      habitPlan: this.habitPlan,
      startingDate: startingDate,
      startingStepNr: startingStep,
    );
    await DatabaseHelper.instance.updateProgressData(progressData);
  }

  @override
  Widget build(BuildContext context) {
    this.startingDateString = formatDate(startingDate);
    this.dateController.text = startingDateString;

    return AlertDialog(
      title: const Text(
        "Confirm starting time",
        style: StyleData.textStyle,
      ),
      content: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "$startingPeriod will ",
                      style: StyleData.textStyle,
                    ),
                    TextSpan(
                      text: "start on $startingDateString",
                      style: StyleData.boldTextStyle,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: this.dateController,
                      decoration: inputDecoration("Starting date"),
                      readOnly: true,
                      onTap: () {
                        final DateTime now = TimeHelper.instance.currentTime;
                        showDatePicker(
                          context: context,
                          firstDate: now.subtract(Duration(days: 6)),
                          initialDate: this.startingDate,
                          lastDate: DateTime(now.year + 2000),
                        ).then(
                          (newStartingDate) {
                            if (newStartingDate != null) {
                              setState(() {
                                this.startingDate = newStartingDate;
                              });
                            }
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    (this.habitPlan.steps.length > 1)
                        ? TextFormField(
                            initialValue: "1",
                            textAlign: TextAlign.end,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration: inputDecoration("Starting step"),
                            validator: (input) => validateNumberField(
                              input: input,
                              maxInput: this.habitPlan.steps.length,
                              toFillIn: "the starting step",
                              onEmptyText:
                                  "Please insert a number between 1 and ${this.habitPlan.steps.length}",
                            ),
                            onSaved: (input) => this.startingStep =
                                int.parse(input.toString().trim()),
                          )
                        : const SizedBox(),
                  ],
                ),
              ),
            ],
          ),
        ),
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
              label: const Text(
                "Cancel",
                style: StyleData.whiteTextStyle,
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
                Icons.check_circle,
                color: Colors.white,
              ),
              label: const Text(
                "Start",
                style: StyleData.whiteTextStyle,
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();

                  Navigator.pop(context); // Pop dialog

                  _startHabitPlan(
                    this.startingDate,
                    this.startingStep,
                  ).then(
                    (_) => this.updateFunction(this.habitPlan),
                  );
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}
