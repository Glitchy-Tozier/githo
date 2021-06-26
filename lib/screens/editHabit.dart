import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:githo/extracted_data/dataShortcut.dart';
import 'package:githo/extracted_data/styleData.dart';

import 'package:githo/extracted_functions/textFormFieldHelpers.dart';
import 'package:githo/extracted_functions/typeExtentions.dart';

import 'package:githo/extracted_widgets/formList.dart';
import 'package:githo/extracted_widgets/headings.dart';
import 'package:githo/extracted_widgets/screenEndingSpacer.dart';
import 'package:githo/extracted_widgets/sliderTitle.dart';

import 'package:githo/models/habitPlanModel.dart';

class EditHabit extends StatefulWidget {
  final HabitPlan habitPlan;
  final Function onSavedFunction;

  const EditHabit({
    required this.habitPlan,
    required this.onSavedFunction,
  });

  @override
  _EditHabitState createState() => _EditHabitState(
        habitPlan: habitPlan,
        onSavedFunction: onSavedFunction,
      );
}

class _EditHabitState extends State<EditHabit> {
  final _formKey = GlobalKey<FormState>();
  final HabitPlan habitPlan;
  final Function onSavedFunction;

  _EditHabitState({
    required this.habitPlan,
    required this.onSavedFunction,
  });

  bool _expandSettings = false;
  // Text used to describe the slider-values
  final List<String> _timeFrames = DataShortcut.timeFrames;
  final List<String> _adjTimeFrames = DataShortcut.adjectiveTimeFrames;
  final List<int> _maxTrainings = DataShortcut.maxTrainings;

  // Function for receiving the onSaved-values from formList.dart
  void _getStepValues(List<String> valueList) {
    this.habitPlan.steps = valueList;
  }

  void _getCommentValues(List<String> valueList) {
    this.habitPlan.comments = valueList;
  }

  @override
  Widget build(BuildContext context) {
    int trainingTimeIndex = habitPlan.trainingTimeIndex.toInt();
    String currentTimeUnit = _timeFrames[trainingTimeIndex];
    String currentAdjTimeUnit = _adjTimeFrames[trainingTimeIndex];

    String currentTimeFrame = _timeFrames[trainingTimeIndex + 1];
    double currentMaxTrainings = _maxTrainings[trainingTimeIndex].toDouble();

    String firstSliderArticle;
    if (trainingTimeIndex == 0) {
      firstSliderArticle = "an";
    } else {
      firstSliderArticle = "a";
    }

    String thirdSliderText;
    if (habitPlan.requiredTrainingPeriods == 1) {
      thirdSliderText = " is";
    } else {
      thirdSliderText = "s are";
    }

    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: StyleData.screenPadding,
          child: Column(
            children: <Widget>[
              const ScreenTitle(title: "Edit Habit-Plan"),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Heading1("Goal"),
                    TextFormField(
                      decoration: inputDecoration("Your goal"),
                      validator: (input) =>
                          checkIfEmpty(input.toString().trim(), "your goal"),
                      initialValue: habitPlan.goal,
                      onSaved: (input) =>
                          habitPlan.goal = input.toString().trim(),
                    ),
                    SizedBox(height: 10),

                    Heading1("${currentAdjTimeUnit.capitalize()} action count"),
                    TextFormField(
                      textAlign: TextAlign.end,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: inputDecoration("Nr of required actions"),
                      validator: (input) => validateNumberField(
                        input,
                        "the required repetitions",
                        currentTimeUnit,
                      ),
                      initialValue: habitPlan.requiredReps.toString(),
                      onSaved: (input) => habitPlan.requiredReps =
                          int.parse(input.toString().trim()),
                    ),
                    SizedBox(height: 10),

                    // Create the step-form-fields
                    const Heading1("Steps towards your goal"),
                    FormList(
                      fieldName: "Step",
                      canBeEmpty: false,
                      valuesGetter: _getStepValues,
                      inputList: habitPlan.steps,
                    ),

                    // Create the form-fields for your personal comments
                    const Heading1("Comments"),
                    FormList(
                      fieldName: "Comment",
                      canBeEmpty: true,
                      valuesGetter: _getCommentValues,
                      inputList: habitPlan.comments,
                    ),

                    // Extended settings
                    SizedBox(height: 10),
                    ExpansionPanelList(
                      expansionCallback: (int index, bool isExpanded) {
                        setState(() {
                          _expandSettings = !_expandSettings;
                        });
                      },
                      children: [
                        ExpansionPanel(
                          headerBuilder:
                              (BuildContext context, bool isExpanded) {
                            return ListTile(
                              //leading: Icon(Icons.settings),
                              title: Text(
                                "Extended Settings",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                          canTapOnHeader: true,
                          isExpanded: _expandSettings,
                          body: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Column(
                              children: <Widget>[
                                SliderTitle([
                                  ["normal", "It will be $firstSliderArticle "],
                                  ["bold", "$currentAdjTimeUnit"],
                                  ["normal", " habit."],
                                ]),
                                Slider(
                                  value: habitPlan.trainingTimeIndex.toDouble(),
                                  min: 0,
                                  max: (_timeFrames.length - 2)
                                      .toDouble(), // -2 BECAUSE -1: .length return a value that is 1 too large AND -1: I want exclude the last value.
                                  divisions: _timeFrames.length - 2,
                                  onChanged: (double value) {
                                    setState(() {
                                      // Set the correct value for THIS slider
                                      habitPlan.trainingTimeIndex =
                                          value.toInt();
                                      // Correct the Value for the NEXT slider
                                      int newTimeIndex = value.toInt();
                                      double newMaxTrainings =
                                          _maxTrainings[newTimeIndex]
                                              .toDouble();
                                      habitPlan.requiredTrainings =
                                          (newMaxTrainings * 0.9).floor();
                                    });
                                  },
                                ),
                                SliderTitle([
                                  ["normal", "Every $currentTimeFrame, "],
                                  [
                                    "bold",
                                    "${habitPlan.requiredTrainings.toInt()}"
                                  ],
                                  [
                                    "normal",
                                    " out of ${currentMaxTrainings.toInt()} ${currentTimeUnit}s must be successful."
                                  ]
                                ]),
                                Slider(
                                  value: habitPlan.requiredTrainings.toDouble(),
                                  min: 1,
                                  max: currentMaxTrainings,
                                  divisions: currentMaxTrainings.toInt() - 1,
                                  onChanged: (double value) {
                                    setState(() {
                                      habitPlan.requiredTrainings =
                                          value.toInt();
                                    });
                                  },
                                ),
                                SizedBox(height: 10),
                                SliderTitle([
                                  [
                                    "bold",
                                    "${habitPlan.requiredTrainingPeriods.toInt()}"
                                  ],
                                  [
                                    "normal",
                                    " successful $currentTimeFrame$thirdSliderText required to advance to the next step."
                                  ]
                                ]),
                                Slider(
                                  value: habitPlan.requiredTrainingPeriods
                                      .toDouble(),
                                  min: 1,
                                  max: 10,
                                  divisions: 9,
                                  onChanged: (double value) {
                                    setState(() {
                                      habitPlan.requiredTrainingPeriods =
                                          value.toInt();
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ScreenEndingSpacer(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.save),
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();
            onSavedFunction(habitPlan);
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}
