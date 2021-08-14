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
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'package:githo/config/data_shortcut.dart';
import 'package:githo/config/style_data.dart';
import 'package:githo/helpers/get_duration_diff.dart';

import 'package:githo/widgets/alert_dialogs/confirm_training_start.dart';
import 'package:githo/widgets/alert_dialogs/training_done.dart';
import 'package:githo/widgets/background.dart';
import 'package:githo/widgets/bottom_sheets/text_sheet.dart';
import 'package:githo/widgets/bottom_sheets/welcome_sheet.dart';
import 'package:githo/widgets/headings/screen_title.dart';
import 'package:githo/widgets/headings/heading.dart';
import 'package:githo/widgets/screen_ending_spacer.dart';
import 'package:githo/widgets/step_to_do.dart';

import 'package:githo/database/database_helper.dart';
import 'package:githo/helpers/time_helper.dart';
import 'package:githo/models/progress_data.dart';
import 'package:githo/models/used_classes/step.dart';
import 'package:githo/models/used_classes/training.dart';

import 'package:githo/screens/about.dart';
import 'package:githo/screens/habit_list.dart';

/// The regular home-screen, containing the to-do's.

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<ProgressData> _progressData;
  bool initialLoad = true;

  final GlobalKey globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _reloadScreen();
  }

  void _reloadScreen() {
    setState(() {
      _progressData = DatabaseHelper.instance.getProgressData();
      _scrollToActiveTraining(delay: 1);
    });
  }

  /// Reloads the screen and saves [_progressData] in the database.
  Future<void> _updateDbAndScreen() async {
    DatabaseHelper.instance.updateProgressData(await _progressData);
    setState(() {});
  }

  // Scrolls to the active training, if there is one.
  void _scrollToActiveTraining({final int delay = 0}) {
    Future<void>.delayed(
      Duration(seconds: delay),
      () {
        if (globalKey.currentContext != null) {
          Scrollable.ensureVisible(
            globalKey.currentContext!,
            duration: const Duration(seconds: 1),
            alignment: 0.5,
          );
        } else {
          print('\nGlobalKey is null\n');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Background(
        child: FutureBuilder<ProgressData>(
          future: _progressData,
          builder:
              (BuildContext context, AsyncSnapshot<ProgressData> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                final ProgressData progressData = snapshot.data!;
                if (progressData.isActive == false) {
                  initialLoad = false;
                  // If connection is done but no habitPlan is active:
                  final double screenHeight =
                      MediaQuery.of(context).size.height;
                  return Padding(
                    padding: EdgeInsets.only(
                      top: screenHeight * 0.25,
                      right: StyleData.screenPaddingValue,
                      left: StyleData.screenPaddingValue,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Heading('No habit-plan is active.'),
                        Text(
                          'Click on the orange button to '
                          'add or activate your habit-plan',
                          style: Theme.of(context).textTheme.bodyText2,
                        ),
                      ],
                    ),
                  );
                } else {
                  // If connection is done and there is an active habitPlan:
                  final bool somethingChanged = progressData.updateSelf();
                  if (somethingChanged) {
                    _scrollToActiveTraining();

                    if (initialLoad == true) {
                      WidgetsBinding.instance?.addPostFrameCallback(
                        (_) => showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: (BuildContext context) =>
                              WelcomeSheet(progressData: progressData),
                        ),
                      );
                    }
                  }
                  initialLoad = false;

                  return ListView(
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    children: <Widget>[
                      Padding(
                        padding: StyleData.screenPadding,
                        child: ScreenTitle(progressData.habit),
                      ),
                      Column(
                        // This column exists to make sure all trainings are
                        // being cached. (= to disable lazyloading)
                        children: <Widget>[
                          ...List<Widget>.generate(progressData.steps.length,
                              (final int i) {
                            final StepData step = progressData.steps[i];
                            return StepToDo(
                              globalKey,
                              step,
                              _updateDbAndScreen,
                            );
                          }),
                        ],
                      ),
                      ScreenEndingSpacer(),
                    ],
                  );
                }
              } else if (snapshot.hasError) {
                initialLoad = false;

                // If connection is done but there was an error:
                print(snapshot.error);
                return Padding(
                  padding: StyleData.screenPadding,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Heading(
                          'There was an error connecting to the database.'),
                      Text(
                        snapshot.error.toString(),
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                    ],
                  ),
                );
              }
            }
            // While loading, do this:
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: StyleData.floatingActionButtonPadding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            SpeedDial(
              backgroundColor: Colors.orange,
              icon: Icons.settings,
              activeIcon: Icons.close,
              spacing: 4,
              spaceBetweenChildren: 4,

              /// If false, backgroundOverlay will not be rendered.
              //renderOverlay: true,
              overlayColor: Colors.black,
              overlayOpacity: 0.5,

              tooltip: 'Show options',
              heroTag: 'speed-dial-hero-tag',
              //isOpenOnStart: false,
              animationSpeed: 200,
              switchLabelPosition: true,
              // childMargin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              children: <SpeedDialChild>[
                SpeedDialChild(
                  child: const Icon(Icons.info),
                  label: 'About',
                  labelStyle: Theme.of(context).textTheme.bodyText2,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<About>(
                        builder: (BuildContext context) => About(),
                      ),
                    );
                  },
                ),
                SpeedDialChild(
                  child: const Icon(Icons.list),
                  label: 'List of Habits',
                  labelStyle: Theme.of(context).textTheme.bodyText2,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<HabitList>(
                        builder: (BuildContext context) => HabitList(
                          updateFunction: _reloadScreen,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            FutureBuilder<ProgressData>(
              future: _progressData,
              builder:
                  (BuildContext context, AsyncSnapshot<ProgressData> snapshot) {
                if (snapshot.hasData) {
                  final ProgressData progressData = snapshot.data!;
                  if (progressData.isActive && DataShortcut.testing) {
                    return SizedBox(
                      height: 55,
                      width: 150,
                      child: Material(
                        color: Colors.cyan.withOpacity(0.5),
                        child: InkWell(
                          splashColor: Colors.purple,
                          onTap: () {
                            // Move one training ahead in time.
                            TimeHelper.instance.timeTravel(progressData);

                            print('Start ${progressData.currentStartingDate}');
                            print('Now   ${TimeHelper.instance.currentTime}\n');
                          },
                          onLongPress: () {
                            // Move one trainingPeriod ahead in time.
                            TimeHelper.instance.superTimeTravel(progressData);

                            print('Start ${progressData.currentStartingDate}');
                            print('Now   ${TimeHelper.instance.currentTime}\n');
                          },
                        ),
                      ),
                    );
                  }
                }
                return const SizedBox();
              },
            ),
            FutureBuilder<ProgressData>(
              future: _progressData,
              builder:
                  (BuildContext context, AsyncSnapshot<ProgressData> snapshot) {
                if (snapshot.hasData) {
                  final ProgressData progressData = snapshot.data!;
                  if (progressData.isActive) {
                    final Map<String, dynamic>? activeMap =
                        progressData.activeData;

                    final IconData icon;
                    final Function onClickFunc;

                    if (activeMap == null) {
                      // If the user is waiting for the first training to start.
                      icon = Icons.lock_clock;

                      onClickFunc = () {
                        final Map<String, dynamic> waitingMap =
                            progressData.waitingData!;

                        final Training training =
                            waitingMap['training'] as Training;
                        final StepData step = waitingMap['step'] as StepData;
                        final String stepDescription = step.text;

                        final DateTime now = TimeHelper.instance.currentTime;
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
                                  text: '$remainingTime.\n\nTo-do: ',
                                  style: Theme.of(context).textTheme.bodyText1,
                                ),
                                TextSpan(
                                  text: stepDescription,
                                  style: Theme.of(context).textTheme.bodyText2,
                                ),
                              ],
                            ),
                          ),
                        );
                      };
                    } else {
                      // During normal use (= when some training is active).
                      icon = Icons.done;

                      onClickFunc = () {
                        final Training currentTraining =
                            activeMap['training'] as Training;
                        final StepData currentStep =
                            activeMap['step'] as StepData;

                        if (currentTraining.status == 'ready') {
                          showDialog(
                            context: context,
                            builder: (BuildContext buildContext) {
                              return ConfirmTrainingStart(
                                title: 'Confirm Activation',
                                toDo: currentStep.text,
                                training: currentTraining,
                                onConfirmation: () {
                                  currentTraining.activate();
                                  _updateDbAndScreen();
                                },
                              );
                            },
                          );
                        } else {
                          currentTraining.incrementReps();
                          if (currentTraining.doneReps ==
                              currentTraining.requiredReps) {
                            showDialog(
                              context: context,
                              builder: (BuildContext buildContext) {
                                return TrainingDoneAlert();
                              },
                            );
                          }
                        }
                        _updateDbAndScreen();
                      };
                    }
                    return FloatingActionButton(
                      tooltip: 'Mark training as done',
                      backgroundColor: Colors.green,
                      heroTag: null,
                      onPressed: () {
                        onClickFunc();
                        _scrollToActiveTraining();
                      },
                      child: Icon(
                        icon,
                      ),
                    );
                  }
                }
                return const SizedBox();
              },
            ),
          ],
        ),
      ),
    );
  }
}
