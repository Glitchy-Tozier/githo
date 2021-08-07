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

import 'package:githo/extracted_data/dataShortcut.dart';
import 'package:githo/extracted_data/styleData.dart';

import 'package:githo/extracted_functions/textFormFieldHelpers.dart';
import 'package:githo/extracted_functions/typeExtentions.dart';
import 'package:githo/extracted_widgets/backgroundWidget.dart';
import 'package:githo/extracted_widgets/dividers/fatDivider.dart';
import 'package:githo/extracted_widgets/dividers/thinDivider.dart';

import 'package:githo/extracted_widgets/formList.dart';
import 'package:githo/extracted_widgets/headings.dart';
import 'package:githo/extracted_widgets/screenEndingSpacer.dart';
import 'package:githo/extracted_widgets/sliderTitle.dart';

import 'package:githo/models/habitPlanModel.dart';

class EditHabit extends StatefulWidget {
  // Edit the values of the input habit-plan.

  final String title;
  final HabitPlan habitPlan;
  final Function onSavedFunction;

  const EditHabit({
    required this.title,
    required this.habitPlan,
    required this.onSavedFunction,
  });

  @override
  _EditHabitState createState() => _EditHabitState(
        title,
        habitPlan,
        onSavedFunction,
      );
}

class _EditHabitState extends State<EditHabit> {
  final _formKey = GlobalKey<FormState>();
  final String title;
  final HabitPlan habitPlan;
  final Function onSavedFunction;

  _EditHabitState(
    this.title,
    this.habitPlan,
    this.onSavedFunction,
  );

  // Text used to describe the slider-values
  final List<String> _timeFrames = DataShortcut.timeFrames;
  final List<String> _adjTimeFrames = DataShortcut.adjectiveTimeFrames;
  final List<int> _maxTrainings = DataShortcut.maxTrainings;

  // Function for receiving the onSaved-values from formList.dart
  void _getStepValues(final List<String> valueList) {
    this.habitPlan.steps = valueList;
  }

  void _getCommentValues(final List<String> valueList) {
    this.habitPlan.comments = valueList;
  }

  @override
  Widget build(BuildContext context) {
    final int trainingTimeIndex = habitPlan.trainingTimeIndex.toInt();
    final String currentTimeUnit = _timeFrames[trainingTimeIndex];
    final String currentAdjTimeUnit = _adjTimeFrames[trainingTimeIndex];

    final String currentTimeFrame = _timeFrames[trainingTimeIndex + 1];
    final double currentMaxTrainings =
        _maxTrainings[trainingTimeIndex].toDouble();

    final String firstSliderArticle;
    if (trainingTimeIndex == 0) {
      firstSliderArticle = "an";
    } else {
      firstSliderArticle = "a";
    }

    final String thirdSliderText;
    if (habitPlan.requiredTrainingPeriods == 1) {
      thirdSliderText = " is";
    } else {
      thirdSliderText = "s are";
    }

    return Scaffold(
      body: BackgroundWidget(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            physics: const BouncingScrollPhysics(),
            shrinkWrap: true,
            children: <Widget>[
              Padding(
                padding: StyleData.screenPadding,
                child: ScreenTitle(this.title),
              ),
              const FatDivider(),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Padding(
                      padding: StyleData.screenPadding,
                      child: Heading("Final habit"),
                    ),
                    Padding(
                      padding: StyleData.screenPadding,
                      child: TextFormField(
                        decoration: inputDecoration("The final habit"),
                        maxLength: 40,
                        validator: (input) => complainIfEmpty(
                          input.toString().trim(),
                          "your final habit",
                        ),
                        initialValue: habitPlan.habit,
                        textInputAction: TextInputAction.next,
                        onSaved: (input) =>
                            habitPlan.habit = input.toString().trim(),
                      ),
                    ),
                    const ThinDivider(),

                    Padding(
                      padding: StyleData.screenPadding,
                      child: Heading(
                          "${currentAdjTimeUnit.capitalize()} action count"),
                    ),
                    Padding(
                      padding: StyleData.screenPadding,
                      child: TextFormField(
                        textAlign: TextAlign.end,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: inputDecoration("Nr of required actions"),
                        maxLength: 2,
                        validator: (input) => validateNumberField(
                          input: input,
                          maxInput: 99,
                          variableText: "the required repetitions",
                          onEmptyText:
                              "It has to be at least one rep a $currentTimeUnit",
                        ),
                        initialValue: habitPlan.requiredReps.toString(),
                        textInputAction: TextInputAction.next,
                        onSaved: (input) => habitPlan.requiredReps =
                            int.parse(input.toString().trim()),
                      ),
                    ),
                    const ThinDivider(),

                    // Create the step-form-fields
                    const Padding(
                      padding: StyleData.screenPadding,
                      child: Heading("Steps towards the habit"),
                    ),
                    Padding(
                      padding: StyleData.screenPadding,
                      child: FormList(
                        fieldName: "Step",
                        canBeEmpty: false,
                        valuesGetter: _getStepValues,
                        inputList: habitPlan.steps,
                      ),
                    ),
                    const ThinDivider(),

                    // Create the form-fields for your personal comments
                    Padding(
                      padding: StyleData.screenPadding,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const <Widget>[
                          Heading("Comments"),
                          Text("(Optional)", style: StyleData.textStyle),
                        ],
                      ),
                    ),
                    Padding(
                      padding: StyleData.screenPadding,
                      child: FormList(
                        fieldName: "Comment",
                        canBeEmpty: true,
                        valuesGetter: _getCommentValues,
                        inputList: habitPlan.comments,
                      ),
                    ),

                    // Extended settings
                    const FatDivider(),
                    const Padding(
                      padding: StyleData.screenPadding,
                      child: Heading("Extended Settings"),
                    ),
                    Padding(
                      padding: StyleData.screenPadding,
                      child: SliderTitle([
                        ["normal", "It will be $firstSliderArticle "],
                        ["bold", "$currentAdjTimeUnit"],
                        ["normal", " habit."],
                      ]),
                    ),
                    Padding(
                      padding: StyleData.screenPadding,
                      child: Slider(
                        value: habitPlan.trainingTimeIndex.toDouble(),
                        min: 0,
                        max: (_timeFrames.length - 2)
                            .toDouble(), // -2 BECAUSE -1: .length return a value that is 1 too large AND -1: I want exclude the last value.
                        divisions: _timeFrames.length - 2,
                        onChanged: (final double value) {
                          setState(() {
                            // Set the correct value for THIS slider
                            habitPlan.trainingTimeIndex = value.toInt();
                            // Correct the Value for the NEXT slider
                            final int newTimeIndex = value.toInt();
                            final double newMaxTrainings =
                                _maxTrainings[newTimeIndex].toDouble();
                            habitPlan.requiredTrainings =
                                (newMaxTrainings * 0.9).floor();
                          });
                        },
                      ),
                    ),
                    const ThinDivider(),
                    Padding(
                      padding: StyleData.screenPadding,
                      child: SliderTitle([
                        ["normal", "Every $currentTimeFrame, "],
                        ["bold", "${habitPlan.requiredTrainings.toInt()}"],
                        [
                          "normal",
                          " out of ${currentMaxTrainings.toInt()} ${currentTimeUnit}s must be successful."
                        ]
                      ]),
                    ),
                    Padding(
                      padding: StyleData.screenPadding,
                      child: Slider(
                        value: habitPlan.requiredTrainings.toDouble(),
                        min: 1,
                        max: currentMaxTrainings,
                        divisions: currentMaxTrainings.toInt() - 1,
                        onChanged: (final double value) {
                          setState(() {
                            habitPlan.requiredTrainings = value.toInt();
                          });
                        },
                      ),
                    ),
                    const ThinDivider(),
                    Padding(
                      padding: StyleData.screenPadding,
                      child: SliderTitle([
                        [
                          "bold",
                          "${habitPlan.requiredTrainingPeriods.toInt()}"
                        ],
                        [
                          "normal",
                          " successful $currentTimeFrame$thirdSliderText required to advance to the next step."
                        ]
                      ]),
                    ),
                    Padding(
                      padding: StyleData.screenPadding,
                      child: Slider(
                        value: habitPlan.requiredTrainingPeriods.toDouble(),
                        min: 1,
                        max: 10,
                        divisions: 9,
                        onChanged: (final double value) {
                          setState(() {
                            habitPlan.requiredTrainingPeriods = value.toInt();
                          });
                        },
                      ),
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
        tooltip: "Save",
        backgroundColor: Colors.green,
        child: const Icon(
          Icons.save,
          color: Colors.white,
        ),
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
