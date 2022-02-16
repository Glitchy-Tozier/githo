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

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:githo/config/custom_widget_themes.dart';
import 'package:githo/config/data_shortcut.dart';
import 'package:githo/config/style_data.dart';

import 'package:githo/helpers/text_form_field_validation.dart';
import 'package:githo/helpers/type_extentions.dart';
import 'package:githo/models/habit_plan.dart';
import 'package:githo/widgets/alert_dialogs/import_habit.dart';
import 'package:githo/widgets/background.dart';
import 'package:githo/widgets/dividers/fat_divider.dart';
import 'package:githo/widgets/dividers/thin_divider.dart';
import 'package:githo/widgets/form_list.dart';
import 'package:githo/widgets/headings/heading.dart';
import 'package:githo/widgets/headings/screen_title.dart';
import 'package:githo/widgets/screen_ending_spacer.dart';

class EditHabit extends StatefulWidget {
  /// Edit the values of the input [HabitPlan].
  const EditHabit({
    required this.title,
    required this.habitPlan,
    required this.onSavedFunction,
    this.displayImportFAB = false,
  });

  final String title;
  final HabitPlan habitPlan;
  final Future<void> Function(HabitPlan) onSavedFunction;
  final bool displayImportFAB;

  @override
  _EditHabitState createState() => _EditHabitState();
}

class _EditHabitState extends State<EditHabit> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController habitController = TextEditingController();
  final TextEditingController repsController = TextEditingController();
  late List<String> levels;
  late List<String> comments;

  @override
  void initState() {
    super.initState();
    habitController.text = widget.habitPlan.habit;
    repsController.text = widget.habitPlan.requiredReps.toString();
    levels = widget.habitPlan.levels;
    comments = widget.habitPlan.comments;
  }

  // Text used to describe the slider-values
  final List<String> _timeFrames = DataShortcut.timeFrames;
  final List<String> _adjTimeFrames = DataShortcut.adjectiveTimeFrames;
  final List<int> _maxTrainings = DataShortcut.maxTrainings;

  /// Used for receiving the onSaved-values from formList.dart
  // ignore: use_setters_to_change_properties
  void _getLevelValues(final List<String> valueList) {
    widget.habitPlan.levels = valueList;
  }

  /// Used for receiving the onSaved-values from formList.dart
  // ignore: use_setters_to_change_properties
  void _getCommentValues(final List<String> valueList) {
    widget.habitPlan.comments = valueList;
  }

  /// Converts a [json]-like [String] into a list of [String]s.
  static List<String> _jsonToStringList(final String json) {
    final dynamic dynamicList = jsonDecode(json);
    final List<String> stringList = <String>[];

    for (final String element in dynamicList) {
      stringList.add(element);
    }
    return stringList;
  }

  void _updateTextFormFields(final String json) {
    final Map<String, dynamic> map = jsonDecode(json) as Map<String, dynamic>;

    habitController.text = map['habit'] as String;
    repsController.text = (map['requiredReps'] as int).toString();
    levels = _jsonToStringList(map['levels'] as String);
    comments = _jsonToStringList(map['comments'] as String);
    widget.habitPlan.trainingTimeIndex = map['trainingTimeIndex'] as int;
    widget.habitPlan.requiredTrainings = map['requiredTrainings'] as int;
    widget.habitPlan.requiredTrainingPeriods =
        map['requiredTrainingPeriods'] as int;
  }

  @override
  Widget build(BuildContext context) {
    final int trainingTimeIndex = widget.habitPlan.trainingTimeIndex;
    final String trainingTimeFrame = _timeFrames[trainingTimeIndex];
    final String trainingAdjTimeFrame = _adjTimeFrames[trainingTimeIndex];

    final String periodTimeFrame = _timeFrames[trainingTimeIndex + 1];
    final double currentMaxTrainings =
        _maxTrainings[trainingTimeIndex].toDouble();

    final String firstSliderArticle;
    if (trainingTimeIndex == 0) {
      firstSliderArticle = 'an';
    } else {
      firstSliderArticle = 'a';
    }

    final String thirdSliderText;
    if (widget.habitPlan.requiredTrainingPeriods == 1) {
      thirdSliderText = ' is';
    } else {
      thirdSliderText = 's are';
    }

    return Scaffold(
      body: Background(
        child: GestureDetector(
          onTap: FocusScope.of(context).unfocus,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            shrinkWrap: true,
            children: <Widget>[
              Padding(
                padding: StyleData.screenPadding,
                child: ScreenTitle(widget.title),
              ),
              const FatDivider(),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Padding(
                      padding: StyleData.screenPadding,
                      child: Heading('Final habit'),
                    ),
                    Padding(
                      padding: StyleData.screenPadding,
                      child: TextFormField(
                        controller: habitController,
                        decoration: const InputDecoration(
                          labelText: 'The final habit',
                        ),
                        maxLength: DataShortcut.maxHabitCharacters,
                        validator: (final String? input) => complainIfEmpty(
                          input: input,
                          toFillIn: 'your final habit',
                        ),
                        textInputAction: TextInputAction.next,
                        onSaved: (final String? input) {
                          String correctedInput = input.toString().trim();
                          if (correctedInput.length >
                              DataShortcut.maxHabitCharacters) {
                            correctedInput = correctedInput.substring(
                              0,
                              DataShortcut.maxHabitCharacters,
                            );
                          }
                          widget.habitPlan.habit = correctedInput;
                        },
                      ),
                    ),
                    const ThinDivider(),

                    Padding(
                      padding: StyleData.screenPadding,
                      child: Heading(
                        '${trainingAdjTimeFrame.capitalize()} action count',
                      ),
                    ),
                    Padding(
                      padding: StyleData.screenPadding,
                      child: TextFormField(
                        controller: repsController,
                        textAlign: TextAlign.end,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Nr of required actions',
                        ),
                        maxLength: 2,
                        validator: (final String? input) {
                          final String timeFrameArticle;
                          if (trainingTimeFrame == 'hour') {
                            timeFrameArticle = 'an';
                          } else {
                            timeFrameArticle = 'a';
                          }
                          return validateNumberField(
                            input: input,
                            maxInput: 99,
                            toFillIn: 'the required repetitions',
                            textIfZero: 'It has to be at least one '
                                'rep $timeFrameArticle $trainingTimeFrame',
                          );
                        },
                        textInputAction: TextInputAction.next,
                        onSaved: (final String? input) => widget.habitPlan
                            .requiredReps = int.parse(input.toString().trim()),
                      ),
                    ),
                    const ThinDivider(),

                    // Create the level-form-fields
                    const Padding(
                      padding: StyleData.screenPadding,
                      child: Heading('Levels of the habit'),
                    ),
                    Padding(
                      padding: StyleData.screenPadding,
                      child: FormList(
                        fieldName: 'level',
                        canBeEmpty: false,
                        valuesGetter: _getLevelValues,
                        initValues: levels,
                      ),
                    ),
                    const ThinDivider(),

                    // Create the form-fields for your personal comments
                    Padding(
                      padding: StyleData.screenPadding,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const <Widget>[
                          Heading('Comments'),
                          Text('(Optional)'),
                        ],
                      ),
                    ),
                    Padding(
                      padding: StyleData.screenPadding,
                      child: FormList(
                        fieldName: 'comment',
                        canBeEmpty: true,
                        valuesGetter: _getCommentValues,
                        initValues: comments,
                      ),
                    ),

                    // Extended settings
                    const FatDivider(),
                    const Padding(
                      padding: StyleData.screenPadding,
                      child: Heading('Extended Settings'),
                    ),
                    Padding(
                      padding: StyleData.screenPadding,
                      child: SizedBox(
                        width: double.infinity,
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                text: 'It will be $firstSliderArticle ',
                                style: Theme.of(context).textTheme.headline4,
                              ),
                              TextSpan(
                                text: trainingAdjTimeFrame,
                                style: Theme.of(context).textTheme.headline3,
                              ),
                              TextSpan(
                                text: ' habit.',
                                style: Theme.of(context).textTheme.headline4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: StyleData.screenPadding,
                      child: Slider(
                        value: widget.habitPlan.trainingTimeIndex.toDouble(),
                        // It is -2 BECAUSE
                        //-1: .length return a value that is 1 too large AND
                        //-1: I want exclude the last value.
                        max: (_timeFrames.length - 2).toDouble(),
                        divisions: _timeFrames.length - 2,
                        onChanged: (final double value) {
                          setState(() {
                            final int newTimeIndex = value.toInt();

                            // Set the correct value for THIS slider
                            widget.habitPlan.trainingTimeIndex = newTimeIndex;

                            // Correct the Value for the NEXT slider
                            final double newMaxTrainings =
                                _maxTrainings[newTimeIndex].toDouble();
                            widget.habitPlan.requiredTrainings =
                                (newMaxTrainings * 0.9).floor();
                          });
                        },
                      ),
                    ),
                    const ThinDivider(),
                    Padding(
                      padding: StyleData.screenPadding,
                      child: SizedBox(
                        width: double.infinity,
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Every $periodTimeFrame, ',
                                style: Theme.of(context).textTheme.headline4,
                              ),
                              TextSpan(
                                text: '${widget.habitPlan.requiredTrainings} ',
                                style: Theme.of(context).textTheme.headline3,
                              ),
                              TextSpan(
                                text: 'out of ${currentMaxTrainings.toInt()} '
                                    '${trainingTimeFrame}s must be successful.',
                                style: Theme.of(context).textTheme.headline4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: StyleData.screenPadding,
                      child: Slider(
                        value: widget.habitPlan.requiredTrainings.toDouble(),
                        min: 1,
                        max: currentMaxTrainings,
                        divisions: currentMaxTrainings.toInt() - 1,
                        onChanged: (final double value) {
                          setState(() {
                            widget.habitPlan.requiredTrainings = value.toInt();
                          });
                        },
                      ),
                    ),
                    const ThinDivider(),
                    Padding(
                      padding: StyleData.screenPadding,
                      child: SizedBox(
                        width: double.infinity,
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                text: widget.habitPlan.requiredTrainingPeriods
                                    .toString(),
                                style: Theme.of(context).textTheme.headline3,
                              ),
                              TextSpan(
                                text: ' successful '
                                    '$periodTimeFrame$thirdSliderText '
                                    'required to level up.',
                                style: Theme.of(context).textTheme.headline4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: StyleData.screenPadding,
                      child: Slider(
                        value:
                            widget.habitPlan.requiredTrainingPeriods.toDouble(),
                        min: 1,
                        max: 10,
                        divisions: 9,
                        onChanged: (final double value) {
                          setState(() {
                            widget.habitPlan.requiredTrainingPeriods =
                                value.toInt();
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: StyleData.floatingActionButtonPadding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Visibility(
              visible: widget.displayImportFAB,
              child: FloatingActionButton(
                backgroundColor: ThemedColors.lightBlue,
                tooltip: 'Import habit-plan.',
                heroTag: null,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext buildContext) => ImportHabit(
                      onImport: (final String json) {
                        setState(() {
                          _updateTextFormFields(json);
                        });
                      },
                    ),
                  );
                },
                child: const Icon(Icons.download),
              ),
            ),
            FloatingActionButton(
              tooltip: 'Save',
              backgroundColor: ThemedColors.green,
              heroTag: null,
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  await widget.onSavedFunction(widget.habitPlan);
                  if (!mounted) return;
                  Navigator.pop(context);
                }
              },
              child: const Icon(
                Icons.save,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
