/* 
 * Githo – An app that helps you gradually form long-lasting habits.
 * Copyright (C) 2022 Florian Thaler
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
    Key? key,
    required this.title,
    required this.initialHabitPlan,
    required this.onSavedFunction,
    this.displayImportFAB = false,
  }) : super(key: key);

  final String title;
  final HabitPlan initialHabitPlan;
  final Future<void> Function(HabitPlan) onSavedFunction;
  final bool displayImportFAB;

  @override
  _EditHabitState createState() => _EditHabitState();
}

class _EditHabitState extends State<EditHabit> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController habitController = TextEditingController();
  final TextEditingController repsController = TextEditingController();
  late FocusNode habitFocusNode;
  late FocusNode repsFocusNode;
  late HabitPlan habitPlan;
  late List<String> levels;
  late List<String> comments;

  @override
  void initState() {
    super.initState();
    habitPlan = widget.initialHabitPlan.clone();
    habitController.text = habitPlan.habit;
    repsController.text = habitPlan.requiredReps.toString();
    habitFocusNode = FocusNode();
    repsFocusNode = FocusNode();
    levels = habitPlan.levels;
    comments = habitPlan.comments;
  }

  @override
  void dispose() {
    habitController.dispose();
    repsController.dispose();
    habitFocusNode.dispose();
    repsFocusNode.dispose();
    super.dispose();
  }

  // Text used to describe the slider-values
  final List<String> _timeFrames = DataShortcut.timeFrames;
  final List<String> _adjTimeFrames = DataShortcut.adjectiveTimeFrames;
  final List<int> _maxTrainings = DataShortcut.maxTrainings;

  /// Used for setting the onSaved-values from form_list.dart
  // ignore: use_setters_to_change_properties
  void _setLevelValues(final List<String> valueList) {
    habitPlan.levels = valueList;
  }

  /// Used for setting the onSaved-values from form_list.dart
  // ignore: use_setters_to_change_properties
  void _setCommentValues(final List<String> valueList) {
    habitPlan.comments = valueList;
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

    setState(() {
      habitController.text = map['habit'] as String;
      repsController.text = (map['requiredReps'] as int).toString();
      levels = _jsonToStringList(map['levels'] as String);
      comments = _jsonToStringList(map['comments'] as String);
      habitPlan.trainingTimeIndex = map['trainingTimeIndex'] as int;
      habitPlan.requiredTrainings = map['requiredTrainings'] as int;
      habitPlan.requiredTrainingPeriods = map['requiredTrainingPeriods'] as int;
    });
  }

  @override
  Widget build(BuildContext context) {
    final int trainingTimeIndex = habitPlan.trainingTimeIndex;
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
    if (habitPlan.requiredTrainingPeriods == 1) {
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
                        focusNode: habitFocusNode,
                        controller: habitController,
                        decoration: const InputDecoration(
                          labelText: 'The final habit',
                        ),
                        maxLength: DataShortcut.maxHabitCharacters,
                        validator: (final String? input) {
                          final String? complaint = complainIfEmpty(
                            input: input,
                            toFillIn: 'your final habit',
                          );
                          if (complaint != null) {
                            // Scroll to faulty input
                            Scrollable.ensureVisible(
                              habitFocusNode.context!,
                              duration: const Duration(milliseconds: 500),
                              alignment: 0.5,
                            ).then((_) => habitFocusNode.requestFocus());
                          }
                          return complaint;
                        },
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
                          habitPlan.habit = correctedInput;
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
                        focusNode: repsFocusNode,
                        controller: repsController,
                        textAlign: TextAlign.end,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Nr of required actions',
                          counter: SizedBox(),
                        ),
                        maxLength: 2,
                        validator: (final String? input) {
                          final String timeFrameArticle;
                          if (trainingTimeFrame == 'hour') {
                            timeFrameArticle = 'an';
                          } else {
                            timeFrameArticle = 'a';
                          }
                          final String? complaint = validateNumberField(
                            input: input,
                            maxInput: 99,
                            toFillIn: 'the required repetitions',
                            textIfZero: 'It has to be at least one '
                                'rep $timeFrameArticle $trainingTimeFrame',
                          );
                          if (complaint != null) {
                            // Scroll to faulty input
                            Scrollable.ensureVisible(
                              repsFocusNode.context!,
                              duration: const Duration(milliseconds: 500),
                              alignment: 0.5,
                            ).then((_) => repsFocusNode.requestFocus());
                          }
                          return complaint;
                        },
                        textInputAction: TextInputAction.next,
                        onSaved: (final String? input) => habitPlan
                            .requiredReps = int.parse(input.toString().trim()),
                      ),
                    ),
                    const ThinDivider(),

                    // Create the level-form-fields
                    Padding(
                      padding: StyleData.screenPadding,
                      child: FormList(
                        header: const Heading('Levels of the habit'),
                        fieldName: 'level',
                        canBeEmpty: false,
                        initialValues: levels,
                        valuesSetter: _setLevelValues,
                      ),
                    ),
                    const ThinDivider(),

                    // Create the form-fields for your personal comments
                    Padding(
                      padding: StyleData.screenPadding,
                      child: FormList(
                        header: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const <Widget>[
                            Heading('Comments'),
                            Text('(Optional)'),
                          ],
                        ),
                        fieldName: 'comment',
                        canBeEmpty: true,
                        initialValues: comments,
                        valuesSetter: _setCommentValues,
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
                        value: habitPlan.trainingTimeIndex.toDouble(),
                        // It is -2 BECAUSE
                        //-1: .length return a value that is 1 too large AND
                        //-1: I want exclude the last value.
                        max: (_timeFrames.length - 2).toDouble(),
                        divisions: _timeFrames.length - 2,
                        onChanged: (final double value) {
                          setState(() {
                            final int newTimeIndex = value.toInt();

                            // Set the correct value for THIS slider
                            habitPlan.trainingTimeIndex = newTimeIndex;

                            // Correct the Value for the NEXT slider
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
                                text: '${habitPlan.requiredTrainings} ',
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
                      child: SizedBox(
                        width: double.infinity,
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                text: habitPlan.requiredTrainingPeriods
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
              const ScreenEndingSpacer(),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: ExcludeFocus(
        child: Padding(
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
                        onImport: (final String json) =>
                            _updateTextFormFields(json),
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

                    // Remove all empty comments
                    habitPlan.comments.removeWhere(
                      (final String c) => c == '',
                    );
                    // (except one, if there's no other ones)
                    if (habitPlan.comments.isEmpty) {
                      habitPlan.comments.add('');
                    }

                    await widget.onSavedFunction(habitPlan);
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
      ),
    );
  }
}
