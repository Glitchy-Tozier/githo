import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:githo/extracted_data/fullDatabaseImport.dart';
import 'package:githo/extracted_data/styleData.dart';
import 'package:githo/extracted_functions/textFormFieldHelpers.dart';
import 'package:githo/helpers/databaseHelper.dart';
import 'package:githo/models/habitPlanModel.dart';
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
  bool _expandSettings = false;

  late DateTime startingDate;
  String startingPeriod = "The first training";
  late String startingDateString;
  final TextEditingController dateController = TextEditingController();

  int startingStep = 1;

  @override
  void initState() {
    super.initState();
    this.startingDate = _getDefaultStartingTime(this.habitPlan);
  }

  DateTime _getDefaultStartingTime(final HabitPlan habitPlan) {
    final DateTime now = DateTime.now();
    final DateTime startingDate;

    switch (habitPlan.trainingTimeIndex) {
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

  void _updateDataBase(
    HabitPlan habitPlan,
    final DateTime startingDate,
    final int startingStep,
  ) async {
    // Mark the old plan as inactive
    final List<HabitPlan> activeHabitPlanList =
        await DatabaseHelper.instance.getActiveHabitPlan();
    if (activeHabitPlanList.length > 0) {
      HabitPlan oldHabitPlan = activeHabitPlanList[0];
      oldHabitPlan.isActive = false;
      await DatabaseHelper.instance.updateHabitPlan(oldHabitPlan);
    }

    // Update (and reset) older progressData
    ProgressData progressData = await DatabaseHelper.instance.getProgressData();
    progressData.adaptToHabitPlan(
      habitPlan: habitPlan,
      startingDate: startingDate,
      startingStepNr: startingStep,
    );
    await DatabaseHelper.instance.updateProgressData(progressData);

    // Update the plan you're looking at to be active
    habitPlan.isActive = true;
    habitPlan.lastChanged = DateTime.now();
    await DatabaseHelper.instance.updateHabitPlan(habitPlan);

    this.updateFunction(habitPlan);
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
              Text(
                "The first training will start at $startingDateString",
                style: StyleData.textStyle,
              ),
              SizedBox(height: 20),
              Form(
                key: _formKey,
                child: ExpansionPanelList(
                  //expandedHeaderPadding: EdgeInsets.all(0),
                  elevation: 0,
                  expansionCallback: (int index, bool isExpanded) {
                    setState(() {
                      _expandSettings = !_expandSettings;
                    });
                  },
                  children: [
                    ExpansionPanel(
                      headerBuilder: (BuildContext context, bool isExpanded) {
                        return ListTile(
                          title: Text(
                            "Extended Settings",
                            textAlign: TextAlign.left,
                            style: StyleData.textStyle,
                          ),
                        );
                      },
                      canTapOnHeader: true,
                      isExpanded: _expandSettings,
                      body: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: 4),
                          TextFormField(
                            controller: this.dateController,
                            decoration: inputDecoration("Starting date"),
                            readOnly: true,
                            onTap: () {
                              final DateTime now = DateTime.now();
                              showDatePicker(
                                context: context,
                                firstDate:
                                    DateTime(now.year, now.month, now.day),
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
                          SizedBox(height: 10),
                          TextFormField(
                            initialValue: "1",
                            textAlign: TextAlign.end,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration: inputDecoration("Starting step"),
                            validator: (input) => validateNumberField(
                              input: input,
                              maxInput: habitPlan.steps.length,
                              variableText: "the starting step",
                              onEmptyText:
                                  "Please insert a number between 1 and ${habitPlan.steps.length}",
                            ),
                            onSaved: (input) => startingStep =
                                int.parse(input.toString().trim()),
                          ),
                        ],
                      ),
                    ),
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

                  Navigator.pop(context);
                  _updateDataBase(
                    this.habitPlan,
                    this.startingDate,
                    this.startingStep,
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
