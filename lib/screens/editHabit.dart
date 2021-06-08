import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:githo/extracted_data/dataShortcut.dart';
import 'package:githo/extracted_data/styleShortcut.dart';

import 'package:githo/models/habitPlan_model.dart';

import 'package:githo/extracted_widgets/screenTitle.dart';
import 'package:githo/extracted_widgets/headings.dart';
import 'package:githo/extracted_widgets/formList.dart';
import 'package:githo/extracted_widgets/sliderTitle.dart';
import 'package:githo/extracted_widgets/screenEndingSpacer.dart';

import 'package:githo/extracted_functions/textFormFieldHelpers.dart';
import 'package:githo/extracted_functions/typeExtentions.dart';

class EditHabit extends StatefulWidget {
  final HabitPlan habitPlan;
  final Function onSavedFunction;

  EditHabit({
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
  final List<String> _advTimeFrames = DataShortcut.advTimeFrames;
  final List<double> _maxActivity = DataShortcut.maxActivity;

  // Function for receiving the onSaved-values from formList.dart
  void getChallengeValues(List<String> valueList) {
    this.habitPlan.challenges = valueList;
  }

  void getRuleValues(List<String> valueList) {
    this.habitPlan.rules = valueList;
  }

  @override
  Widget build(BuildContext context) {
    int timeIndex = habitPlan.timeIndex.toInt();
    String currentTimeUnit = _timeFrames[timeIndex];
    String currentAdvTimeUnit = _advTimeFrames[timeIndex];

    String currentTimeFrame = _timeFrames[timeIndex + 1];
    double currentMaxActivity = _maxActivity[timeIndex];

    String thirdSliderText;
    if (habitPlan.requiredRepeats == 1) {
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
              ScreenTitle("Edit Challenge"),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Heading1("Goal"),
                    TextFormField(
                      decoration: inputDecoration("Your goal"),
                      validator: (input) =>
                          checkIfEmpty(input.toString().trim(), "your goal"),
                      initialValue: habitPlan.goal,
                      onSaved: (input) =>
                          habitPlan.goal = input.toString().trim(),
                    ),
                    SizedBox(height: 10),

                    Heading1("${currentAdvTimeUnit.capitalize()} repetitions"),
                    TextFormField(
                      textAlign: TextAlign.end,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: inputDecoration("Required repetitions"),
                      validator: (input) => validateNumberField(
                          input, "the required repetitions"),
                      initialValue: habitPlan.reps.toString(),
                      onSaved: (input) =>
                          habitPlan.reps = int.parse(input.toString().trim()),
                    ),
                    SizedBox(height: 10),

                    // Create the challenge-form-fields
                    Heading1("Steps towards that goal"),
                    FormList(
                      fieldName: "Step",
                      valuesGetter: getChallengeValues,
                      inputList: habitPlan.challenges,
                    ),

                    // Create the form-fields for your personal rules
                    Heading1("Rules set for yourself"),
                    FormList(
                      fieldName: "Rule",
                      valuesGetter: getRuleValues,
                      inputList: habitPlan.rules,
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
                                  ["normal", "It will be a "],
                                  ["bold", "$currentAdvTimeUnit"],
                                  ["normal", " habit."],
                                ]),
                                Slider(
                                  value: habitPlan.timeIndex,
                                  min: 0,
                                  max: (_timeFrames.length - 2)
                                      .toDouble(), // -2 BECAUSE -1: .length return a value that is 1 too large AND -1: I want exclude the last value.
                                  divisions: _timeFrames.length - 2,
                                  onChanged: (double value) {
                                    setState(() {
                                      // Set the correct value for THIS slider
                                      habitPlan.timeIndex = value;
                                      // Correct the Value for the NEXT slider
                                      int newTimeIndex = value.toInt();
                                      double newMaxActivity =
                                          _maxActivity[newTimeIndex];
                                      habitPlan.activity =
                                          (newMaxActivity * 0.9)
                                              .floorToDouble();
                                    });
                                  },
                                ),
                                SliderTitle([
                                  ["normal", "Every $currentTimeFrame, "],
                                  ["bold", "${habitPlan.activity.toInt()}"],
                                  [
                                    "normal",
                                    " out of ${currentMaxActivity.toInt()} ${currentTimeUnit}s must be successful to level up."
                                  ]
                                ]),
                                Slider(
                                  value: habitPlan.activity,
                                  min: 1,
                                  max: currentMaxActivity,
                                  divisions: currentMaxActivity.toInt() - 1,
                                  onChanged: (double value) {
                                    setState(() {
                                      habitPlan.activity = value;
                                    });
                                  },
                                ),
                                SizedBox(height: 10),
                                SliderTitle([
                                  [
                                    "bold",
                                    "${habitPlan.requiredRepeats.toInt()}"
                                  ],
                                  [
                                    "normal",
                                    " level-up$thirdSliderText required to advance to the next challenge."
                                  ]
                                ]),
                                Slider(
                                  value: habitPlan.requiredRepeats,
                                  min: 1,
                                  max: 10,
                                  divisions: 9,
                                  onChanged: (double value) {
                                    setState(() {
                                      habitPlan.requiredRepeats = value;
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
