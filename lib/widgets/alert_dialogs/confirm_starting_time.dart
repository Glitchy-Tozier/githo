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

import 'package:githo/helpers/format_date.dart';
import 'package:githo/helpers/text_form_field_validation.dart';
import 'package:githo/database/database_helper.dart';
import 'package:githo/helpers/time_helper.dart';
import 'package:githo/models/habit_plan.dart';
import 'package:githo/models/progress_data.dart';

class ConfirmStartingTime extends StatefulWidget {
  /// Returns a dialog that lets the user choose
  /// 1. when his journey will start
  /// 2. what step it should start with.
  const ConfirmStartingTime({
    required this.habitPlan,
    required this.onConfirmation,
  });

  final HabitPlan habitPlan;
  final Function onConfirmation;

  @override
  _ConfirmStartingTimeState createState() => _ConfirmStartingTimeState();
}

class _ConfirmStartingTimeState extends State<ConfirmStartingTime> {
  final GlobalKey<FormFieldState<String?>> formKey =
      GlobalKey<FormFieldState<String?>>();

  String startingPeriod = 'The first training';
  late DateTime startingDate;
  late String startingDateString;
  final TextEditingController dateController = TextEditingController();
  int startingStep = 1;

  @override
  void initState() {
    super.initState();
    startingDate = _getDefaultStartingTime();
  }

  /// Returns the default [DateTime] for the first trainig to start.
  DateTime _getDefaultStartingTime() {
    final DateTime now = TimeHelper.instance.currentTime;
    final DateTime startingDate;

    switch (widget.habitPlan.trainingTimeIndex) {
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
    if (activeHabitPlanList.isNotEmpty) {
      final HabitPlan oldHabitPlan = activeHabitPlanList[0];
      oldHabitPlan.isActive = false;
      DatabaseHelper.instance.updateHabitPlan(oldHabitPlan);
    }

    // Update the plan you're looking at to be active.
    final DateTime now = TimeHelper.instance.currentTime;
    widget.habitPlan.isActive = true;
    widget.habitPlan.lastChanged = now;
    DatabaseHelper.instance.updateHabitPlan(widget.habitPlan);

    // Adapt [ProgressData] to the [HabitPlan].
    final ProgressData progressData =
        await DatabaseHelper.instance.getProgressData();
    progressData.adaptToHabitPlan(
      habitPlan: widget.habitPlan,
      startingDate: startingDate,
      startingStepNr: startingStep,
    );
    await DatabaseHelper.instance.updateProgressData(progressData);
  }

  @override
  Widget build(BuildContext context) {
    startingDateString = formatDate(startingDate);
    dateController.text = startingDateString;

    return AlertDialog(
      title: const Text(
        'Confirm starting time',
      ),
      content: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(
                    text: '$startingPeriod will ',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  TextSpan(
                    text: 'start on $startingDateString.',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: dateController,
                  decoration: const InputDecoration(
                    labelText: 'Starting date',
                  ),
                  readOnly: true,
                  onTap: () {
                    final DateTime now = TimeHelper.instance.currentTime;
                    showDatePicker(
                      context: context,
                      firstDate: now.subtract(const Duration(days: 6)),
                      initialDate: startingDate,
                      lastDate: DateTime(now.year + 2000),
                    ).then(
                      (DateTime? newStartingDate) {
                        if (newStartingDate != null) {
                          setState(() {
                            startingDate = newStartingDate;
                          });
                        }
                      },
                    );
                  },
                ),
                if (widget.habitPlan.steps.length > 1) ...<Widget>[
                  const SizedBox(height: 10),
                  TextFormField(
                    initialValue: '1',
                    key: formKey,
                    textAlign: TextAlign.end,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Starting step',
                    ),
                    validator: (final String? input) => validateNumberField(
                      input: input,
                      maxInput: widget.habitPlan.steps.length,
                      toFillIn: 'the starting step',
                      textIfZero: 'Fill in number between 1 and '
                          '${widget.habitPlan.steps.length}',
                    ),
                    onSaved: (final String? input) =>
                        startingStep = int.parse(input.toString().trim()),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <ElevatedButton>[
            ElevatedButton.icon(
              icon: const Icon(
                Icons.cancel,
              ),
              label: Text(
                'Cancel',
                style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      color: Colors.white,
                    ),
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
              ),
              label: Text(
                'Start',
                style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      color: Colors.white,
                    ),
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
              ),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();

                  Navigator.pop(context); // Pop dialog

                  _startHabitPlan(
                    startingDate,
                    startingStep,
                  ).then(
                    (_) => widget.onConfirmation(widget.habitPlan),
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
