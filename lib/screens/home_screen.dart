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
import 'package:flutter/scheduler.dart';

import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'package:githo/config/custom_widget_themes.dart';
import 'package:githo/config/data_shortcut.dart';
import 'package:githo/config/style_data.dart';

import 'package:githo/database/database_helper.dart';
import 'package:githo/helpers/notification_helper.dart';
import 'package:githo/helpers/runtime_variables.dart';
import 'package:githo/helpers/time_helper.dart';
import 'package:githo/models/notification_data.dart';
import 'package:githo/models/progress_data.dart';
import 'package:githo/models/used_classes/level.dart';
import 'package:githo/models/used_classes/training.dart';

import 'package:githo/screens/about.dart';
import 'package:githo/screens/habit_list.dart';
import 'package:githo/screens/notification_settings.dart';
import 'package:githo/screens/theme_settings.dart';

import 'package:githo/widgets/background.dart';
import 'package:githo/widgets/bottom_sheets/welcome_sheet.dart';
import 'package:githo/widgets/floating_action_buttons/training_fab.dart';
import 'package:githo/widgets/headings/heading.dart';
import 'package:githo/widgets/headings/screen_title.dart';
import 'package:githo/widgets/level_to_do.dart';
import 'package:githo/widgets/screen_ending_spacer.dart';

/// The regular home-screen, containing the to-do's.

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<ProgressData> _progressData;

  Timer? timer;
  final GlobalKey activeCardKey = GlobalKey();
  final ValueNotifier<bool> isDialOpen = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _reloadScreen();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  /// Reloads [_progressData] (and possibly the notifications) and resets the
  /// screen, as if the app just was launched.
  void _reloadScreen() {
    setState(() {
      _progressData = DatabaseHelper.instance.getProgressData();
      _progressData.then(
        (ProgressData progressData) async {
          if (progressData.isActive) {
            // Update ProgressData
            final bool somethingChanged = await progressData.updateSelf();
            if (somethingChanged) {
              final NotificationData notificationData =
                  await DatabaseHelper.instance.getNotificationData();
              if (notificationData.isEnabled) {
                // Update Notifications
                await notificationData.updateActivationDate();
                await cancelNotifications();
                await scheduleNotifications();
              }
            }
          }
        },
      );
      _scrollToActiveTraining(delay: 1);
    });
  }

  /// Scrolls to the active training, if there is one.
  void _scrollToActiveTraining({final int delay = 0}) {
    Future<void>.delayed(
      Duration(seconds: delay),
      () {
        if (activeCardKey.currentContext != null) {
          Scrollable.ensureVisible(
            activeCardKey.currentContext!,
            duration: const Duration(seconds: 1),
            alignment: 0.5,
          );
        }
      },
    );
  }

  /// Reloads the screen when the next `setState((){});` needs to occur.
  void _startReloadTimer(final ProgressData progressData) {
    final DateTime restartingDate;

    // Get the value for [restartingDate].
    if (progressData.waitingDataSlice != null) {
      final Training waitingTraining = progressData.waitingDataSlice!.training;
      restartingDate = waitingTraining.startingDate;
    } else {
      final Training activeTraining = progressData.activeDataSlice!.training;
      restartingDate = activeTraining.endingDate;
    }
    timer?.cancel();
    timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        final DateTime now = TimeHelper.instance.currentTime;
        final Duration remainingTime = restartingDate.difference(now);

        if (remainingTime.isNegative) {
          setState(() {
            timer?.cancel();
            // Update ProgressData
            progressData.updateSelf().then(
              (final bool somethingChanged) async {
                if (somethingChanged) {
                  final NotificationData notificationData =
                      await DatabaseHelper.instance.getNotificationData();
                  if (notificationData.isEnabled) {
                    // Update Notifications
                    await notificationData.updateActivationDate();
                    await cancelNotifications();
                    await scheduleNotifications();
                  }
                }
              },
            );

            _scrollToActiveTraining(delay: 1);
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    timer?.cancel();
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
                      children: const <Widget>[
                        Heading('No habit-plan is active.'),
                        Text(
                          'Click on the orange button to '
                          'add or activate your habit-plan',
                        ),
                      ],
                    ),
                  );
                } else {
                  // If connection is done and there is an active habitPlan:
                  _startReloadTimer(progressData);
                  if (RuntimeVariables.instance.showWelcomeSheet) {
                    WidgetsBinding.instance?.addPostFrameCallback(
                      (_) => showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (BuildContext context) =>
                            WelcomeSheet(progressData: progressData),
                      ),
                    );
                    RuntimeVariables.instance.showWelcomeSheet = false;
                  }

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
                          ...List<Widget>.generate(progressData.levels.length,
                              (final int i) {
                            final Level level = progressData.levels[i];
                            return LevelToDo(
                              activeCardKey: activeCardKey,
                              level: level,
                              setHomeState: () => setState(() {}),
                            );
                          }),
                        ],
                      ),
                      ScreenEndingSpacer(),
                    ],
                  );
                }
              } else if (snapshot.hasError) {
                // If connection is done but there was an error:
                print(snapshot.error);
                return Padding(
                  padding: StyleData.screenPadding,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Heading(
                        'There was an error connecting to the database.',
                      ),
                      Text(
                        snapshot.error.toString(),
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
            WillPopScope(
              // Necessary to prevent a crash when pressing the back-button
              // while the dial is open.
              onWillPop: () async {
                if (isDialOpen.value) {
                  isDialOpen.value = false;
                  return false;
                } else {
                  return true;
                }
              },
              child: FutureBuilder<ProgressData>(
                future: _progressData,
                builder: (
                  BuildContext context,
                  AsyncSnapshot<ProgressData> snapshot,
                ) {
                  if (snapshot.hasData) {
                    final ProgressData progressData = snapshot.data!;
                    return SpeedDial(
                      backgroundColor: ThemedColors.orange,
                      icon: Icons.settings,
                      activeIcon: Icons.close,
                      spacing: 4,
                      spaceBetweenChildren: 4,

                      // Necessary to make the dial close when pressing
                      // the back-button.
                      openCloseDial: isDialOpen,

                      overlayColor: Colors.black,
                      overlayOpacity: 0.5,

                      tooltip: 'Show options',
                      //isOpenOnStart: false,
                      animationSpeed: 200,
                      switchLabelPosition: true,
                      // childMargin:
                      // EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      children: <SpeedDialChild>[
                        SpeedDialChild(
                          backgroundColor: Colors.grey.shade800,
                          label: 'About',
                          labelStyle:
                              Theme.of(context).textTheme.bodyText2!.copyWith(
                                    color: Colors.black,
                                  ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute<About>(
                                builder: (BuildContext context) => About(),
                              ),
                            );
                          },
                          child: const Icon(
                            Icons.info,
                            color: Colors.white,
                          ),
                        ),
                        SpeedDialChild(
                          backgroundColor: Colors.pink.shade900,
                          label: 'Themes',
                          labelStyle:
                              Theme.of(context).textTheme.bodyText2!.copyWith(
                                    color: Colors.black,
                                  ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute<ThemeSettings>(
                                builder: (BuildContext context) =>
                                    ThemeSettings(),
                              ),
                            );
                          },
                          child: Icon(
                            SchedulerBinding
                                        .instance!.window.platformBrightness ==
                                    Brightness.light
                                ? Icons.light_mode
                                : Icons.dark_mode,
                            color: Colors.white,
                          ),
                        ),
                        if (progressData.isActive)
                          SpeedDialChild(
                            backgroundColor: Colors.lightBlue.shade700,
                            label: 'Notifications',
                            labelStyle:
                                Theme.of(context).textTheme.bodyText2!.copyWith(
                                      color: Colors.black,
                                    ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute<NotificationSettings>(
                                  builder: (BuildContext context) =>
                                      NotificationSettings(progressData),
                                ),
                              );
                            },
                            child: const Icon(
                              Icons.notifications,
                              color: Colors.white,
                            ),
                          ),
                        SpeedDialChild(
                          backgroundColor: Theme.of(context).primaryColor,
                          label: 'List of habits',
                          labelStyle:
                              Theme.of(context).textTheme.bodyText2!.copyWith(
                                    color: Colors.black,
                                  ),
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
                          child: const Icon(
                            Icons.list,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    );
                  }
                  return const SizedBox();
                },
              ),
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
            TrainingFAB(
              progressData: _progressData,
              scrollToActiveTraining: _scrollToActiveTraining,
              setHomeState: () => setState(() {}),
            ),
          ],
        ),
      ),
    );
  }
}
