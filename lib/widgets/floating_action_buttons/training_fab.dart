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

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart';

import 'package:githo/config/custom_widget_themes.dart';
import 'package:githo/helpers/format_date.dart';
import 'package:githo/helpers/get_duration_diff.dart';
import 'package:githo/helpers/time_helper.dart';
import 'package:githo/models/progress_data.dart';
import 'package:githo/models/used_classes/level.dart';
import 'package:githo/models/used_classes/training.dart';
import 'package:githo/widgets/alert_dialogs/confirm_training_start.dart';
import 'package:githo/widgets/alert_dialogs/training_done.dart';
import 'package:githo/widgets/bottom_sheets/text_sheet.dart';

/// The [FloatingActionButton] on the righthand-side of the [HomeScreen].
///
/// It basically mirrors the functionality of directly tapping the active
/// training's card.

class TrainingFAB extends StatefulWidget {
  const TrainingFAB({
    required this.progressData,
    required this.scrollToActiveTraining,
    required this.setHomeState,
    Key? key,
  }) : super(key: key);
  final Future<ProgressData> progressData;
  final void Function() scrollToActiveTraining;
  final void Function() setHomeState;

  @override
  _TrainingFABState createState() => _TrainingFABState();
}

class _TrainingFABState extends State<TrainingFAB> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ProgressData>(
      future: widget.progressData,
      builder: (BuildContext context, AsyncSnapshot<ProgressData> snapshot) {
        if (snapshot.hasData) {
          final ProgressData progressData = snapshot.data!;
          if (progressData.isActive) {
            final ProgressDataSlice? activeSlice = progressData.activeDataSlice;

            if (activeSlice == null) {
              // If the user is waiting for the first training to start.
              return FloatingActionButton(
                tooltip: 'Waiting for training to start',
                backgroundColor: ThemedColors.green,
                heroTag: null,
                onPressed: () {
                  final ProgressDataSlice waitingSlice =
                      progressData.waitingDataSlice!;

                  final Training training = waitingSlice.training;
                  final Level level = waitingSlice.level;
                  final String levelDescription = level.text;

                  final TZDateTime now = TimeHelper.instance.currentTime;
                  final String remainingTime = getDurationDiff(
                    now,
                    training.startingDate,
                  );
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (BuildContext context) => TextSheet(
                      title: 'Waiting for training to start',
                      text: TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                            text: 'Starting in ',
                            style: Theme.of(context).textTheme.bodyText2,
                          ),
                          TextSpan(
                            text: '$remainingTime\n',
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                          TextSpan(
                            text:
                                '(On ${formatDate(training.startingDate)})\n\n',
                            style: Theme.of(context).textTheme.bodyText2,
                          ),
                          TextSpan(
                            text: 'To-do: ',
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                          TextSpan(
                            text: levelDescription,
                            style: Theme.of(context).textTheme.bodyText2,
                          ),
                        ],
                      ),
                    ),
                  );
                  widget.scrollToActiveTraining();
                },
                child: const Icon(Icons.lock_clock),
              );
            } else {
              // During normal use (= when some training is active).
              final Level currentLevel = activeSlice.level;
              final Training currentTraining = activeSlice.training;

              if (currentTraining.status == 'ready') {
                return FloatingActionButton(
                  tooltip: 'Start Training',
                  heroTag: null,
                  onPressed: null,
                  child: ClipOval(
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: <Color>[
                            Colors.deepOrange.shade200,
                            Colors.pinkAccent.shade400,
                            Colors.purple.shade900,
                          ],
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext buildContext) {
                                return ConfirmTrainingStart(
                                  title: 'Confirm Activation',
                                  toDo: currentLevel.text,
                                  training: currentTraining,
                                  onConfirmation: () {
                                    currentTraining.activate();
                                    widget.setHomeState();
                                  },
                                );
                              },
                            );
                            widget.scrollToActiveTraining();
                            widget.setHomeState();
                          },
                          child: const Icon(Icons.done),
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                return FloatingActionButton(
                  tooltip: 'Mark training as done',
                  backgroundColor: ThemedColors.green,
                  heroTag: null,
                  onPressed: () {
                    currentTraining.incrementReps();
                    if (currentTraining.doneReps ==
                        currentTraining.requiredReps) {
                      Timer(
                        const Duration(milliseconds: 700),
                        () => showDialog(
                          context: context,
                          builder: (BuildContext buildContext) {
                            return TrainingDoneAlert();
                          },
                        ),
                      );
                    }
                    widget.scrollToActiveTraining();
                    widget.setHomeState();
                  },
                  child: GestureDetector(
                    onLongPress: () {
                      currentTraining.decrementReps();
                      widget.scrollToActiveTraining();
                      widget.setHomeState();
                    },
                    child: const Icon(Icons.done),
                  ),
                );
              }
            }
          }
        }
        return const SizedBox();
      },
    );
  }
}
