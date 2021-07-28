import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:githo/extracted_data/styleData.dart';
import 'package:githo/extracted_functions/textFormFieldHelpers.dart';
import 'package:githo/helpers/databaseHelper.dart';
import 'package:githo/models/habitPlanModel.dart';
import 'package:githo/models/progressDataModel.dart';

import 'package:intl/intl.dart';

class ConfirmStartingTime extends StatefulWidget {
  final HabitPlan habitPlan;
  final Function updateFunction;

  const ConfirmStartingTime(this.habitPlan, this.updateFunction);

  @override
  _ConfirmStartingTimeState createState() =>
      _ConfirmStartingTimeState(this.habitPlan, this.updateFunction);
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

  DateTime _getDefaultStartingTime() {
    final DateTime now = DateTime.now();
    final DateTime startingDate;

    switch (this.habitPlan.trainingTimeIndex) {
      case 0:
        // start on the next day, 0am
        startingDate = DateTime(
          now.year,
          now.month,
          now.day + 1,
        );
        break;
      default:
        // start on the next week, monday, 0am
        startingDate = DateTime(
          now.year,
          now.month,
          now.day + 8 - now.weekday,
        );
    }

    return startingDate;
  }

  String _formatDate(final DateTime dateTime) {
    return DateFormat("EEEE, dd.MM.yyyy").format(dateTime);
  }

  Future<void> _updateDataBase(
    final DateTime startingDate,
    final int startingStep,
  ) async {
    // Mark the old plan as inactive
    final List<HabitPlan> activeHabitPlanList =
        await DatabaseHelper.instance.getActiveHabitPlan();
    if (activeHabitPlanList.length > 0) {
      final HabitPlan oldHabitPlan = activeHabitPlanList[0];
      oldHabitPlan.isActive = false;
      DatabaseHelper.instance.updateHabitPlan(oldHabitPlan);
    }

    // Update (and reset) older progressData
    final ProgressData progressData =
        await DatabaseHelper.instance.getProgressData();
    progressData.adaptToHabitPlan(
      habitPlan: this.habitPlan,
      startingDate: startingDate,
      startingStepNr: startingStep,
    );
    DatabaseHelper.instance.updateProgressData(progressData);

    // Update the plan you're looking at to be active
    this.habitPlan.isActive = true;
    this.habitPlan.lastChanged = DateTime.now();
    DatabaseHelper.instance.updateHabitPlan(this.habitPlan);
  }

  @override
  Widget build(BuildContext context) {
    this.startingDateString = _formatDate(startingDate);
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
                        final DateTime now = DateTime.now();
                        showDatePicker(
                          context: context,
                          firstDate: DateTime.now().subtract(Duration(days: 6)),
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
                              variableText: "the starting step",
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
              label: Text(
                "Cancel",
                style: coloredTextStyle(Colors.white),
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
              label: Text(
                "Start",
                style: coloredTextStyle(Colors.white),
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();

                  Navigator.pop(context); // Pop dialog

                  _updateDataBase(
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
